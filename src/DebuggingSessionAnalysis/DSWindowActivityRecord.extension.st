Extension { #name : #DSWindowActivityRecord }

{ #category : #'*DebuggingSessionAnalysis' }
DSWindowActivityRecord >> duration [
	^ events last dateTime - events first dateTime
]
