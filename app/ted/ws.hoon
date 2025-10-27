/-  spider, nsur=nostr
/+  strandio
=,  strand=strand:spider
^-  thread:spider
|=  arg=vase
=/  m  (strand ,vase)
^-  form:m
:: =/  [url=@t req=client-msg:nsur]  (need !<((unit [@t client-msg:nsur]) arg))
=/  [url=@t wev=websocket-event:eyre]  !<([@t websocket-event:eyre] arg)
~&  >  url=url
~&  >  req=wev
=/  url  'ws://localhost:8888'
::
::
:: 


:: ;<  ~  bind:m  (send-request:strandio [%'GET' 'http://localhost:8888/test' ~ ~])
::
;<  =bowl:spider  bind:m  get-bowl:strandio
=/  desk  q.byk.bowl
=/  =task:iris  [%websocket-connect desk url]
=/  =card:agent:gall  [%pass /ws-req/nostrill %arvo %i task]
;<  ~  bind:m  (send-raw-card:strandio card)
;<  res=(pair wire sign-arvo)  bind:m  take-sign-arvo:strandio
~&  >  res=res
:: :: confirm connection was established
:: ?.  ?=([%iris %websocket-response id=@ud websocket-event:eyre] q.res)
::       (strand-fail:strand %bad-sign ~)
:: ?.  ?=(%accept +>+<.q.res)
::       (strand-fail:strand %bad-sign ~)

:: :: ~&  ws-handshake=[id.q.res url.q.res]
:: :: ?.  ?=([%iris %websocket-handshake id=@ud url=@t] q.res)
:: ::       (strand-fail:strand %bad-sign ~)
:: :: ~&  ws-handshake=[id.q.res url.q.res]
:: =/  wid  id.+.q.res
:: =/  =task:iris  [%websocket-event wid wev]
:: =/  =card:agent:gall  [%pass /ws-req-2 %arvo %i task]
:: ;<  ~  bind:m  (send-raw-card:strandio card)
:: ;<  res=(pair wire sign-arvo)  bind:m  take-sign-arvo:strandio
:: ?.  ?=(%iris -.q.res)  
::       (strand-fail:strand %bad-sign ~)
:: =/  g=gift:iris  +.q.res
(pure:m !>('done'))
