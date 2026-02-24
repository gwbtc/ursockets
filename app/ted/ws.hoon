/-  spider, ui=nostrill-ui
/+  strandio, jsonlib=json-nostrill, sr=sortug, lib=nostrill
=,  strand=strand:spider
=,  strand-fail=strand-fail:libstrand:spider
^-  thread:spider
::  One Off WebSockets message thread
::  Connets to WebSockets server, awaits the connection to be open, sends message, awaits confirmation, then closes connection
|=  arg=vase
  =/  m  (strand ,vase)  ^-  form:m
  ;<  =bowl:spider  bind:m  get-bowl:strandio
  =|  retries=@ud
  :: =/  args  !<([@t websocket-message:eyre] arg)
  :: ~&  >>  args=args
  :: =/  endpoint  -.args
  :: =/  wmsg  +.args
  ~&  >>  arg=arg
  =/  dev  !<((unit @t) arg)
  =/  endpoint  (need dev)
  |^
  
  ::
  =/  =task:iris  [%websocket-connect q.byk.bowl endpoint]
  =/  iris-card  [%pass /ws-connect %arvo %i task]
  ;<  ~  bind:m  (send-raw-card:strandio iris-card)
  :: ~&  >  "sleeping..."
  :: ;<  ~  bind:m  (sleep:strandio ~s3)
  :: ~&  >  "woke up..."
  :: ::
  ;<  wid=@ud  bind:m  %+  (retry:strandio @ud)  `7  (get-wid)
  :: ;<  wid=@ud  bind:m  (rescry (list socket) /ix/ws/app)
  ~&  >>  wid=wid
  :: =/  uwid=(unit @ud)
  ::   |-  ?~  skets  ~
  ::     ?:  .=(url.i.skets endpoint)  `wid.i.skets
  ::     $(skets t.skets)
  :: ?~  uwid  (pure:m !>(~))

  
  (pure:m !>(~))
  :: ?+  -.action.req  (pure:m !>(bail))
  ::   %sync
  ::     ;<  =bowl:spider  bind:m  get-bowl:strandio
  ::     =/  desk  q.byk.bowl

  ::     ~&  >  ship=ship
  ::     =/  =user:sur  (atom-to-user:lib ship)
  ::     (pure:m !>(j))
  :: ==
    +$  socket  [wid=@ud url=@t status=$?(%accepted %pending)]
    ++  rescry
      ~&  >>>  "rescry"
      |*  [=mold =path]
      =/  m  (strand ,mold)
      ^-  form:m
      ?>  ?=(^ path)
      ?>  ?=(^ t.path)
      =*  loop  $
        ?:  (gte retries 3)  (strand-fail %retry-too-many ~)
        ~&  looping=retries

        =/  sockets  .^((list socket) i.path (scot %p our.bowl) i.t.path (scot %da now.bowl) t.t.path)
        ?~  sockets
          ~&  "sleeping..."
          ;<  ~  bind:m  (sleep:strandio ~s2)
          loop(retries +(retries))
        |-  ?~  sockets  loop(retries +(retries))
          ?.  .=(url.i.sockets endpoint)
            $(sockets t.sockets)
          ?.  ?=(%accepted status.i.sockets)
            $(sockets t.sockets)
          (pure:m `wid.i.sockets)
    
    ++  get-wid
      |.
      ~&  >  "hey hey getting wid"
      =/  m  (strand ,(unit @))
      ^-  form:m
      =/  sockets  .^((list socket) %ix (scot %p our.bowl) %ws (scot %da now.bowl) /app)
      ~&  >>>  get-wid=sockets
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
