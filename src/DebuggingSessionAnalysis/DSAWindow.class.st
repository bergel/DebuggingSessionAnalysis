Class {
	#name : #DSAWindow,
	#superclass : #Object,
	#instVars : [
		'events'
	],
	#category : #DebuggingSessionAnalysis
}

{ #category : #public }
DSAWindow >> visualize: someEvents [
	events := someEvents.
	self halt.
]

{ #category : #public }
DSAWindow >> visualizeFromFileName: aFilename [
	| es |
	es := OCDbgExampleCode loadDataFromPath: aFilename.
	^ self visualize: es
]
