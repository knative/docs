res←helloWorld arg;sink;target
 ⎕←'Start helloWorld fn.'
 ⎕←'arg:'arg
 sink←arg
 
 _getenv←{2 ⎕NQ'.' 'GetEnvironment'⍵}
 target←_getenv'TARGET'

 :If 0=⊃⍴target
     target←'World'
 :EndIf

 res←'Hello ',target

 ⎕←'End helloWorld fn.'