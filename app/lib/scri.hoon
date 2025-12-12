/-  sur=nostrill, nsur=nostr, comms=nostrill-comms,
    post=trill-post, gate=trill-gate, feed=trill-feed
/+  appjs=json-nostrill,
    trilljs=json-trill,
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
  %-  res:en:appjs
  ^-  res:comms
  =/  host  (slaw %p hs)
  ?~  host
    =/  msg  'Host is not a @p'  [%thread `@da`0 msg %done %ng]
  :: TODO what about non urbit stuff
  =/  =user:sur  [%urbit u.host]
  =/  fed=(unit feed:feed)
    ?:  .=(u.host our.bowl)  `feed.state  (~(get by following.state) user)
  ?~  fed
    =/  msg  'Feed not found'
        [%thread `@da`0 msg %done %ng]
  =/  id  (slaw:sr %ud ids)  ?~  id
    =/  msg  'Post ID malformed'
    [%thread `@da`0 msg %done %ng]
  =/  node  (get:orm:feed u.fed u.id)
  ?~  node
    =/  msg  'Post not found in feed'
        [%thread u.id msg %done %ng]
  =/  fn   (node-to-full:feedlib u.node u.fed)
  =/  ted  (extract-thread:feedlib fn)
  =/  msg  ''  [%thread u.id msg %done %ok fn ted]

++  sfeed  |=  [hs=@t s=@t e=@t c=@ n=@ r=@]
  ^-  (unit (unit cage))  :-  ~  :-  ~  :-  %json  !>
  %-  res:en:appjs
  ^-  res:comms
  =/  host  (slaw %p hs)
  ?~  host
    =/  msg  'Host is not a @p'
        [%feed msg %done %ng]
  =/  =user:sur  [%urbit u.host]
  =/  fed=(unit feed:feed)  ?:  .=(u.host our.bowl)  `feed.state  (~(get by following.state) user)
  ?~  fed
  =/  msg  'Feed not found'
        [%feed msg %done %ng]
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
  =/  msg  ''  [%feed msg %done %ok fc profile]
::
++  feed-ids
  |=  hs=@ta
  ^-  (unit (unit cage))
  :^  ~  ~  %noun  
  !>
  =/  host=(unit @p)  (slaw %p hs)
  ?~  host  ~
  =/  fed=(unit feed:feed)
    ?:  =(u.host our.bowl)  `feed.state  
    (~(get by following.state) urbit+u.host)
  ?~  fed  ~
  %-  sort  :_  gth
  %+  turn  (tap:orm:feed u.fed)
  |=([key=@da val=*] key)
::
++  host-feed
  |=  hs=@ta
  ^-  (unit (unit cage))
  :^  ~  ~  %json
  !>
  =/  host=(unit @p)  (slaw %p hs)
  ?~  host  ~
  =/  fed=(unit feed:feed)  
    ?:  .=(u.host our.bowl)  `feed.state  
    (~(get by following.state) urbit+u.host)
  ?~  fed  *json
  (feed:en:trilljs u.fed)
::
--
