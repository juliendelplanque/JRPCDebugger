Class {
	#name : #JRPCASTDebugger,
	#superclass : #JRPCDebugger,
	#category : #JRPCDebugger
}

{ #category : #actions }
JRPCASTDebugger >> context [
	^ self session currentContext contextTag  
]

{ #category : #actions }
JRPCASTDebugger >> currentMethodNode [
	^ self currentNode methodNode
]

{ #category : #actions }
JRPCASTDebugger >> currentNode [
	^ self session currentNode
]

{ #category : #actions }
JRPCASTDebugger >> displayCurrentContext [
	^ self session currentContext asString
]

{ #category : #actions }
JRPCASTDebugger >> init: aString [
	process := DASTInterpreter new.
	process initializeWithProgram: (RBParser parseExpression: aString).
	session := process.
	^ self lineInfo
]

{ #category : #actions }
JRPCASTDebugger >> initialize [
	super initialize.
	jrpcServer addHandlerNamed: 'currentcontext' block: [ self displayCurrentContext ].
	jrpcServer addHandlerNamed: 'where' block: [ self where ].
	jrpcServer addHandlerNamed: 'stepThrough' block: [ self stepThrough ].
						
]

{ #category : #actions }
JRPCASTDebugger >> resume [
	^ JRPCDEvalInfo result: process evaluate.
]

{ #category : #actions }
JRPCASTDebugger >> stepThrough [
	| context |
	context := self context. 
	self step.
	[ (self context isBlockContext and: [ self context parent = context ]) or: [ self context = context ] ] whileFalse: [ self step ].
	^ self lineInfo 
]

{ #category : #actions }
JRPCASTDebugger >> where [
	| stack context |
	stack := OrderedCollection new.
	context := self session currentContext.
	[ context isNil ]
		whileFalse: [ stack add: context asString.
			context := context sender ].
	^ stack asArray
]
