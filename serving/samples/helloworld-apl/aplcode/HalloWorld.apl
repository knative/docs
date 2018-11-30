res←halloWorld;empty;getenv;modename;_getenv;folder;aplfile;fnname;timeout;port;lx;server;nr
 ⎕←'Start halloWorld fn.'
 empty←0∊⍴
 _getenv←{2 ⎕NQ'.' 'GetEnvironment'⍵}

 target←_getenv'TARGET'
 res←'Hallo world ',target
 
 ⎕←'Stop halloWorld fn.'