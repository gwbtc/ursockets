|%
+$  card  card:agent:gall
++  cards

:: https://docs.urbit.org/build-on-urbit/userspace/remote-scry#scrying
|_  =bowl:gall
  ::  publishing
  ++  grow
  |=  a=*  ^-  card
    [%pass /waya %grow /foo atom+a]
  ++  tomb  ::  delete one
  |=  a=*  ^-  card
    [%pass /waya %tomb ud+1 /foo]
  ++  cull  ::  delete range
  |=  a=*  ^-  card
    [%pass /waya %cull ud+1 /foo]
  ::  encrypted
  ++  germ  ^-  card
  ::  create security context for multiparty encryption
    [%pass /call/back/path %germ /foo/bar/baz]
  ++  tend  ^-  card
    [%pass /call/back/path %tend /foo/bar/baz /foo2 atom+0]


  ::  reading
  ++  keen
  |=  [who=@p =path]  ^-  card
    ::  example gall path
    :: /g/x/4/agent//1/foo
    :: example multiparty encrypted path
    :: /g/x/4/example//1/my/context/foo
    [%pass /waiya %keen %.n who path]
  ++  chum
  |=  [who=@p =path]  ^-  card
    ::  two-party encrypted scry. no context
    :: /g/x/4/agent//1/foo
    [%pass /waiya %arvo %a %chum who path]
  ++  yawn
  |=  [who=@p =path]  ^-  card
  ::  cancel keen or chum request
    [%pass /waiya %arvo %a %yawn who path]
  ++  wham
  |=  [who=@p =path]  ^-  card
  ::  cancel keen or chum request on *all* agents or vanes
    [%pass /waiya %arvo %a %wham who path]
  --
--
