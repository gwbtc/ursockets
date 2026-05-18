/-  spider, ui=nostrill-ui, comms=nostrill-comms
/+  strandio, jsonlib=json-nostrill, sr=sortug, lib=nostrill, ws=websockets
=,  strand=strand:spider
=,  strand-fail=strand-fail:libstrand:spider
^-  thread:spider
::  One Off WebSockets message thread
::  Connets to WebSockets server, awaits the connection to be open, sends message, awaits confirmation, then closes connection
|=  arg=vase
  ~&  "calling websockets %ws thread"
  =/  m  (strand ,vase)  ^-  form:m
  ;<  =bowl:spider  bind:m  get-bowl:strandio
  =/  args  !<([@t websocket-message:eyre] arg)
  =/  endpoint  -.args
  |^
  
  ::
  =/  =task:iris  [%websocket-connect q.byk.bowl endpoint]
  =/  iris-card  [%pass /ws-connect %arvo %i task]
  ;<  ~  bind:m  (send-raw-card:strandio iris-card)
  ;<  wid=@ud  bind:m  %+  (retry:strandio @ud)  `5  get-wid
  :: ~&  >>  ted-found-wid=wid
  ::  NOTE: can't directly send cards to Iris, Iris is subscribed to the agent, not the Thread, hence won't receive them. Poke the agent instead
  =/  pok=poke:comms  [%ted wid %msg +.args]
  ;<  ~  bind:m  (poke-our:strandio %nostrill %noun !>(pok))
  ;<  ~  bind:m  (sleep:strandio ~s2)

  =/  pok=poke:comms  [%ted wid %disconnect ~]
  ;<  ~  bind:m  (poke-our:strandio %nostrill %noun !>(pok))

  
  
  
  (pure:m !>(~))
  
  :: ==
    +$  socket  [wid=@ud url=@t status=$?(%accepted %pending)]    
    ++  get-wid
      :: ~&  get-wid=endpoint
      =/  m  (strand ,(unit @))
      ^-  form:m
      :: .^(* %ix /=//=/ws)
      ;<  sockets=(list socket)  bind:m  (scry:strandio (list socket) /ix//ws/nostrill)
      :: :: =/  sockets  .^((list socket) %ix (scot %p our.bowl) %ws (scot %da now.bowl) /app)
      :: ~&  >>>  get-wid=sockets
      ?~  sockets  (pure:m ~)
      =/  l=(list socket)  sockets
      |-  ?~  l  (pure:m ~)
        =/  =socket  i.l
        ?.  .=(url.socket endpoint)
          $(l t.l)
        ?.  ?=(%accepted status.socket)
          $(l t.l)
        (pure:m `wid.socket)

    ++  bail
    %-  pure:m   !>
      ^-  json
      %+  frond:enjs:format  %error
      s+'error'
      
  --
