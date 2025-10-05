/-  sur=nostr
/+  common=json-common, sr=sortug
|%
++  en
=,  enjs:format  
  |%
  ::  shim comms
  ++  bulk-req  |=  [relays=(list @t) r=req:shim:sur]  ^-  json
    %+  frond  %ws
    %:  pairs
      relays+a+(turn relays cord:en:common)
      req+(req r)
    ~
    ==
  ++  http-req  |=  [relay=@t delay=@ud sub-id=@t fs=(list filter:sur)]
    %+  frond  %http
    %:  pairs
      relay+s+relay
      delay+(numb delay)
      ['subscription_id' %s sub-id]
      filters+a+(turn fs filter)
    ~
    ==
  ++  req  |=  =req:shim:sur  ^-  json
    =/  en-ev  event
    :-  %a  :-  s+(crip (cuss (trip -.req)))
    ?-  -.req
      %req    (enreq +.req)
      %event  :_  ~  (en-ev(nostr .y) +.req)
      %auth   :_  ~  (en-ev(nostr .y) +.req)
      %close  :_  ~  [%s +.req]
    ==
++  enreq
  |=  [sub-id=@t fs=(list filter:sur)]
  ^-  (list json)
  :-  [%s sub-id]
  %+  turn  fs  filter
  
    ::
  ++  raw-event  |=  raw-event:sur
  :: WTF nostr doesn't want the prefix on the pubkey
    :: =/  scw  scow:sr
    :: =/  pubkeyt  (scw(min-chars 64) %ux pubkey)
    =/  pubkeyt  (scow:sr %ux pubkey)
    ?~  pubkeyt  !!
    =/  pubkeyj  [%s (crip t.pubkeyt)]
    :: =/  pubkeyj  [%s (crip pubkeyt)]
    :-  %a  :~
      [%n '0']
      pubkeyj  
      (numb created-at)
      (numb kind)
      a+(turn tags tag)
      s+content
    ==
  ++  event
  =/  nostr=?  .n
  |=  e=event:sur  ^-  json
    =/  pubkey  ?.  nostr
        (hex:en:common pubkey.e)
      =/  pubkeyt  (scow:sr %ux pubkey.e)
      ?~  pubkeyt  !!
      [%s (crip t.pubkeyt)]
    %:  pairs
      id+(hex:en:common id.e)
      pubkey+pubkey
      sig+(hex:en:common sig.e)
      ['created_at' (numb created-at.e)]
      kind+(numb kind.e)
      content+s+content.e
      tags+a+(turn tags.e tag)
    ~
    ==
  ++  tag
  |=  t=tag:sur  ^-  json  [%a (turn t cord:en:common)]
    :: :-  s+key.t
    :: :-  s+value.t
    :: (turn rest.t |=(tt=@t s+tt))
    :: 
  ++  filter
  |=  f=filter:sur  ^-  json
    =|  l=(list [key=@t jon=json])
    =.  l  ?~  ids.f      l  :_  l  ['ids' %a (turn ~(tap in u.ids.f) hex:en:common)]
    =.  l  ?~  authors.f  l  :_  l  ['authors' %a (turn ~(tap in u.authors.f) hex:en:common)]
    =.  l  ?~  kinds.f    l  :_  l  ['kinds' %a (turn ~(tap in u.kinds.f) numb)]
    =.  l  ?~  tags.f     l  %+  weld  l  (tags u.tags.f)

    =.  l  ?~  since.f    l  :_  l  ['since' (sect u.since.f)]
    =.  l  ?~  until.f    l  :_  l  ['until' (sect u.until.f)]
    =.  l  ?~  limit.f    l  :_  l  ['limit' (numb u.limit.f)]
    ::
    %-  pairs  l


  ++  tags
  |=  tm=(map @t (set @t))  ^-  (list [@t json])  ::  entries to the filter obeject
    %+  turn  ~(tap by tm)    |=  [key=@t values=(set @t)]
      =/  nkey  (cat 3 '#' key)
      [nkey %a (turn ~(tap in values) cord:en:common)]

  ++  user-meta
  |=  meta=user-meta:sur
    %:  pairs
        name+s+name.meta
        picture+s+picture.meta
        about+s+about.meta
        other+o+other.meta
        ~
    ==
  --
++  de
=,  dejs-soft:format
  |%
    :: shim
  ++  shim-res
    %-  of  :~
      http+(ar relay-msg)
      ws+msg
    ==    
  ++  msg
    %-  ot  :~
      relay+so
      msg+relay-msg
    ==
  ++  relay-msg
    %-  of  :~
      event+event-sub
      ok+relay-ok
      eose+so
      closed+closed
      notice+so
      error+so
    ==

    
    :: | { event: { subscription_id: string; event: NostrEvent } }
    :: | { ok: { event_id: string; accepted: boolean; message: string } }
    :: | { eose: string }
    :: | { closed: { subscription_id: string; message: string } }
    :: | { notice: string }
    :: // this is ours
    :: | { error: string };
  ++  event-sub
    %-  ot  :~
      ['subscription_id' so]
      event+event
    ==
  ++  relay-ok
    %-  ot  :~
      ['event_id' hex:de:common]
      accepted+bo
      message+so
    ==
  ++  closed
    %-  ot  :~
      ['subscription_id' so]
      message+so
    ==
  ++  event
    %-  ot  :~
      id+hex:de:common
      pubkey+hex:de:common
      ['created_at' ni]
      kind+ni
      tags+(ar (ar so))
      content+so
      sig+hex:de:common
    ==
  ++  user-meta  |=  jon=json
    ^-  (unit user-meta:sur)
    ?.  ?=(%o -.jon)  ~
    =|  um=user-meta:sur
    =/  fields  ~(tap by p.jon)
    |-  ?~  fields  (some um)
      =/  k  -.i.fields
      =/  jn=json  +.i.fields
      ?+  k
        =/  ot  (~(put by other.um) k jn)
        =.  um  um(other ot)  $(fields t.fields)
      %'name'             
        =/  crd  (so jn)
        ?~  crd  $(fields t.fields)  $(fields t.fields, um um(name u.crd))
      %'display_name'
        =/  crd  (so jn)
        ?~  crd  $(fields t.fields)  $(fields t.fields, um um(name u.crd))
      %'displayName'
        =/  crd  (so jn)
        ?~  crd  $(fields t.fields)  $(fields t.fields, um um(name u.crd))
      %'about'
        =/  crd  (so jn)
        ?~  crd  $(fields t.fields)  $(fields t.fields, um um(picture u.crd))
      %'picture'
        =/  crd  (so jn)
        ?~  crd  $(fields t.fields)  $(fields t.fields, um um(picture u.crd))
      ==
  --
--
