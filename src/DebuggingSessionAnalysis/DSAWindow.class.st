Class {
	#name : #DSAWindow,
	#superclass : #Object,
	#instVars : [
		'windowId',
		'events',
		'duration',
		'firstEventTime',
		'lastEventTime',
		'sessionStart'
	],
	#category : #DebuggingSessionAnalysis
}

{ #category : #accessing }
DSAWindow >> durationAsMinute [
	^ duration asMinutes round: 1
]

{ #category : #accessing }
DSAWindow >> events [

	^ events
]

{ #category : #accessing }
DSAWindow >> events: someEvents [
	| dts |
	self assert: [ someEvents isCollection ].
	self assert: [ someEvents notEmpty ].
	events := someEvents.
	
	dts := events collect: #dateTime.
	
	firstEventTime := dts min.
	lastEventTime := dts max.
	
	duration := lastEventTime - firstEventTime
	

]

{ #category : #accessing }
DSAWindow >> firstEventTime [
	^ firstEventTime
]

{ #category : #'public - inspector' }
DSAWindow >> inspectorCanvas [
	<inspectorPresentationOrder: 50 title: 'Timeline'>
	^ SpRoassal3InspectorPresenter new
		canvas: self visualize;
		yourself
]

{ #category : #'public - inspector' }
DSAWindow >> inspectorCanvasContext: aContext [

	aContext withoutEvaluator
]

{ #category : #'public - inspector' }
DSAWindow >> inspectorEvents [
	<inspectorPresentationOrder: 90 title: 'All events'>
	^ SpListPresenter new
			items: self events;
			yourself
]

{ #category : #testing }
DSAWindow >> isDebugger [
	self events ifEmpty: [ ^ false ].
	^ self events first class == DSDebuggerOpeningRecord
]

{ #category : #testing }
DSAWindow >> isInspector [
	self events ifEmpty: [ ^ false ].
	^ self events first class == DSWindowOpenedRecord and: [ self events first windowName beginsWith: 'Inspector' ]
]

{ #category : #testing }
DSAWindow >> isSenderOrImplementor [
	self events ifEmpty: [ ^ false ].
	self events detect: [ :e | e class == DSQueryBrowseRecord ] ifNone: [ ^ false ].
	^ true
]

{ #category : #accessing }
DSAWindow >> lastEventTime [
	^ lastEventTime
]

{ #category : #printing }
DSAWindow >> numberOfEvents [
	^ events size
]

{ #category : #printing }
DSAWindow >> printOn: str [
	super printOn: str.
	str nextPut: $(.
	str nextPutAll: self numberOfEvents asString.
	str nextPutAll: ' events, '.
	
	str nextPut: $).
]

{ #category : #accessing }
DSAWindow >> sessionStart [
	^ sessionStart
]

{ #category : #accessing }
DSAWindow >> sessionStart: aDateAndTime [
	sessionStart := aDateAndTime
]

{ #category : #private }
DSAWindow >> visualize [
	^ DSAVisualization new events: events; visualize
]

{ #category : #accessing }
DSAWindow >> windowId [

	^ windowId
]

{ #category : #accessing }
DSAWindow >> windowId: anObject [

	windowId := anObject
]
