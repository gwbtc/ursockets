/-  spider, nsur=nostr
/+  strandio
=,  strand=strand:spider
^-  thread:spider
|=  arg=vase
=/  m  (strand ,vase)
^-  form:m
:: =/  [url=@t req=client-msg:nsur]  (need !<((unit [@t client-msg:nsur]) arg))
=/  [url=@t wmsg=websocket-message:eyre]  !<([@t websocket-message:eyre] arg)
~&  >  url=url
~&  >  req=wmsg
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
~&  >  ted-ws-res=+>+<.q.res
?.  ?=(%accept +>+<.q.res)
  (pure:m !>([%ng '']))
      :: (strand-fail:strand %bad-sign ~)

~&  "ws connection accepted, sending ws msg"
~&  >>>  "sleeping"
;<  ~  bind:m  (sleep:strandio ~s3)
~&  >>>  "slept"
=/  card2=card:agent:gall
  [%pass /ws/proxy %agent [our.bowl desk] %poke %websocket-thread !>([id.q.res wmsg])]
;<  ~  bind:m  (send-raw-card:strandio card2)
;<  res2=(pair wire sign-arvo)  bind:m  take-sign-arvo:strandio


:: =/  subwire=path  /websocket-server/(scot %ud id.q.res)
:: =/  =cage  [%websocket-response !>(+>.q.res)]
:: =/  gf=gift:agent:gall  [%fact :~(subwire) cage]
:: =/  =card:agent:gall  [%give gf]
:: ~&  >>  ws-ted-ok-sending-msg=id.q.res
:: ;<  ~  bind:m  (send-raw-card:strandio card)
:: ;<  res2=(pair wire sign-arvo)  bind:m  take-sign-arvo:strandio
:: ?.  ?=([%iris %websocket-response id=@ud %message wm=websocket-message:eyre] q.res2)
::       (strand-fail:strand %bad-sign ~)
:: =/  wm=websocket-message:eyre  +>+>.q.res2
(pure:m !>([%ok id.q.res]))
