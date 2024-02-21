Class {
	#name : #DSAWindow,
	#superclass : #Object,
	#instVars : [
		'windowId',
		'events',
		'duration',
		'firstEventTime',
		'lastEventTime',
		'sessionStart',
		'nextWindows'
	],
	#category : #DebuggingSessionAnalysis
}

{ #category : #adding }
DSAWindow >> addNextWindow: aWindow [
	self assert: [ aWindow class == self class ].
	nextWindows add: aWindow.
]

{ #category : #accessing }
DSAWindow >> debuggingActions [
	"Return all step actions and browse actions"
	^ self events select: [ :e | 
		{ DSStepActionRecord . 

		  DSBrowseContextRecord .		
		  DSSelectInspectorPageRecord .
		  DSBrowseContextRecord .
		  DSPlaygroundReadRecord
		} includes: e class ]
]

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

{ #category : #testing }
DSAWindow >> hasNextWindow [
	^ nextWindows notEmpty
]

{ #category : #initialization }
DSAWindow >> initialize [
	super initialize.
	nextWindows := OrderedCollection new
]

{ #category : #'public - inspector' }
DSAWindow >> inspectionDebuggingEvents [
	<inspectorPresentationOrder: 50 title: 'Actions'>
	^ SpRoassal3InspectorPresenter new
		canvas: self visualizeDebuggingActions;
		yourself

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

{ #category : #accessing }
DSAWindow >> nextWindows [
	^ nextWindows
]

{ #category : #accessing }
DSAWindow >> nextWindowsAsSet [
	^ nextWindows asSet
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
	self isDebugger ifTrue: [ str nextPutAll: ' debugger' ].
	self isInspector ifTrue: [ str nextPutAll: ' inspector' ].
	self isSenderOrImplementor ifTrue: [ str nextPutAll: ' navigation' ].
	str nextPut: $).
]

{ #category : #accessing }
DSAWindow >> selectedColor [
	self isDebugger ifTrue: [ ^  Color pink ].
	self isInspector ifTrue: [ ^ Color blue ].
	self isSenderOrImplementor ifTrue: [ ^ Color green ].
	^ Color gray
]

{ #category : #accessing }
DSAWindow >> sessionStart [
	^ sessionStart
]

{ #category : #accessing }
DSAWindow >> sessionStart: aDateAndTime [
	sessionStart := aDateAndTime
]

{ #category : #'private - visualization' }
DSAWindow >> visualize [
	^ DSAVisualization new events: events; visualize
]

{ #category : #'private - visualization' }
DSAWindow >> visualizeDebuggingActions [

	| c d |
	c := RSCanvas new.
	self debuggingActions do: [ :act |
		| s s2 |
		"DEBUG ACTION"
		act class == DSStepActionRecord ifTrue: [
			d := Dictionary newFromPairs: { 'Over'. '>'. 'Into'. 'V' . 'Through' . '>>' . 'Restart' . 'R' . 'Proceed' . 'P' }.
			s := RSLabel new
				     text: (d at: act eventName);
				     color: Color red.

			s2 := RSLabel new text: (act context asString), (act node). ].
	
		"INSPECTION ACTION"	
		act class ~~ DSStepActionRecord ifTrue: [
			s := RSLabel new
				     text: 'In';
				     color: Color green.

			s2 := RSLabel new text: act context
		].
	
		s ifNotNil: [
		s @ RSPopup.
		c
			add: (s model: act);
			add: s2 ].
	].
	RSGridLayout new
		lineItemsCount: 2;
		on: c shapes.
	(2 to: c shapes size by: 2) do: [ :i |
		(c shapes at: i) translateBy: 40 @ 0 ].
	^ c @ RSCanvasController
]

{ #category : #'private - visualization' }
DSAWindow >> visualizeSummarizedDebuggingActions [

	| c d |
	c := RSCanvas new.
	self debuggingActions do: [ :act |
		| s |
		"DEBUG ACTION"
		act class == DSStepActionRecord ifTrue: [
			d := Dictionary newFromPairs: { 'Over'. '>'. 'Into'. 'V' . 'Through' . '>>' . 'Restart' . 'R' . 'Proceed' . 'P' }.
			s := RSLabel new
				     text: (d at: act eventName);
				     color: Color red ].
	
		"INSPECTION ACTION"	
		act class ~~ DSStepActionRecord ifTrue: [
			s := RSLabel new
				     text: 'In';
				     color: Color green.
		].
	
		s ifNotNil: [
			s @ RSPopup.
			c
				add: (s model: act) ].
	].
	RSGridLayout new
		on: c shapes.
	^ c @ RSCanvasController
]

{ #category : #'private - visualization' }
DSAWindow >> visualizeSummarizedDebuggingActionsOnGroup: g [
	"g is a RSGroup"
	self debuggingActions do: [ :act |
		| s d |
		"DEBUG ACTION"
		act class == DSStepActionRecord ifTrue: [
			d := Dictionary newFromPairs: { 'Over'. '>'. 'Into'. 'V' . 'Through' . '>>' . 'Restart' . 'R' . 'Proceed' . 'P' }.
			s := RSLabel new
				     text: (d at: act eventName);
				     color: Color red ].
	
		"INSPECTION ACTION"	
		act class ~~ DSStepActionRecord ifTrue: [
			s := RSLabel new
				     text: 'In';
				     color: Color green.
		].
	
		s ifNotNil: [
			s @ RSPopup.
			g
				add: (s model: act) ].
	].
	RSGridLayout new
		on: g.
	^ g
]

{ #category : #accessing }
DSAWindow >> windowId [

	^ windowId
]

{ #category : #accessing }
DSAWindow >> windowId: anID [

	windowId := anID
]
