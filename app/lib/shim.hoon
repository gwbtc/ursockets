/-  sur=nostrill, nsur=nostr
/+  js=json-nostr, sr=sortug, nostr-keys, constants
/=  web  /web/router
|_  [=state:sur =bowl:gall]

+$  card  card:agent:gall
++  parse-msg
  |=  [eyre-id=@ta req=inbound-request:eyre]
  ^-  (unit res:shim:nsur)
  ?~  body.request.req  ~
  =/  jstring  q.u.body.request.req
  (parse-body jstring)
++  parse-body  |=  jstring=@t
  =/  ures  (de:json:html jstring)
  ?~  ures  ~
  =/  ur  (shim-res:de:js u.ures)
  ?~  ur  ~&  >>>  shim-msg-parsing-failed=jstring  ~
  ur
:: __
++  get-req  |=  fs=(list filter:nsur)
    ^-  [bulk-req:shim:nsur _state]
    =/  rls  ~(tap by relays.state)
    =|  urls=(list @t)
    =/  sub-id  (gen-sub-id:nostr-keys eny.bowl)
    =/  req=client-msg:nsur  [%req sub-id fs]
    |-  ?~  rls  [[urls req] state]
      ::  build http card
      =/  [url=@t rs=relay-stats:nsur]  i.rls
      ::  mutate relays stats
      =/  es=event-stats:nsur  [fs 0]  
      =/  nreqs  (~(put by reqs.rs) sub-id es)
      =/  nrs  rs(reqs nreqs)
      =.  relays.state  (~(put by relays.state) url nrs)
      $(urls [url urls], rls t.rls)

++  get-posts
  ^-  (quip card _state)
  =/  kinds  (silt ~[1])
  =/  last-week  (sub now.bowl ~d7)
  :: =/  since  (to-unix-secs:jikan:sr last-week)
  =/  =filter:nsur  [~ ~ `kinds ~ `last-week ~ ~]
  =^  req=bulk-req:shim:nsur  state  (get-req ~[filter])
  :-  :~((send req))  state

++  get-user-feed
  |=  pubkey=@ux
  ^-  (quip card _state)
  =/  kinds  (silt ~[1])
  :: =/  since  (to-unix-secs:jikan:sr last-week)
  =/  pubkeys  (silt ~[pubkey])
  =/  =filter:nsur  [~ `pubkeys `kinds ~ ~ ~ ~]
  =^  req=bulk-req:shim:nsur  state  (get-req ~[filter])
  :-  :~((send req))  state

++  get-profiles
  |=  pubkeys=(set @ux)
    ^-  (quip card _state)
    =/  kinds  (silt ~[0])
    =/  =filter:nsur  [~ `pubkeys `kinds ~ ~ ~ ~]
    =^  req=bulk-req:shim:nsur  state  (get-req ~[filter])
    :-  :~((send req))  state

++  get-engagement
  |=  post-ids=(set @ux)
    ^-  (quip card _state)
    =/  post-strings  %-  ~(run in post-ids)  |=  id=@ux  (crip (scow:sr %ux id))
    =/  =filter:nsur
      =/  kinds  (silt ~[6 7])
      =/  tags  (malt :~([%e post-strings]))
      [~ ~ `kinds `tags ~ ~ ~]
    =^  req  state  (get-req ~[filter])
    :-  :~((send req))  state

++  get-quotes
  |=  post-id=@ux
  ^-  (quip card _state)
    =/  post-string  (crip (scow:sr %ux post-id))
    =/  kinds  (silt ~[1])
    =/  tags  (malt :~([%q (silt ~[post-string])]))
    =/  =filter:nsur  [~ ~ `kinds `tags ~ ~ ~]
    =^  req  state  (get-req ~[filter])
    :-  :~((send req))  state

    
++  send
  |=  req=bulk-req:shim:nsur  ^-  card:agent:gall
    =/  req-body  (bulk-req:en:js req)
    :: ~&  shim-req-json=(en:json:html req-body)
    =/  host  .^(hart:eyre %e /(scot %p our.bowl)/host/(scot %da now.bowl))
    =/  origin  %-  crip  (head:en-purl:html host)
    =/  headers  :~
      [key='content-type' value='application/json']
      [key='origin' value=origin]
    ==
    =/  =request:http  [%'POST' url:shim:nsur headers `(json-body:web req-body)]
    =/  pat  /shim
    [%pass (weld /ws pat) %arvo %k %fard dap.bowl %fetch %noun !>(request)]  

++  send-http
  |=  req=http-req:shim:nsur
  ^-  card:agent:gall
    =/  req-body  (http-req:en:js req)
    :: ~&  shim-req-json=(en:json:html req-body)
    =/  host  .^(hart:eyre %e /(scot %p our.bowl)/host/(scot %da now.bowl))
    =/  origin  %-  crip  (head:en-purl:html host)
    =/  headers  :~
      [key='content-type' value='application/json']
      [key='origin' value=origin]
    ==
    =/  =request:http  [%'POST' url:shim:nsur headers `(json-body:web req-body)]
    [%pass /http/[sub-id.req] %arvo %k %fard dap.bowl %fetch %noun !>(request)]  
::
:: HTTP
:: 

++  get-profiles-http
  |=  pubkeys=(set @ux)
    ^-  (quip card _state)
    =/  relays  ~(key by relays.state)
    :: TODO make a function to use most reliable
    =/  relay  (head ~(tap in relays))
    ~&  http=relay
    =/  sub-id  (gen-sub-id:nostr-keys eny.bowl)
    =/  kinds  (silt ~[0])
    =/  total=filter:nsur  [~ `pubkeys `kinds ~ ~ ~ ~]
    =/  req=http-req:shim:nsur  [relay http-delay:constants sub-id ~[total]]
    =/  =card  (send-http req)
    :-  :~(card)  state

--
