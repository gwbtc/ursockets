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
;<  =bowl:spider  bind:m  get-bowl:strandio
=/  desk  q.byk.bowl
=/  =task:iris  [%websocket-connect desk url]
=/  =card:agent:gall  [%pass /ws-req/nostrill %arvo %i task]
;<  ~  bind:m  (send-raw-card:strandio card)
;<  res=(pair wire sign-arvo)  bind:m  take-sign-arvo:strandio
~&  >  res=res
:: confirm connection was established
?.  ?=([%iris %websocket-response id=@ud websocket-event:eyre] q.res)
      (strand-fail:strand %bad-sign ~)
~&  >  ted-ws-res=+>.q.res
?.  ?=(%accept +>+<.q.res)
  (pure:m !>([%ng '']))
      :: (strand-fail:strand %bad-sign ~)

:: :: ~&  ws-handshake=[id.q.res url.q.res]
:: TODO this might fail if the subscription is not set yet
~&  >>>  "sleeping"
;<  ~  bind:m  (sleep:strandio ~s3)
~&  >>>  "slept"

=/  subwire=path  /websocket-server/(scot %ud id.q.res)
=/  =cage  [%websocket-response !>(+>.q.res)]
=/  gf=gift:agent:gall  [%fact :~(subwire) cage]
=/  =card:agent:gall  [%give gf]
~&  >>  ws-ted-ok-sending-msg=id.q.res
;<  ~  bind:m  (send-raw-card:strandio card)
;<  res2=(pair wire sign-arvo)  bind:m  take-sign-arvo:strandio
?.  ?=([%iris %websocket-response id=@ud %message wm=websocket-message:eyre] q.res2)
      (strand-fail:strand %bad-sign ~)
=/  wm=websocket-message:eyre  +>+>.q.res2
(pure:m !>([%ok id.q.res]))
