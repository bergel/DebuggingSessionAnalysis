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
DSA >> events: aCollection [
	events := aCollection.
	self populateWindows.
	^ self
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

	| windowSequence historyByWindowDict previousWindow historyByWindow c compound compounds jumps hi allWindowJumps allLeavesShapes highlightable popup lbl |
	allWindowJumps := self historyWindows filteredWindowJumps.
	
	"HISTORY BY WINDOW"
	historyByWindow := DSAHistoryWindow fromAssociations: 
								(allWindowJumps groupedBy: #windowId) associations.
	historyByWindowDict := Dictionary new.
	historyByWindow do: [ :hw |
		historyByWindowDict at: hw windowId put: hw ].


	"CONNECT NEXT"
	previousWindow := nil.
	windowSequence := allWindowJumps collect: #windowId.
	windowSequence do: [ :w |
		previousWindow ifNotNil: [
			"(historyByWindowDict at: w) previousWindowHistory: (historyByWindowDict at: previousWindow)."
			(historyByWindowDict at: previousWindow) addNextHistoryWindow: (historyByWindowDict at: w)
		].
		previousWindow := w 
	].


	"MAIN RENDERING"
	c := RSCanvas new.
	compounds := RSGroup new.
	historyByWindow do: [ :historyWin |
		compound := RSComposite new.
		jumps := RSBox models: historyWin jumps.
		jumps do: [ :j | j size: ((j model duration asSeconds sqrt * 3) max: 5) ].
		jumps do: [ :j | j model hasDebuggingOperations ifTrue: [ j borderColor: Color black ] ].
		RSFlowLayout on: jumps.
		"jumps @ (RSHighlightable new highlightColor: Color red; highlightShapes: [ :aShape | 
						| t |
						t := c shapes shapeFromModel: aShape model next.
						t ifNil: [ #() ] ])."
		popup := RSPopup new.
		popup shapeBuilder: [ :aJump |
			| g |
			g := RSGroup new.
			lbl := RSLabel new text: aJump asString.
			aJump visualizeSummarizedDebuggingActionsOnGroup: g.
			RSLocation move: lbl above: g.
			g add: lbl.
			
			g asShape
				color: Color white;
				borderColor: #black;
				padding: 3
		].
		"jumps @ popup."
		compound shapes: jumps.
		compound color: historyWin color.
		compound model: historyWin.
		compound padding: 10.
		"compound := RSBox new color: historyWin color; model: historyWin."
		
		c addShape: compound.
		compounds add: compound.
		hi := RSHighlightable new withOutgoingLines.
		compound "@ RSPopup" @ RSDraggable ].

	RSLineBuilder arrowedLine
		canvas: c;
		withBorderAttachPoint;
		shapes: compounds;
		moveBehind;
		connectToAll: #nextHistoryWindows.

	"HIGHLIGHT NEXT JUMP"
	allLeavesShapes := compounds flatCollect: #children.
	highlightable := RSHighlightable new.
	highlightable highlightColor: Color red. 
	highlightable highlightShapes: [ :aShape | 
		allLeavesShapes select: [ :s | aShape model next  == s model ] ].
	allLeavesShapes @ highlightable.
	
	highlightable := RSHighlightable new.
	highlightable highlightColor: Color orange. 
	highlightable highlightShapes: [ :aShape | 
		allLeavesShapes select: [ :s | aShape model previous  == s model ] ].
	allLeavesShapes @ highlightable.

	"LAYOUT"
	RSForceBasedLayout new charge: -2000; on: compounds.
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
