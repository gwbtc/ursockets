/-  sur=nostrill, nsur=nostr
/+  js=json-nostr, sr=sortug, seq, nostr-keys, constants, server, ws=websockets
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

++  get-relay
  =/  rls  ~(tap by relays.state)  ^-  [@ud relay-stats:nsur]
  ?~  rls  !!
  :: TODO not how this should work
  =/  wid  -.i.rls
  =/  rs=relay-stats:nsur  +.i.rls
  [wid rs]

++  close-sub  |=  [sub-id=@t wid=@ud relay=relay-stats:nsur]
  ^-  (quip card _state)
  =.  reqs.relay  (~(del by reqs.relay) sub-id)
  =.  relays.state  (~(put by relays.state) wid relay)
  =/  req=client-msg:nsur  [%close sub-id]
  =/  rl  get-relay
  =/  relay  +.rl
  =/  url  url.relay
  :-  :~  (send url req)  ==  state

++  send-req  |=  [fs=(list filter:nsur) ongoing=? chunked=(list filter:nsur)]
    ^-  (quip card _state)
    =/  sub-id  (gen-sub-id:nostr-keys eny.bowl)
    =/  req=client-msg:nsur  [%req sub-id fs]
    =/  es=event-stats:nsur  [fs 0 ongoing chunked]  
    =/  rl  get-relay
    =/  wid  -.rl
    =/  relay  +.rl
    =/  url  url.relay
    =.  reqs.relay    (~(put by reqs.relay) sub-id es)
    =.  relays.state  (~(put by relays.state) wid relay)
    ~&  >  sending-ws-req=sub-id
    :-  :~  (send url req)  ==  state


++  get-posts
  ^-  (quip card _state)
  =/  kinds  (silt ~[1])
  :: =/  last-week  (sub now.bowl ~d7)
  =/  last-week  (sub now.bowl ~m2)
  :: =/  since  (to-unix-secs:jikan:sr last-week)
  =/  =filter:nsur  [~ ~ `kinds ~ `last-week ~ ~]
  (send-req ~[filter] .y ~)

++  get-user-feed
  |=  pubkey=@ux
  ^-  (quip card _state)
  =/  kinds  (silt ~[1])
  :: =/  since  (to-unix-secs:jikan:sr last-week)
  =/  pubkeys  (silt ~[pubkey])
  =/  =filter:nsur  [~ `pubkeys `kinds ~ ~ ~ ~]
  (send-req ~[filter] .y ~)

++  get-profiles
    ^-  (quip card _state)
    =/  npoasts  (tap:norm:sur nostr-feed.state)
    =|  missing-profs=(set @ux)
    =/  pubkeys=(set @ux)
      |-  ?~  npoasts  missing-profs
        =/  poast=event:nsur  +.i.npoasts
        =/  have  (~(has by profiles.state) [%nostr pubkey.poast])
        =.  missing-profs  ?:  have  missing-profs  (~(put in missing-profs) pubkey.poast)
      $(npoasts t.npoasts)
    =/  kinds  (silt ~[0])
    ?.  (gth ~(wyt in pubkeys) 300)
      =/  =filter:nsur  [~ `pubkeys `kinds ~ ~ ~ ~]
      (send-req ~[filter] .n ~)
      ::
      =/  chunks=(list (list @ux))  (chunk-by-size:seq ~(tap in pubkeys) 300)
      ?~  chunks  ~&  >>>  "error chunking pubkeys"  `state
      =/  queue=(list filter:nsur)
        %+  turn  t.chunks  |=  l=(list @ux)  ^-  filter:nsur
        =/  pubkeys=(set @ux)  (silt l)
        [~ `pubkeys `kinds ~ ~ ~ ~]
      =/  pubkeys=(set @ux)  (silt i.chunks)
      =/  =filter:nsur  [~ `pubkeys `kinds ~ ~ ~ ~]
      (send-req ~[filter] .n queue)


++  get-engagement
  |=  post-ids=(set @ux)
    ^-  (quip card _state)
    =/  post-strings  %-  ~(run in post-ids)  |=  id=@ux  (crip (scow:sr %ux id))
    =/  =filter:nsur
      =/  kinds  (silt ~[6 7])
      =/  tags  (malt :~([%e post-strings]))
      [~ ~ `kinds `tags ~ ~ ~]
  (send-req ~[filter] .y ~)

++  get-quotes
  |=  post-id=@ux
  ^-  (quip card _state)
    =/  post-string  (crip (scow:sr %ux post-id))
    =/  kinds  (silt ~[1])
    =/  tags  (malt :~([%q (silt ~[post-string])]))
    =/  =filter:nsur  [~ ~ `kinds `tags ~ ~ ~]
  (send-req ~[filter] .y ~)

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
  |=  [relay-url=@t req=client-msg:nsur]  ^-  card
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
