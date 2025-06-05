Class {
	#name : 'DSAHistoryWindow',
	#superclass : 'Object',
	#instVars : [
		'windowId',
		'jumps',
		'previousWindowHistory',
		'nextHistoryWindows'
	],
	#category : 'DebuggingSessionAnalysis',
	#package : 'DebuggingSessionAnalysis'
}

{ #category : 'instance creation' }
DSAHistoryWindow class >> fromAssociations: associations [
	| result t |
	result := OrderedCollection new.
	associations do: [ :a |
		t := self new.
		t windowId: a key.
		t jumps: a value.
		result add: t ].
	^ result
]

{ #category : 'adding' }
DSAHistoryWindow >> addNextHistoryWindow: aDSAHistoryWindow [
	self assert: [ aDSAHistoryWindow isKindOf: self class ].
	nextHistoryWindows add: aDSAHistoryWindow
]

{ #category : 'testing' }
DSAHistoryWindow >> color [
	self isBrowser ifTrue: [ ^ Color green ].
	self isImplementorOrSender ifTrue: [ ^ Color lightGreen ].
	self isInspector ifTrue: [ ^ Color blue ].
	self isDebugger ifTrue: [ ^ Color pink ].
	
	self isPlayground ifTrue: [ ^ Color blue muchLighter ].
	self isBreakpointBrowser ifTrue: [ ^ Color pink muchDarker ].
	self isCritiqueBrowser ifTrue: [ ^ Color green muchDarker ].
	self isEpicea ifTrue: [ ^ Color green muchDarker muchDarker ].
	self isIceberg ifTrue:[^Color blue muchDarker ].
	self isRewriter ifTrue:[^Color blue muchLighter muchLighter ].
	
	^ Color gray.
]

{ #category : 'as yet unclassified' }
DSAHistoryWindow >> initialize [
	super initialize.
	nextHistoryWindows := OrderedCollection new
]

{ #category : 'testing' }
DSAHistoryWindow >> isBreakpointBrowser [
	^ self jumps first window isBreakpointBrowser
]

{ #category : 'testing' }
DSAHistoryWindow >> isBrowser [
	^ self jumps first window isBrowser
]

{ #category : 'testing' }
DSAHistoryWindow >> isCritiqueBrowser [
	^ self jumps first window isCritiqueBrowser
]

{ #category : 'testing' }
DSAHistoryWindow >> isDebugger [

	^ self jumps first window isDebugger
]

{ #category : 'testing' }
DSAHistoryWindow >> isEpicea [
	^ self jumps first window isEpicea
]

{ #category : 'testing' }
DSAHistoryWindow >> isIceberg [
	^ self jumps first window isIceberg
]

{ #category : 'testing' }
DSAHistoryWindow >> isImplementorOrSender [

	^ self jumps first window isQueryTool
]

{ #category : 'testing' }
DSAHistoryWindow >> isInspector [
	^ self jumps first window isInspector
]

{ #category : 'testing' }
DSAHistoryWindow >> isPlayground [
	^ self jumps first window isPlayground
]

{ #category : 'testing' }
DSAHistoryWindow >> isRewriter [
	^ self jumps first window isRewriter
]

{ #category : 'accessing' }
DSAHistoryWindow >> jumps [

	^ jumps
]

{ #category : 'accessing' }
DSAHistoryWindow >> jumps: anObject [

	jumps := anObject
]

{ #category : 'adding' }
DSAHistoryWindow >> nextHistoryWindows [
	^ nextHistoryWindows
]

{ #category : 'as yet unclassified' }
DSAHistoryWindow >> numberOfJumps [
	^ self jumps size
]

{ #category : 'accessing' }
DSAHistoryWindow >> previousWindowHistory [

	^ previousWindowHistory
]

{ #category : 'accessing' }
DSAHistoryWindow >> previousWindowHistory: anObject [

	previousWindowHistory := anObject
]

{ #category : 'printing' }
DSAHistoryWindow >> printOn: str [

	self isDebugger ifTrue: [ str nextPutAll: 'Debugger' ].
	self isInspector ifTrue: [ str nextPutAll: 'Inspector' ].
	self isBrowser ifTrue: [ str nextPutAll: 'Browser' ].
	self isImplementorOrSender ifTrue: [
		str nextPutAll: 'Implementor/Sender' ].
	str << ' - '.
	super printOn: str 
]

{ #category : 'accessing' }
DSAHistoryWindow >> windowId [

	^ windowId
]

{ #category : 'accessing' }
DSAHistoryWindow >> windowId: anObject [

	windowId := anObject
]
