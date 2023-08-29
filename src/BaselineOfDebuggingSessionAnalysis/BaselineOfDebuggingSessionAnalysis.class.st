Class {
	#name : #BaselineOfDebuggingSessionAnalysis,
	#superclass : #BaselineOf,
	#category : #BaselineOfDebuggingSessionAnalysis
}

{ #category : #baselines }
BaselineOfDebuggingSessionAnalysis >> baseline: spec [

	<baseline>
	spec for: #common do: [ 
		spec package: 'DebuggingSessionAnalysis' ]
]
