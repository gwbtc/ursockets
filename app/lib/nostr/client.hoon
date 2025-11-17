/-  sur=nostrill, nsur=nostr
/+  js=json-nostr, sr=sortug, nostr-keys, constants, server, ws=websockets
/=  web  /web/router
|_  [=state:sur =bowl:gall]

+$  card  card:agent:gall
++  parse-msg
  |=  [eyre-id=@ta req=inbound-request:eyre]
  ^-  (unit relay-msg:nsur)
  ?~  body.request.req  ~
  =/  jstring  q.u.body.request.req
  (parse-body jstring)
++  parse-body  |=  jstring=@t
  =/  ures  (de:json:html jstring)
  ?~  ures  ~
  =/  ur  (relay-msg:de:js u.ures)
  ?~  ur  ~&  >>>  relay-msg-parsing-failed=jstring  ~
  ur
:: __

:: ++  get-req  |=  fs=(list filter:nsur)
::     ^-  [bulk-req:shim:nsur _state]
::     =/  rls  ~(tap by relays.state)
::     =|  urls=(list @t)
::     =/  sub-id  (gen-sub-id:nostr-keys eny.bowl)
::     =/  req=client-msg:nsur  [%req sub-id fs]
::     |-  ?~  rls  [[urls req] state]
::       ::  build http card
::       =/  [url=@t rs=relay-stats:nsur]  i.rls
::       ::  mutate relays stats
::       =/  nrs  rs(reqs nreqs)
::       =.  relays.state  (~(put by relays.state) url nrs)
::       $(urls [url urls], rls t.rls)

++  send-req  |=  fs=(list filter:nsur)
    ^-  (quip card _state)
    =/  sub-id  (gen-sub-id:nostr-keys eny.bowl)
    =/  req=client-msg:nsur  [%req sub-id fs]
    =/  rls  ~(tap by relays.state)
    ?~  rls  !!
    :: TODO not how this should work
    =/  rs=relay-stats:nsur  +.i.rls
    =/  wid  -.i.rls
    =/  url  url.rs
    =/  es=event-stats:nsur  [fs 0]  
    =.  reqs.rs  (~(put by reqs.rs) sub-id es)
    =.  relays.state  (~(put by relays.state) wid rs)
    ~&  >  sending-ws-req=sub-id
    :-  :~  (send url req)  ==  state


++  get-posts
  ^-  (quip card _state)
  =/  kinds  (silt ~[1])
  :: =/  last-week  (sub now.bowl ~d7)
  =/  last-week  (sub now.bowl ~m2)
  :: =/  since  (to-unix-secs:jikan:sr last-week)
  =/  =filter:nsur  [~ ~ `kinds ~ `last-week ~ ~]
  (send-req ~[filter])

++  get-user-feed
  |=  pubkey=@ux
  ^-  (quip card _state)
  =/  kinds  (silt ~[1])
  :: =/  since  (to-unix-secs:jikan:sr last-week)
  =/  pubkeys  (silt ~[pubkey])
  =/  =filter:nsur  [~ `pubkeys `kinds ~ ~ ~ ~]
  (send-req ~[filter])

++  get-profiles
  |=  pubkeys=(set @ux)
    ^-  (quip card _state)
    =/  kinds  (silt ~[0])
    =/  =filter:nsur  [~ `pubkeys `kinds ~ ~ ~ ~]
  (send-req ~[filter])

++  get-engagement
  |=  post-ids=(set @ux)
    ^-  (quip card _state)
    =/  post-strings  %-  ~(run in post-ids)  |=  id=@ux  (crip (scow:sr %ux id))
    =/  =filter:nsur
      =/  kinds  (silt ~[6 7])
      =/  tags  (malt :~([%e post-strings]))
      [~ ~ `kinds `tags ~ ~ ~]
  (send-req ~[filter])

++  get-quotes
  |=  post-id=@ux
  ^-  (quip card _state)
    =/  post-string  (crip (scow:sr %ux post-id))
    =/  kinds  (silt ~[1])
    =/  tags  (malt :~([%q (silt ~[post-string])]))
    =/  =filter:nsur  [~ ~ `kinds `tags ~ ~ ~]
  (send-req ~[filter])

::
++  test-connection
  |=  relay-url=@t
  =/  kinds  (silt ~[1])
  =/  since  (sub now.bowl ~m10)
  =/  =filter:nsur  [~ ~ `kinds ~ `since ~ ~]
  =/  sub-id  (gen-sub-id:nostr-keys eny.bowl)
  =/  req=client-msg:nsur  [%req sub-id ~[filter]]
  :-  :~  (send relay-url req)  ==  state

++  send
  |=  [relay-url=@t req=client-msg:nsur]  ^-  card:agent:gall
    ~&  >>>  sendws=relay-url
    =/  req-body=json  (req:en:js req)
    =/  octs  (json-to-octs:server req-body)
    =/  wmsg=websocket-message:eyre  [1 `octs]
    ~&  >>  sup=sup.bowl
    =/  conn  (check-connected:ws relay-url bowl)
    ~&  >>>  send-client-conn=conn
    ?~  conn  :: if no ws connection we start a thread which will connect first, then send the message
    !!
    :: =/  =task:iris  [%websocket-connect dap.bowl relay-url]
    :: [%pass /ws-req/nostrill %arvo %i task]
    ::
    (give-ws-payload-client:ws wid.u.conn wmsg)
--
