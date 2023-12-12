Class {
	#name : #BaselineOfDebuggingSessionAnalysis,
	#superclass : #BaselineOf,
	#category : #BaselineOfDebuggingSessionAnalysis
}

{ #category : #baselines }
BaselineOfDebuggingSessionAnalysis >> baseline: spec [

	<baseline>
	spec for: #common do: [ 
		spec preLoadDoIt: #loadDSSpy.
		spec package: 'DebuggingSessionAnalysis' ]
]

{ #category : #baselines }
BaselineOfDebuggingSessionAnalysis >> loadDSSpy [

	Metacello new
		baseline: 'Phex';
		repository: 'github://Pharo-XP-Tools/Phex:baseline-update';
		onWarningLog;
		load.

	Metacello new
		baseline: 'DebuggingSpy';
		repository: 'github://StevenCostiou/DebuggingSpy:P11';
		onWarningLog;
		load
]
