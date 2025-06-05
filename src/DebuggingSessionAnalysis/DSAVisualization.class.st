Class {
	#name : 'DSAVisualization',
	#superclass : 'Object',
	#instVars : [
		'events'
	],
	#category : 'DebuggingSessionAnalysis',
	#package : 'DebuggingSessionAnalysis'
}

{ #category : 'private' }
DSAVisualization >> events: someEvents [
	events := someEvents
]

{ #category : 'private' }
DSAVisualization >> produceLineLabelFrom: aClass [
	| n |
	n := aClass name.
	^ n copyFrom: 3 to: n size - 'Record' size
]

{ #category : 'private' }
DSAVisualization >> render: cls index: index on: canvas color: aColor [
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

{ #category : 'private' }
DSAVisualization >> visualize [
	| canvas blackList index rootClasses |
	canvas := RSCanvas new.
	blackList := { DSMouseEventRecord . DSSurveyRecord }.
	index := 0.
	rootClasses := DSAbstractEventRecord subclasses copyWithoutAll: blackList.
	rootClasses do: [ :rootCls | 
		| aColor |
		aColor := Color random translucent.
		({rootCls}, rootCls subclasses) do: [ :cls |
			self render: cls index: index on: canvas color: aColor.
			index := index + 1 ].
		index := index + 1 ].
	
	canvas @ RSCanvasController.
	^ canvas
]
