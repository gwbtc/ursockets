/-  sur=nostrill, hark
/+  lib=nostrill
|%
:: |=  =pid:post
:: =/  pu  (~(get by unread) ship.pid)
:: =/  nu  ?~  pu  (~(put in *(set @da)) id.pid)
:: (~(put in u.pu) id.pid)
:: =.  state
:: %=  state
:: unread  (~(put by unread) ship.pid nu)
:: ==
:: :_  this  ui-card^~
:: ++  handle-ui
:: |=  ac=action:ui
:: =.  state
:: ?.  ?=(%hark -.ac)  state
:: =/  a  +.ac
:: ?-  -.a
:: %read-one     (handle-one +.a)
:: %read-range   (handle-range +.a)
:: %read-all     (handle-all +.a)
:: %read-mot     handle-mot
:: %dismiss      (dismiss +.a)
:: %dismiss-all  wipe
:: ==
:: :_  this  ui-card^~
:: ++  dismiss
:: |=  i=@
:: %=  state
::   engagement  (oust [i 1] engagement)
::   archive     [(snag i engagement) archive]
:: ==
:: ++  wipe
:: %=  state
::   engagement  ~
:: ==
:: ++  handle-one
:: |=  =pid:post
:: =/  ship-unread  (~(got by unread) ship.pid)
:: =/  new-unread   (~(del in ship-unread) id.pid)
:: =/  skimmed      (filter-engagement pid)
:: %=  state
::   unread      (~(put by unread) ship.pid new-unread)
::   engagement  -.skimmed
::   archive     (welp +.skimmed archive)
:: ==
:: ++  filter-engagement
:: |=  =pid:post  ^-  [_engagement _engagement]
:: %+  skid  engagement
:: |=  e=engagement:hark  ^-  ?
:: ?+  -.e  %|
:: %reply    =(pid ad.e)
:: %quote    =(pid ad.e)
:: %share    =(pid ad.e)
:: %react    =(pid pid.e)
:: %mention  =(pid pid.e)
:: ==
:: ++  handle-range
:: |=  [ship=@p start=id:post end=id:post]
:: ?.  (lth start end)  state
:: =/  ids  (~(got by unread) ship)
:: =/  range=(list id:post)   %+  skip  ~(tap in ids)
:: |=  =id:post
:: ?&  (gte id start)  (lte id end)  ==
:: =/  new-unread  (~(put by unread) ship (sy range))
:: =/  new-engagement  %+  roll  range  |=  [=id:post acc=(list engagement:hark)]
:: =/  pid  [ship id]
:: %+  skim  engagement  |=  e=engagement:hark
:: ?+  -.e  .n
:: %reply    =(ad.e pid)
:: %quote    =(ad.e pid)
:: %share    =(ad.e pid)
:: %react    =(pid.e pid)
:: %mention  =(pid.e pid)
:: ==
:: %=  state  
:: unread  new-unread  
:: engagement  new-engagement
:: ==
:: ++  handle-all
:: |=  s=@p
:: =/  new-engagement  %+  skim  engagement
:: |=  e=engagement:hark
:: ?+  -.e  .n
:: %reply    =(ship.ad.e s)
:: %quote    =(ship.ad.e s)
:: %share    =(ship.ad.e s)
:: %react    =(ship.pid.e s)
:: %mention  =(ship.pid.e s)
:: ==
:: %=  state  
:: unread      (~(del by unread) s)  
:: engagement  new-engagement
:: == 
:: ++  handle-mot
:: %=  state  
:: unread      ~
:: engagement  ~
:: ==
++  to-hark
  |=  [n=notif:sur =bowl:gall]  ^-  yarn:hark
  =/  id=@uvH  (sham n)
  =/  var=[(list content:hark) path]
  ?-  -.n
    %prof
      =/  user  (user-to-atom:lib user.n)
      :-  :~([%ship user] 'Changed his profile')  /prof/(scot %p user)
    %fans
      =/  user  (user-to-atom:lib user.n)
      ::  TODO  handle if fed not open
      :-  :~([%ship user] 'Followed you')         /fans/(scot %p user)
    %fols
      =/  user  (user-to-atom:lib user.n)
      ::  TODO  handle if fed not open
      =/  res  ?:  accepted.n  'accepted your follow request'  'refused your follow request'
          =/  ok  %+  scot  %ud  ?:  accepted.n  1  0
      :-  :~([%ship user] res msg.n)             /fols/[ok]/(scot %p user)
    %beg-req
      =/  user  (user-to-atom:lib user.n)
      ?-  -.beg.n
        %feed
          :-  :~([%ship user] 'Requested access to your feed' msg.n)       /beg-req/(scot %p user)/feed
        %thread
          =/  ids  (scot %ud `@`id.beg.n)
          :-  :~([%ship user] 'Requested access to your thread of id:' ids msg.n)       /beg-req/(scot %p user)/thread/[ids]
      ==
    %beg-res
      ?-  -.beg.n
        %feed
          =/  user  p.beg.n
          =/  res  ?:  accepted.n  'accepted your request to access his feed'  'refused your request to access his feed'
          =/  ok  %+  scot  %ud  ?:  accepted.n  1  0
          :-  :~([%ship user] res msg.n)            /beg-res/[ok]/feed/(scot %p user)
        %thread
          =/  user  p.beg.n
          =/  res  ?:  accepted.n  'accepted your request to access his thread'  'refused your request to access his thread'
          =/  ids  (scot %ud `@`id.beg.n)
          =/  ok  %+  scot  %ud  ?:  accepted.n  1  0
          :-  :~([%ship user] res 'id:' ids msg.n)  /beg-res/[ok]/thread/(scot %p user)/[ids]
      ==
    %post
      =/  user  (user-to-atom:lib user.n)
      =/  ids  (scot %ud `@`id.pid.n)
      =/  hosts  (scot %p ship.pid.n)
      =/  pids  %-  spat  /[hosts]/[ids]
      ?-  -.action.n
        %reply
          =/  tids  (scot %ud `@`id.p.action.n)
          =/  thosts  (scot %p host.p.action.n)
          :-  :~([%ship user] 'Replied to post:' pids)     /post/reply/(scot %p user)/[hosts]/[ids]/[thosts]/[tids]
        %quote
          =/  tids  (scot %ud `@`id.p.action.n)
          =/  thosts  (scot %p host.p.action.n)
          :-  :~([%ship user] 'Quoted the post:' pids)     /post/quote/(scot %p user)/[hosts]/[ids]/[thosts]/[tids]
        %rp
          :-  :~([%ship user] 'Reposted the post:' pids)   /post/rp/(scot %p user)/[hosts]/[ids]
        %del
          :-  :~([%ship user] 'Deleted the post:' pids)    /post/del/(scot %p user)/[hosts]/[ids]
        %reaction
          :-  :~([%ship user] 'Reacted to post:' pids reaction.action.n)   /post/react/(scot %p user)/[hosts]/[ids]
      ==
  ==
  =/  pat=path  (weld +.var /(scot %da now.bowl))
  =/  =rope:hark    [~ ~ dap.bowl pat]
  [id rope now.bowl -.var pat ~]
