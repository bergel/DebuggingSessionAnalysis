Class {
	#name : #DSA,
	#superclass : #Object,
	#instVars : [
		'events'
	],
	#category : #DebuggingSessionAnalysis
}

{ #category : #'public - inspector' }
DSA >> inspectorCanvas [
	<inspectorPresentationOrder: 90 title: 'All events'>
	^ SpRoassal3InspectorPresenter new
		canvas: (self visualize: events);
		yourself
]

{ #category : #'public - inspector' }
DSA >> inspectorCanvasContext: aContext [

	aContext withoutEvaluator
]

{ #category : #private }
DSA >> produceLineLabelFrom: aClass [
	| n |
	n := aClass name.
	^ n copyFrom: 3 to: n size - 'Record' size
]

{ #category : #private }
DSA >> render: cls index: index on: canvas color: aColor [
	| relevantEvents allShapes line lbl verticalGap |
	verticalGap := 15.
	relevantEvents := events select: [ :e | e isKindOf: cls ].
	allShapes := RSCircle models: relevantEvents. 
	allShapes color: aColor.
	allShapes @ RSPopup.
	canvas addAll: allShapes.
	
	RSNormalizer position
		to: 500 @ 500;
		shapes: allShapes;
		normalize: [ :event | (event dateTime asSeconds) @ 0 ].
		
	allShapes do: [ :s |
		s translateBy: 0 @ index * verticalGap ].
	
	line := RSLine new from: 0@ (index * verticalGap); to: 500@ (index * verticalGap).
	line color: Color veryVeryLightGray.
	canvas add: line.
	line pushBack.
	
	lbl := RSLabel model: (self produceLineLabelFrom: cls).
	canvas add: lbl.
	RSLocation move: lbl onTheLeftOf: line.
	lbl translateBy: -20@0.
]

{ #category : #public }
DSA >> visualize: someEvents [
	| canvas blackList index rootClasses |
	events := someEvents.
	
	canvas := RSCanvas new.
	blackList := { DSMouseEventRecord }.
	index := 0.
	rootClasses := DSAbstractEventRecord subclasses copyWithoutAll: blackList.
	rootClasses do: [ :rootCls | 
		| aColor |
		aColor := Color random translucent.
		rootCls subclasses do: [ :cls |
			self render: cls index: index on: canvas color: aColor.
			index := index + 1 ].
		index := index + 1 ].
	
	canvas @ RSCanvasController.
	^ canvas
]

{ #category : #public }
DSA >> visualizeFromFileName: aFilename [
	
	"es := OCDbgExampleCode loadDataFromPath: aFilename."
	self assert: [ aFilename isString ].
	self assert: [ aFilename endsWith: '.ston' ].
	events := STON fromString: aFilename asFileReference readStream contents.
	^ self visualize: events
]
