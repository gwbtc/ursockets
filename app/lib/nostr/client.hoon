/-  sur=nostrill, nsur=nostr
/+  js=json-nostr, sr=sortug, seq, nostr-keys, constants, server, ws=websockets
/=  web  /web/router
|_  [=state:sur =bowl:gall wid=@ud relay=relay-stats:nsur]

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

++  close-sub  |=  [sub-id=@t wid=@ud relay=relay-stats:nsur]
  ^-  (quip card _relay)
  =.  reqs.relay  (~(del by reqs.relay) sub-id)
  =/  req=client-msg:nsur  [%close sub-id]
  :-  :~  (send url.relay req)  ==  relay

++  send-req  |=  [fs=(list filter:nsur) ongoing=(unit ?) chunked=(list filter:nsur)]
    ^-  (quip card _relay)
    =/  sub-id  (gen-sub-id:nostr-keys eny.bowl)
    =/  req=client-msg:nsur  [%req sub-id fs]
    =/  es=event-stats:nsur  [fs 0 ongoing chunked]  
    =/  url  url.relay
    =.  reqs.relay    (~(put by reqs.relay) sub-id es)
    ~&  >  sending-ws-req=sub-id
    :-  :~  (send url req)  ==  relay


++  get-posts
  =/  kinds  (silt ~[1])
  :: =/  last-week  (sub now.bowl ~d7)
  =/  last-week  (sub now.bowl ~m1)
  :: =/  since  (to-unix-secs:jikan:sr last-week)
  =/  =filter:nsur  [~ ~ `kinds ~ `last-week ~ ~]
  (send-req ~[filter] `.n ~)
::
++  get-user-feed
  |=  pubkey=@ux
  =/  kinds  (silt ~[1])
  :: =/  since  (sub now.bowl ~d30)
  =/  since  (sub now.bowl ~d5)
  =/  pubkeys  (silt ~[pubkey])
  =/  =filter:nsur  [~ `pubkeys `kinds ~ `since ~ ~]
  (send-req ~[filter] `.n ~)

++  get-thread  |=  id=@ux
  =/  kinds  (silt ~[1])
  =/  ids  (silt :~(id))
  =/  f1=filter:nsur  [`ids ~ `kinds ~ ~ ~ ~]
  =/  ids=(list @t)  :~((crip (scow:parsing:sr %ux id)))
  =/  tag  ['e' ids]
  =/  tags=(map @t (list @t))  (malt :~(tag))
  =/  f2=filter:nsur  [~ ~ `kinds `tags ~ ~ ~]
  ~&  >>>  getting-thread=[f1 f2]
  (send-req ~[f1 f2] `.n ~)

++  get-post  |=  id=@ux
  =/  kinds  (silt ~[1])
  =/  ids  (silt :~(id))
  =/  =filter:nsur  [`ids ~ `kinds ~ ~ ~ ~]
  (send-req ~[filter] ~ ~)

++  get-replies  |=  id=@ux
  =/  kinds  (silt ~[1])
  =/  ids=(list @t)  :~((crip (scow:parsing:sr %ux id)))
  =/  tag  ['e' ids]
  =/  tags=(map @t (list @t))  (malt :~(tag))
  =/  =filter:nsur  [~ ~ `kinds `tags ~ ~ ~]
  (send-req ~[filter] `.n ~)
::
++  get-profile  |=  pubkey=@ux
  =/  kinds  (silt ~[0])
  :: =/  since  (to-unix-secs:jikan:sr last-week)
  =/  pubkeys  (silt ~[pubkey])
  =/  =filter:nsur  [~ `pubkeys `kinds ~ ~ ~ ~]
  (send-req ~[filter] ~ ~)

++  get-profiles
    ~&  >>>  "getting profiles"
    =/  npoasts  (tap:norm:sur nostr-feed.state)
    =|  missing-profs=(set @ux)
    =/  pubkeys=(set @ux)
      |-  ?~  npoasts  missing-profs
        =/  poast=event:nsur  +.i.npoasts
        =/  have  (~(has by profiles.state) [%nostr pubkey.poast])
        =?  missing-profs  !have  (~(put in missing-profs) pubkey.poast)
      $(npoasts t.npoasts)
    =/  kinds  (silt ~[0])
    =/  chunk-size  300
    ~&  >>  fetching-profiles=~(wyt in pubkeys)
    ?.  (gth ~(wyt in pubkeys) chunk-size)
      =/  =filter:nsur  [~ `pubkeys `kinds ~ ~ ~ ~]
      (send-req ~[filter] ~ ~)
      ::
      =/  chunks=(list (list @ux))  (chunk-by-size:seq ~(tap in pubkeys) chunk-size)
      ?~  chunks  ~&  >>>  "error chunking pubkeys"  `relay
      =/  queue=(list filter:nsur)
        %+  turn  t.chunks  |=  l=(list @ux)  ^-  filter:nsur
        =/  pubkeys=(set @ux)  (silt l)
        [~ `pubkeys `kinds ~ ~ ~ ~]
      =/  pubkeys=(set @ux)  (silt i.chunks)
      =/  =filter:nsur  [~ `pubkeys `kinds ~ ~ ~ ~]
      (send-req ~[filter] ~ queue)


++  get-engagement
  |=  post-ids=(set @ux)
    =/  post-strings  %+  turn  ~(tap in post-ids)  |=  id=@ux  (crip (scow:sr %ux id))
    =/  =filter:nsur
      =/  kinds  (silt ~[6 7])
      =/  tags  (malt :~([%e post-strings]))
      [~ ~ `kinds `tags ~ ~ ~]
  (send-req ~[filter] `.n ~)

++  get-quotes
  |=  post-id=@ux
    =/  post-string  (crip (scow:sr %ux post-id))
    =/  kinds  (silt ~[1])
    =/  tags  (malt :~([%q ~[post-string]]))
    =/  =filter:nsur  [~ ~ `kinds `tags ~ ~ ~]
  (send-req ~[filter] `.n ~)

::
++  test-connection
  =/  kinds  (silt ~[1])
  =/  since  (sub now.bowl ~m10)
  =/  =filter:nsur  [~ ~ `kinds ~ `since ~ ~]
  =/  sub-id  (gen-sub-id:nostr-keys eny.bowl)
  =/  req=client-msg:nsur  [%req sub-id ~[filter]]
  :-  :~  (send url.relay req)  ==  relay

++  send
  |=  [relay-url=@t req=client-msg:nsur]  ^-  card
    ~&  >>>  sendws=[relay-url req]
    =/  req-body=json  (req:en:js req)
    =/  octs  (json-to-octs:server req-body)
    =/  wmsg=websocket-message:eyre  [1 `octs]
    =/  conn  (check-connected:ws relay-url bowl)
    ~&  >>>  send-client-conn=conn
    ?~  conn  :: if no ws connection we start a thread which will connect first, then send the message
    ~&  >>>  "no connection!!"
    !!
    :: =/  =task:iris  [%websocket-connect dap.bowl relay-url]
    :: [%pass /ws-req/nostrill %arvo %i task]
    ::
    (give-ws-payload-client:ws wid.u.conn wmsg)

--
