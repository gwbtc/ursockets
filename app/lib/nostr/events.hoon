/-  sur=nostrill, nsur=nostr, post=trill-post, gate=trill-gate
/+  js=json-nostr, sr=sortug, trill=trill-post, nostr-keys
|%
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
