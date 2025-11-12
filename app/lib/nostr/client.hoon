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
::       =/  es=event-stats:nsur  [fs 0]  
::       =/  nreqs  (~(put by reqs.rs) sub-id es)
::       =/  nrs  rs(reqs nreqs)
::       =.  relays.state  (~(put by relays.state) url nrs)
::       $(urls [url urls], rls t.rls)

++  send-req  |=  fs=(list filter:nsur)
    ^-  (quip card _state)
    =/  rls  ~(tap by relays.state)
    =/  sub-id  (gen-sub-id:nostr-keys eny.bowl)
    =/  req=client-msg:nsur  [%req sub-id fs]
    =/  rls  ~(tap by relays.state)
    ?~  rls  !!
    =/  url  -.i.rls
    :-  :~  (send url req)  ==  state


++  get-posts
  ^-  (quip card _state)
  =/  kinds  (silt ~[1])
  =/  last-week  (sub now.bowl ~d1)
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
    ~&  >>>  send=relay-url
    =/  req-body=json  (req:en:js req)
    =/  octs  (json-to-octs:server req-body)
    =/  wmsg=websocket-message:eyre  [1 `octs]
    =/  conn  (check-connected:ws relay-url bowl)
    ~&  >>>  send-client-conn=conn
    ?~  conn  :: if no ws connection we start a thread which will connect first, then send the message
    =/  pat  /to-nostr-relay
    [%pass (weld /ws pat) %arvo %k %fard dap.bowl %ws %noun !>([relay-url wmsg])]  
    ::
    (give-ws-payload-client:ws id.u.conn wmsg)
    

:: ++  send-http
::   |=  req=http-req:shim:nsur
::   ^-  card:agent:gall
::     =/  req-body  (http-req:en:js req)
::     :: ~&  shim-req-json=(en:json:html req-body)
::     =/  host  .^(hart:eyre %e /(scot %p our.bowl)/host/(scot %da now.bowl))
::     =/  origin  %-  crip  (head:en-purl:html host)
::     =/  headers  :~
::       [key='content-type' value='application/json']
::       [key='origin' value=origin]
::     ==
::     =/  =request:http  [%'POST' url:shim:nsur headers `(json-body:web req-body)]
::     [%pass /http/[sub-id.req] %arvo %k %fard dap.bowl %fetch %noun !>(request)]  
:: ::
:: :: HTTP
:: :: 

:: ++  get-profiles-http
::   |=  pubkeys=(set @ux)
::     ^-  (quip card _state)
::     =/  relays  ~(key by relays.state)
::     :: TODO make a function to use most reliable
::     =/  relay  (head ~(tap in relays))
::     ~&  http=relay
::     =/  sub-id  (gen-sub-id:nostr-keys eny.bowl)
::     =/  kinds  (silt ~[0])
::     =/  total=filter:nsur  [~ `pubkeys `kinds ~ ~ ~ ~]
::     =/  req=http-req:shim:nsur  [relay http-delay:constants sub-id ~[total]]
::     =/  =card  (send-http req)
::     :-  :~(card)  state

--
