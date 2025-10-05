/-  feed=trill-feed, post=trill-post, sur=nostrill
/+  sr=sortug, constants
|%
++  latest-page
=/  count  feed-page-size:constants
|=  f=feed:feed  ^-  fc:feed
  =/  nodelist  (tap:orm:feed f)
  =/  subset  (scag count nodelist)
  ?~  subset  [f ~ ~]
  =/  start  `-.i.subset
  =/  rev  (flop subset)
  ?~  rev  [f ~ ~]
  =/  end  `-.i.rev
  =/  nf  (gas:orm:feed *feed:feed subset)
  [nf start end]
::
++  latest-page-nostr  |=  f=nostr-feed:sur  ^-  nfc:sur
  =/  nodelist  (tap:norm:sur f)
  =/  subset  (scag feed-page-size:constants nodelist)
  ?~  subset  [f ~ ~]
  =/  start  (some `@da`-.i.subset)
  =/  rev  (flop subset)
  ?~  rev  [f ~ ~]
  =/  end  (some `@da`-.i.rev)
  =/  nf  (gas:norm:sur *nostr-feed:sur subset)
  [nf start end]
:: 
:: NOTE START IS OLD, END IS NEW

++  subset
=/  count  feed-page-size:constants
|=  [=fc:feed replies=? now=@da]  ^-  fc:feed
  ?:  ?&(?=(%~ start.fc) ?=(%~ end.fc))  (latest-page feed.fc)

  =/  start  ?~  start.fc  0    u.start.fc  
  =/  end    ?~  end.fc    now  u.end.fc
  =/  nodelist  (tap:orm:feed feed.fc)

  =/  threads  %+  skim  nodelist 
  |=  [=id:post =post:post]  ^-  ?
  ?.  replies
  ?&
    ?=  %~  parent.post
    (lte id start)  (gte id end)
  ==
  ?&  (lte id start)  (gte id end)  ==
  =/  thread-count  (lent threads)
  :: TODO I remember something was weird about this
  :: =/  result=(list [id:post post:post])  ?:  newest  (scag count threads)  (flop (scag count (flop threads)))
  =/  result=(list [id:post post:post])  (scag count threads)
  =/  cursors=[(unit @da) (unit @da)]  ?~  result  [~ ~]  ?~  threads  [~ ~]  :-
  ?:  .=((head result) (head threads))  ~  `id:(head result)
  ?:  .=((rear result) (rear threads))  ~  `id:(rear result)
  [(gas:orm:feed *feed:feed result) -.cursors +.cursors]
::  posts
++  node-to-full
|=  [p=post:post f=feed:feed]  ^-  full-node:post
  p(children (convert-children children.p f))
++  convert-children
|=  [children=(set id:post) f=feed:feed]
  ^-  internal-graph:post
  =/  g=full-graph:post  %-  ~(rep in children)
    |=  [=id:post acc=full-graph:post]
    =/  n  (get:orm:feed f id)
    ?~  n  acc
    =/  full-node  (node-to-full u.n f)
    (put:form:post acc id full-node)
  ?~  children  [%empty ~]
  :-  %full  g
--
