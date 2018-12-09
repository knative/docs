 startJsonServer;_empty;_getenv;_log;apphome;fnname;folder;lx;nr;port;server;timeout
 _empty←{0∊⍴⍵}
 _getenv←{2 ⎕NQ'.' 'GetEnvironment'⍵}
 _log←{⎕←⍵}
 _log 'Start init. of JSON Server.'
 
 apphome←_getenv'APP_HOME'
 folder←apphome,'/aplcode'
 _log'Folder with apl code:'folder

 fnname←_getenv'FUNC_HANDLER'
 _log'FUNC_HANDLER:'fnname
 port←_getenv'PORT'
 timeout←_getenv'FUNC_TIMEOUT'
 _log'FUNC_TIMEOUT:'timeout
 :If ∨/lx←_empty¨port timeout
    (lx/(port timeout))←lx/'8080' '300'
 :EndIf
 port timeout←⍎¨port timeout
 wrrapername←'HandlerWrapper'
 _log'Making ',wrrapername,':'
 nr←⍬
 nr,←⊂' res←',wrrapername,' arg'
 nr,←⊂' ⍝ Handler wrapper.'
 ⍝ nr,←⊂' ⎕←''Start execution handler wrapper for "',fnname,'".'''
 nr,←⊂' res←(⍎''',fnname,''')arg'
 ⍝ nr,←⊂' ⎕←''Finished execution handler wrapper for "',fnname,'".'''
 _log¨nr
 (⊂nr)⎕NPUT folder,'/',wrrapername,'.dyalog'

 ⎕CY'/JSONServer/Distribution/JSONServer.dws'

 server←⎕NEW #.JSONServer
 server.Port←port
 server.Timeout←timeout
 server.CodeLocation←folder
 server.Threaded←0
 server.AllowHttpGet←1
 server.Logging←1
 server.Handler←'helloWorld' ⍝ wrrapername
 server.HtmlInterface←0
 server.AccessControlAllowOrigin←''
 server.ContentType←'text/html; charset=utf-8' ⍝ or application/json; charset=utf-8

 _log'JSONServer argumnets:'
 _log'server.Port'server.Port
 _log'server.Timeout'server.Timeout
 _log'server.CodeLocation'server.CodeLocation
 _log'server.Threaded'server.Threaded
 _log'server.AllowHttpGet'server.AllowHttpGet
 _log'server.Logging'server.Logging
 _log'server.Handler'server.Handler
 _log'server.HtmlInterface'server.HtmlInterface
 _log'server.AccessControlAllowOrigin'server.AccessControlAllowOrigin
 _log'server.ContentType'server.ContentType

 _log'Starting server'

 server.Start

 _log'Stopped server'
