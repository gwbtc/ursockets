/-  spider
/+  strandio
=,  strand=strand:spider
^-  thread:spider
|=  arg=vase
=/  m  (strand ,vase)
^-  form:m
=/  url=@t  (need !<((unit @t) arg))
;<  =bowl:spider  bind:m  get-bowl:strandio
=/  desk  q.byk.bowl
=/  =task:iris  [%websocket-connect desk url]
=/  =card:agent:gall  [%pass /ws-req %arvo %i task]
;<  ~  bind:m  (send-raw-card:strandio card)
;<  res=(pair wire sign-arvo)  bind:m  take-sign-arvo:strandio
?.  ?=([%iris %websocket-handshake id=@ud url=@t] q.res)
      (strand-fail:strand %bad-sign ~)
~&  ws-handshake=[id.q.res url.q.res]
:: ?:  ?=([%iris %websocket-response id=@ud e=websocket-event:eyre] q.res)
=/  data=@t  'done'
(pure:m !>(data))
