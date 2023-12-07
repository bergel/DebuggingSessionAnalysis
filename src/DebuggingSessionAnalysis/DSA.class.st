Class {
	#name : #DSA,
	#superclass : #Object,
	#instVars : [
		'events',
		'windows',
		'groups',
		'w',
		'offset'
	],
	#category : #DebuggingSessionAnalysis
}

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

{ #category : #private }
DSA >> populateWindows [
	windows := OrderedCollection new.
	groups := (events groupedBy: #windowId) associations.
	groups do: [ :assoc |
		w := DSAWindow new.
		w windowId: assoc key.
		w events: assoc value.
		windows add: w ]
	
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
		box width: win durationAsMinute / maxDuration * widthCanvas.
		c add: box.
		win isDebugger ifTrue: [ box color: Color pink ].
		win isInspector ifTrue: [ box color: Color blue ].
		win isSenderOrImplementor ifTrue: [ box color: Color green ].
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

{ #category : #'public - inspector' }
DSA >> windows [
	^ windows
]
