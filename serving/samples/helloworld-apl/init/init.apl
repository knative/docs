⎕←'Starting knative APL runtime...'

_getenv←{2 ⎕NQ'.' 'GetEnvironment'⍵}

apphome←_getenv'APP_HOME'
⎕←'APP_HOME:'apphome

sink←⎕FX⊃⎕NGET (apphome,'/init/StartJsonServer.apl')1
startJsonServer

⎕←'Closing knative APL runtime.'
