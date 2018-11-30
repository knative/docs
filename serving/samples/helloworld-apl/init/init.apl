 ⎕←'Starting knative APL runtime...'
 
 empty←0∊⍴
 _getenv←{2 ⎕NQ'.' 'GetEnvironment'⍵}

 folder←'/aplcode'
 ⎕←'Folder with apl code:' folder
 apphome←_getenv'APP_HOME'
 ⎕←'APP_HOME:'apphome
 folder ⎕NCOPY apphome

 fnname←_getenv'FUNC_HANDLER'
 ⎕←'FUNC_HANDLER:'fnname
 port←_getenv'FUNC_PORT'
 timeout←_getenv'FUNC_TIMEOUT'

 :If ∨/lx←empty¨empty port
    (lx/empty port)←'8080' '180'
 :EndIf

 port timeout←⍎¨port timeout
 
 ⎕←'Making HandlerWrapper:'
 nr←⍬
 nr,←⊂' res←HandlerWrapper arg'  
 nr,←⊂' ⍝ Handler wrapper (note from JSON server is not send context).'  
 nr,←⊂ '⎕←''Start execution handler wrapper for "',fnname,'".'''
 nr,←⊂' res←(⍎''',fnname,''')arg'
 nr,←⊂' ⎕←''Finished execution handler wrapper for "',fnname,'".''' 
 ⎕←'nr:'
 ⎕←nr
 (⊂nr)⎕NPUT folder,'/HandlerWrapper.dyalog'

 ⎕CY'/JSONServer/Distribution/JSONServer.dws'

 server←⎕NEW #.JSONServer
 server.Port←port
 server.Timeout←timeout
 server.CodeLocation←folder
 server.Threaded←0
 server.AllowHttpGet←1
 server.Logging←1
 server.Handler←'HandlerWrapper'
 server.HtmlInterface←0

 ⎕←'JSONServer argumnets:'
 ⎕←'server.Port' server.Port
 ⎕←'server.Timeout' server.Timeout
 ⎕←'server.CodeLocation' server.CodeLocation
 ⎕←'server.Threaded' server.Threaded
 ⎕←'server.AllowHttpGet' server.AllowHttpGet
 ⎕←'server.Logging' server.Logging
 ⎕←'server.Handler' server.Handler
 ⎕←'server.HtmlInterface' server.HtmlInterface

 ⎕←'Starting server'

 server.Start
 
 ⎕←'Stoped server'

