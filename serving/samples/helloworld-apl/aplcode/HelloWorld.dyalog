res←helloWorld arg;sink;target
 ⎕←'Start helloWorld fn.'
 ⎕←'arg:'arg
 sink←arg
 
 _getenv←{2 ⎕NQ'.' 'GetEnvironment'⍵}
 target←_getenv'TARGET'

 res←'Hallo world ',target

 ⎕←'End helloWorld fn.'