Class {
	#name : #DSA,
	#superclass : #Object,
	#instVars : [
		'events',
		'windows',
		'groups',
		'offset'
	],
	#category : #DebuggingSessionAnalysis
}

{ #category : #accessing }
DSA >> events [
	^ events
]

{ #category : #public }
DSA >> fromFileName: aFilename [
	"Public method. Entry point of the Visualization Framework."
	
	"es := OCDbgExampleCode loadDataFromPath: aFilename."
	self assert: [ aFilename isString ].
	self assert: [ aFilename endsWith: '.ston' ].
	events := STON fromString: aFilename asFileReference readStream contents.
	self populateWindows.
	^ self
]

{ #category : #accessing }
DSA >> historyWindows [
	"NEED TO BUILD A VISUALIZATION FOR THIS!!!!!"
	^ (DSRecordHistory on: self events) buildWindowHistory
]

{ #category : #initialization }
DSA >> initialize [
	super initialize.
	offset := Duration days: 0 hours: 0 minutes: 0 seconds: 0
]

{ #category : #'public - inspector' }
DSA >> inspectorCanvas [
	<inspectorPresentationOrder: 50 title: 'Timeline'>
	^ SpRoassal3InspectorPresenter new
		canvas: (self visualize: events);
		yourself
]

{ #category : #'public - inspector' }
DSA >> inspectorCanvasContext: aContext [

	aContext withoutEvaluator
]

{ #category : #'public - inspector' }
DSA >> inspectorVisualizeWindowFlow [
	<inspectorPresentationOrder: 50 title: 'Window flow'>
	^ SpRoassal3InspectorPresenter new
		canvas: self visualizeWindowFlow;
		yourself
]

{ #category : #'public - inspector' }
DSA >> inspectorVisualizeWindowFlowContext: aContext [

	aContext withoutEvaluator
]

{ #category : #'public - inspector' }
DSA >> inspectorVisualizeWindowHistory [
	<inspectorPresentationOrder: 50 title: 'Window History'>
	^ SpRoassal3InspectorPresenter new
		canvas: self visualizeHistory;
		yourself
]

{ #category : #'public - inspector' }
DSA >> inspectorWindow [
	<inspectorPresentationOrder: 90 title: 'All windows'>
	^ SpListPresenter new
		items: self windows;
		yourself
]

{ #category : #'public - inspector' }
DSA >> inspectorWindowTimeline [
	<inspectorPresentationOrder: 90 title: 'Window timeline'>
	^ SpRoassal3InspectorPresenter new
		canvas: self visualizeWindowTimelines;
		yourself
]

{ #category : #accessing }
DSA >> pingpongWindows [
	| pWindows |
	pWindows := OrderedCollection new.
	self windows do: [ :win |
		(win nextWindows anySatisfy: [ :ww | ww nextWindows includes: win ])
			ifTrue: [ pWindows add: win ]
	].
	^ pWindows
]

{ #category : #private }
DSA >> populateWindows [
	| previousWindow currentWindow isPreviousWindowClosed |
	windows := OrderedCollection new.
	groups := (events groupedBy: #windowId) associations.
	groups do: [ :assoc |
		| ww |
		ww := DSAWindow new.
		ww windowId: assoc key.
		ww events: assoc value.
		windows add: ww ].

	previousWindow := nil.
	isPreviousWindowClosed := false.
	events do: [ :anEvent |
		currentWindow := self windowForEvent: anEvent.
		(previousWindow notNil and: [ previousWindow ~~ currentWindow ]) ifTrue: [
			isPreviousWindowClosed ifFalse: [ 
				currentWindow numberOfEvents > 3 ifTrue: [ 
					previousWindow addNextWindow: currentWindow ] ]
		].
		previousWindow := currentWindow.
		isPreviousWindowClosed := anEvent isKindOf: DSWindowClosedRecord
	]
	
]

{ #category : #accessing }
DSA >> relevantDebuggingWindows [
	"Debugger windows with at least one action"
	^ (self windows select: [ :ww | ww isDebugger and: [ ww debuggingActions notEmpty ] ]) sortedAs: #firstEventTime
]

{ #category : #initialization }
DSA >> setOffsetMinute: min seconds: sec [
	offset := Duration days: 0 hours: 0 minutes: min seconds: sec
]

{ #category : #private }
DSA >> visualize: someEvents [
	^ DSAVisualization new events: someEvents; visualize
]

{ #category : #public }
DSA >> visualizeFromFileName: aFilename [
	"Public method. Entry point of the Visualization Framework."
	
	"es := OCDbgExampleCode loadDataFromPath: aFilename."
	self assert: [ aFilename isString ].
	self assert: [ aFilename endsWith: '.ston' ].
	events := STON fromString: aFilename asFileReference readStream contents.
	self populateWindows.
	^ self visualize: events
]

{ #category : #public }
DSA >> visualizeHistory [

	| windowSequence windowSequencePrevious previousWindow historyByWindow c |
	"Key are windows, value are next window"
	windowSequencePrevious := Dictionary new.
	previousWindow := nil.
	windowSequence := self historyWindows windowJumps collect: [:j | j window sourceEvent windowId ].
	windowSequence do: [ :w |
		previousWindow ifNotNil: [
			windowSequencePrevious at: w put: previousWindow ].
		previousWindow := w ].

	historyByWindow := (self historyWindows windowJumps groupedBy:
		                    [:j | j window sourceEvent windowId ]) associations.

	c := RSCanvas new.
	historyByWindow do: [ :assoc |
		| box |
		box := RSBox new size: assoc value size / 20 + 5; model: assoc key.
		
		(assoc value first printString beginsWith: 'Browser') ifTrue: [ box color: Color green ].
		(assoc value first printString beginsWith: 'Inspector') ifTrue: [ box color: Color blue ].
		(assoc value first printString beginsWith: 'Debugger') ifTrue: [ box color: Color pink ].
		
		c addShape: box.
		box @ RSPopup @ RSDraggable ].

	"RSNormalizer size
		shapes: c shapes;
		normalize: [ :m | m value size ]."

	RSLineBuilder line
		canvas: c;
		shapes: c shapes;
		connectFrom: [ :w | windowSequencePrevious at: w ifAbsent: [ nil ] ].

	RSForceBasedLayout on: (c shapes select: [:s | s class == RSBox ]).
	^ c @ RSCanvasController
]

{ #category : #public }
DSA >> visualizeWindowFlow [

	| c shapes int int2 |
	c := RSCanvas new.
	shapes := RSCircle models: self windows.
	shapes do: [ :s | s color: s model selectedColor ].
	int := RSHighlightable new withOutgoingLines highlightColor:
		       Color red.
	int2 := RSHighlightable new withIncomingLines highlightColor:
		        Color black.
	shapes @ RSPopup @ RSDraggable @ int @ int2.
	c addAll: shapes.

	RSLineBuilder line
		canvas: c;
		shapes: shapes;
		connectToAll: #nextWindowsAsSet.

	RSForceBasedLayout new
		charge: -300;
		on: shapes.
	c lines pushBack.
	c lines do: [ :l | l color: (Color gray alpha: 0.1) ].

	RSNormalizer size
		shapes: shapes;
		from: 5;
		to: 20;
		normalize: #numberOfEvents.
	c @ RSCanvasController.
	^ c
]

{ #category : #public }
DSA >> visualizeWindowTimelines [

	| c maxDuration minTime maxTime box widthCanvas |
	c := RSCanvas new.
	widthCanvas := 500.
	maxDuration := self windows max: #durationAsMinute.
	minTime := (self windows min: #firstEventTime).
	maxTime := (self windows max: #lastEventTime).
	self windows doWithIndex: [ :win :index | 
		box := RSBox new.
		box model: win.
		box height: 10.
		box width: ((win durationAsMinute / maxDuration * widthCanvas) max: 5).
		c add: box.
		box color: win selectedColor.
		box @ RSPopup.
	].
	RSVerticalLineLayout new verticalGap: 5; on: c shapes.
	
	c shapes do: [ :aBox |
		| ss |
		ss := aBox model firstEventTime - minTime.
		aBox model sessionStart: ss + offset.
		aBox translateBy: (ss asDuration asMinutes / maxDuration * widthCanvas)@ 0 ].
	
	c @ RSCanvasController.
	^ c
]

{ #category : #private }
DSA >> windowForEvent: anEvent [
	^ windows detect: [ :win | win windowId = anEvent windowId ]
]

{ #category : #'public - inspector' }
DSA >> windows [
	^ windows
]
