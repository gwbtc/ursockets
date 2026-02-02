/-  spider, ui=nostrill-ui
/+  strandio, jsonlib=json-nostrill, sr=sortug, lib=nostrill
=,  strand=strand:spider
=,  strand-fail=strand-fail:libstrand:spider
^-  thread:spider
|=  arg=vase
  =/  m  (strand ,vase)  ^-  form:m
  |^
  =/  ujon  !<((unit json) arg)
  ~&  >>  sync-thread=ujon
  ?~  ujon  bail
  =/  ureq  (de-relay-do:de:jsonlib u.ujon)
  ?~  ureq  ~&  bad-json=(en:json:html u.ujon)  bail  
  =/  req=relay-handling:ui  u.ureq
  ~&  req=req
  ;<  =bowl:spider  bind:m  get-bowl:strandio
  ?.  ?=(relay-get:ui action.req)  bail
  =/  t=ted:ui  [%req tid.bowl relays.req action.req]

  ;<  ~  bind:m  (poke-our:strandio %nostrill %nostrill-ted !>(t))
  ;<  v=vase  bind:m  (take-poke:strandio %nostrill-ted)
  ~&  v=v
  =/  res  !<(ted:ui v)
  ~&  sub-id-to-ted=res
  ?.  ?=(%res -.res)  bail
  =/  j=json  [%s sub-id.res]
  (pure:m !>(j))
  :: ?+  -.action.req  (pure:m !>(bail))
  ::   %sync
  ::     ;<  =bowl:spider  bind:m  get-bowl:strandio
  ::     =/  desk  q.byk.bowl

  ::     ~&  >  ship=ship
  ::     =/  =user:sur  (atom-to-user:lib ship)
  ::     (pure:m !>(j))
  :: ==
    ++  bail
    %-  pure:m   !>
      ^-  json
      %+  frond:enjs:format  %error
      s+'error'
  --
