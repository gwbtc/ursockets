/-  sur=nostrill, nsur=nostr, comms=nostrill-comms,
    post=trill-post, gate=trill-gate, feed=trill-feed
    
/+  appjs=json-nostrill,
    lib=nostrill,
    njs=json-nostr,
    feedlib=trill-feed,
    postlib=trill-post,
    constants,
    sr=sortug

|_  [=state:sur =bowl:gall]
+$  card  card:agent:gall

++  get-poast  |=  [host=@p id=@]  ^-  (unit post:post)
  =/  poast  ?:  .=(host our.bowl)
    (get:orm:feed feed.state id)
    ~
  poast



++  thread  |=  [hs=@t ids=@t]
  ^-  (unit (unit cage))  :-  ~  :-  ~  :-  %json  !>
  %-  beg-res:en:appjs
  ^-  res:comms
  =/  host  (slaw %p hs)
  ?~  host  [%ng 'Host is not a @p']
  :: TODO what about non urbit stuff
  =/  =user:sur  [%urbit u.host]
  =/  fed=(unit feed:feed)  ?:  .=(u.host our.bowl)  `feed.state  (~(get by following.state) user)
  ?~  fed  [%ng 'Feed not found']
  =/  id  (slaw:sr %ud ids)  ?~  id  [%ng 'Post ID malformed']
  =/  node  (get:orm:feed u.fed u.id)
  ?~  node  [%ng 'Post not found in feed']
  =/  fn   (node-to-full:feedlib u.node u.fed)
  =/  ted  (extract-thread:feedlib fn)
  [%ok %thread fn ted]

++  sfeed  |=  [hs=@t s=@t e=@t c=@ n=@ r=@]
  ^-  (unit (unit cage))  :-  ~  :-  ~  :-  %json  !>
  %-  beg-res:en:appjs
  ^-  res:comms
  =/  host  (slaw %p hs)
  ?~  host  [%ng 'Host is not a @p']
  =/  =user:sur  [%urbit u.host]
  =/  fed=(unit feed:feed)  ?:  .=(u.host our.bowl)  `feed.state  (~(get by following.state) user)
  ?~  fed  [%ng 'Feed not found']
  =/  start=(unit @da)  (timestamp:sr s)  
  =/  end               (timestamp:sr e) 
  =/  cont  (slaw:sr %ud c)
  =/  count  ?~  cont  feed-page-size:constants  u.cont
  =/  newest  !=('0' n)
  :: =/  nodelist  (tap:orm:feed u.fed)
  :: =/  replies=?  !=('0' r)
  :: =/  threads  %+  skim  nodelist 
  ::   |=  [=id:post =post:post]  ^-  ?
  ::   ?.  replies
  ::   ?&
  ::     ?=  %~  parent.post
  ::     (lte id start)  (gte id end)
  ::   ==
  ::   ?&  (lte id start)  (gte id end)  ==
  :: =/  thread-count  (lent threads)
  :: =/  result=(list [id:post post:post])  ?:  newest  (scag count threads)  (flop (scag count (flop threads)))
  :: =/  cursors=[(unit @da) (unit @da)]  ?~  result  [~ ~]  ?~  threads  [~ ~]  :-
  :: ?:  .=((head result) (head threads))  ~  `id:(head result)
  :: ?:  .=((rear result) (rear threads))  ~  `id:(rear result)
  :: =/  =fc:feed  [(gas:orm:feed *feed:feed result) -.cursors +.cursors]
  :: TODO counts and order
  =/  nf  (lot:orm:feed u.fed start end)
  =/  hed  (pry:orm:feed nf)
  =/  tal  (ram:orm:feed nf)
  =/  ns=(unit @da)  ?~  hed  ~  (some key.u.hed)
  =/  ne=(unit @da)  ?~  tal  ~  (some key.u.tal)
  =/  =fc:feed  [nf ns ne]
  =/  profile  (~(get by profiles.state) user)
  [%ok %feed fc profile]
--
