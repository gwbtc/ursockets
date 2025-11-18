/-  sur=nostrill, nsur=nostr, post=trill-post, gate=trill-gate
/+  js=json-nostr, sr=sortug, trill=trill-post, nostr-keys
|%
::  filters
++  is-feed  |=  fs=(list filter:nsur)  ^-  ?
  |-  ?~  fs  .n
    =/  filter  i.fs
    ?~  kinds.filter  .n
      ?:  (~(has in u.kinds.filter) 0)  .n
        ?:  ?&  (~(has in u.kinds.filter) 1)
                ?=(%~ ids.filter)
                ?=(%~ authors.filter)
                ?=(%~ tags.filter)
            ==  .y
    $(fs t.fs)

++  user-req  |=  fs=(list filter:nsur)  ^-  (set @ux)
  =|  pubkeys=(set @ux)
  |-  ?~  fs  pubkeys
    =/  filter  i.fs
    ?~  kinds.filter    ~
    ?~  authors.filter  ~
    ?:  (~(has in u.kinds.filter) 0)  ~
    =?  pubkeys
      ?&  (~(has in u.kinds.filter) 1)
          ?=(%~ ids.filter)
      ==  (~(uni in pubkeys) u.authors.filter)
    $(fs t.fs)
++  posts-req  |=  fs=(list filter:nsur)  ^-  (set @ux)
  =|  ids=(set @ux)
  |-  ?~  fs  ids
    =/  filter  i.fs
    ?~  kinds.filter    ~
    ?~  ids.filter      ~
    =?  ids  (~(has in u.kinds.filter) 1)  (~(uni in ids) u.ids.filter)
    $(fs t.fs)

++  replies-req  |=  fs=(list filter:nsur)  ^-  (set @ux)
  =|  ids=(set @ux)
  |-  ?~  fs  ids
    =/  filter  i.fs
    =/  parent  (replies-filter filter)
    =?  ids  ?=(^ parent)  (~(put in ids) u.parent)
    $(fs t.fs)

++  thread-req  |=  fs=(list filter:nsur)  ^-  (unit @ux)
  =|  parent=(unit @ux)
  |-  ?~  fs  ~
    =/  filter  i.fs
    ?~  parent
      =/  upid  (post-filter filter)
      $(fs t.fs, parent upid)
    =/  replies-parent  (replies-filter i.fs)
    ?:  ?&  ?=(^ replies-parent)
            .=(u.replies-parent u.parent)
        ==  parent
    $(fs t.fs)

++  post-filter  |=  =filter:nsur  ^-  (unit @ux)
  ?~  kinds.filter  ~
  ?~  ids.filter    ~
  =/  post-filter  (silt ~[1])
  ?.  .=(u.kinds.filter post-filter)  ~
  =/  idl  ~(tap in u.ids.filter)
  ?~  idl  ~
  ?.  .=(1 (lent idl))  ~
  `i.idl

++  replies-filter  |=  =filter:nsur  ^-  (unit @ux)
  ?~  kinds.filter  ~
  ?~  tags.filter   ~
  =/  post-filter  (silt ~[1])
  ?.  .=(u.kinds.filter post-filter)  ~
  =/  tag  (~(get by u.tags.filter) 'e')
  ?~  tag    ~
  ?~  u.tag  ~
  =/  reference  (slaw:sr %ux i.u.tag)
  reference

++  is-posts-no-prof  |=  fs=(list filter:nsur)  ^-  ?
  =/  has-posts  .n
  |-  ?~  fs  has-posts
    =/  filter  i.fs
    ?~  kinds.filter  .n
      ?:  (~(has in u.kinds.filter) 0)  .n
      =?  has-posts  (~(has in u.kinds.filter) 1)  .y
    $(fs t.fs)


::  events
++  get-references  |=  ev=event:nsur  ^-  (set @ux)
  =|  ids=(set @ux)
  =/  tags  tags.ev
  |-  ?~  tags  ids
    =/  tag  i.tags
    ?~  tag            $(tags t.tags)
    ?.  .=('e' i.tag)  $(tags t.tags)
    ?~   t.tag         $(tags t.tags)
    =/  ref  (slaw:sr %ux i.t.tag)
    =?  ids  ?=(^ ref)  (~(put in ids) u.ref)
    $(tags t.tags)

++  post-to-event  |=  [=keys:nsur eny=@ p=post:post]  ^-  event:nsur
  =/  cl  (latest-post-content:trill contents.p)
  =/  string  (crip (content-list-to-md:trill cl))
  =/  ts  (to-unix-secs:jikan:sr id.p)
  =/  raw=raw-event:nsur  [pub.keys ts 1 ~ string]
  =/  event-id  (hash-event:nostr-keys raw)
  =/  signature  (sign-event:nostr-keys priv.keys event-id eny)
  ~&  hash-and-signed=[event-id signature]
  =/  =event:nsur  :*
    event-id
    pub.keys
    created-at.raw
    kind.raw
    tags.raw
    content.raw
    signature
    ==
  event

++  event-to-post
  |=  [=event:nsur profile=(unit user-meta:nsur) relay=(unit @t)]
    ^-  post-wrapper:sur

    =/  cl  (tokenize:trill content.event)
    =/  ts  (from-unix:jikan:sr created-at.event)
    =/  cm=content-map:post  (init-content-map:trill cl ts)

   :: TODO more about @ps and stuff
    =/  p=post:post  :*
      id=ts
      host=`@p`pubkey.event
      author=`@p`pubkey.event
      thread=ts
      parent=~
      children=~
      contents=cm
      read=*lock:gate
      write=*lock:gate
      *engagement:post
      0v0
      *signature:post
      tags=~
    ==  
    =/  meta  [(some pubkey.event) (some id.event) relay profile]
    [p meta]
--
