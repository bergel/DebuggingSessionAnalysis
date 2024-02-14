Extension { #name : #DSWindowActivityRecord }

{ #category : #'*DebuggingSessionAnalysis' }
DSWindowActivityRecord >> debuggingActions [
	"Return all step actions and browse actions"
	^ self events select: [ :e | 
		{ DSStepActionRecord . 

		  DSBrowseContextRecord .		
		  DSSelectInspectorPageRecord .
		  DSBrowseContextRecord .
		  DSPlaygroundReadRecord
		} includes: e class ]
]

{ #category : #'*DebuggingSessionAnalysis' }
DSWindowActivityRecord >> duration [
	^ events last dateTime - events first dateTime
]

{ #category : #'*DebuggingSessionAnalysis' }
DSWindowActivityRecord >> inspectionDebuggingEvents [
	<inspectorPresentationOrder: 50 title: 'Actions'>
	^ SpRoassal3InspectorPresenter new
		canvas: self visualizeDebuggingActions;
		yourself

]

{ #category : #'*DebuggingSessionAnalysis' }
DSWindowActivityRecord >> visualizeDebuggingActions [

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
				     text: 'I';
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