::
++  poke-hark
  |=  [=yarn:hark =bowl:gall]  ^-  card:agent:gall
  =/  h=action:hark  [%add-yarn .n .y yarn]
  =/  poke  [%pass /harrk %agent [our.bowl %hark] %poke %hark-action !>(h)]
  poke
::
++  send-hark
  |=  [n=notif:sur =bowl:gall]  ^-  card:agent:gall
  =/  y  (to-hark n bowl)
  (poke-hark y bowl)
:: |=  f=engagement:hark
:: =/  id      (end 7 (shas %trill-hark eny.bowl))
:: =/  pat-id  /[-.f]/(scot %da now.bowl)
:: =/  rope    [~ ~ q.byk.bowl pat-id]
:: =/  body  
:: ?+  -.f  ~
:: %reply  
:: :~([%ship ship.f] ' replied to you on Trill')
:: %quote 
:: :~([%ship ship.f] ' quoted you on Trill')
:: %share  
:: :~([%ship ship.f] ' RT\'d a post of yours on Trill')
:: %mention  
:: :~([%ship ship.f] ' mentioned you on Trill')
:: %react    
:: :~([%ship ship.f] ' reacted to a post of yours on Trill')
:: %follow   
:: :~([%ship ship.f] ' followed you on Trill')
:: %unfollow 
:: :~([%ship ship.f] ' unfollowed you on Trill')
:: ==
:: =/  a  [%add-yarn & & id rope now.bowl body /apps/trill ~]
:: =/  =cage  [%hark-action !>(a)]
:: [%pass /hark %agent [our.bowl %hark] %poke cage]
--
