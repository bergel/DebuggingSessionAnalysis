Class {
	#name : 'BaselineOfDebuggingSessionAnalysis',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfDebuggingSessionAnalysis',
	#package : 'BaselineOfDebuggingSessionAnalysis'
}

{ #category : 'baselines' }
BaselineOfDebuggingSessionAnalysis >> baseline: spec [

	<baseline>
	spec for: #common do: [ 
		spec preLoadDoIt: #loadDSSpy.
		spec package: 'DebuggingSessionAnalysis' ]
]

{ #category : 'baselines' }
BaselineOfDebuggingSessionAnalysis >> loadDSSpy [

	Metacello new
		baseline: 'Phex';
		repository: 'github://Pharo-XP-Tools/Phex:main';
		onWarningLog;
		load.

	Metacello new
		baseline: 'DebuggingSpy';
		repository: 'github://StevenCostiou/DebuggingSpy:P12';
		onWarningLog;
		load
]
