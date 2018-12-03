res←helloWorld arg;sink;empty;target;_getenv
 ⎕←'Start helloWorld fn.'
 ⎕←arg
 sink←arg
 empty←0∊⍴
 _getenv←{2 ⎕NQ'.' 'GetEnvironment'⍵}

 target←_getenv'TARGET'
 res←'Hallo world ',target

 ⎕←'End helloWorld fn.'