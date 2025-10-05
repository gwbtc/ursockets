/-  spider
/+  strandio, jsonlib=json-nostrill, sr=sortug
=,  strand=strand:spider
=,  strand-fail=strand-fail:libstrand:spider
^-  thread:spider
|=  arg=vase
  =/  m  (strand ,vase)  ^-  form:m
  |^
  =/  ujon  !<((unit json) arg)
  :: ~&  ujon=ujon
  ?~  ujon  (pure:m !>(bail))
  =/  req  (ui:de:jsonlib u.ujon)
  ?~  req  (pure:m !>(bail))
  ?.  ?=(%begs -.u.req)  (pure:m !>(bail))
  ?-  +<.u.req
    %feed
      ;<  =bowl:spider  bind:m  get-bowl:strandio
      =/  desk  q.byk.bowl
      ~&  dock=[+>.u.req desk]
      ;<  =cage  bind:m  (watch-one:strandio /beg/feed [+>.u.req desk] /beg/feed)
      ~&  >  watch-cage=-.cage
      =/  j  !<(json +.cage)
      (pure:m !>(j))

    %thread
      ;<  =bowl:spider  bind:m  get-bowl:strandio
      =/  desk  q.byk.bowl
      ~&  dock=[+>.u.req desk]
      =/  ship=@p  +>-.u.req
      =/  id=@da  +>+.u.req
      =/  ids  (crip (scow:sr %uw `@`id))
      =/  wire  /beg/thread/[ids]
      ;<  =cage  bind:m  (watch-one:strandio wire [ship desk] wire)
      ~&  >  watch-cage=-.cage
      =/  j  !<(json +.cage)
      (pure:m !>(j))
  ==
    ++  bail  ^-  json
    %+  frond:enjs:format  %error
    s+'error'
  --
