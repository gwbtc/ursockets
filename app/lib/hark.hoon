/-  sur=nostrill, hark, noti=nostrill-noti, comms=nostrill-comms
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
  |=  [n=notif:noti =bowl:gall]  ^-  yarn:hark
  =/  id=@uvH  (sham n)
  =/  var=[(list content:hark) path]
  ?-  -.n
    %prof
      =/  ship  (user-to-atom:lib user.n)
      :-  :~([%ship ship] 'Changed his profile')  /prof/(scot %p ship)
    %req
      =/  ship  (user-to-atom:lib user.n)
      =/  ship-token  [%ship ship]
      ?@  req.n  ::  follow
        ?~  solved.n
          :-  :~  ship-token
                  'tried to follow you. Your decision is pending'
                  'He left the following request message: '
                   msg.n
              ==
              /req/fans/(scot %p ship)/pending
        ::
        ?.  approved.u.solved.n
          :-  :~  ship-token
                  'Tried to follow you but you rejected his request'
              ==
              /req/fans/(scot %p ship)/ng
        ::
          :-  :~  ship-token
                  'Followed you'
              ==
              /req/fans/(scot %p ship)/ok
      ::  begs
      ?@  p.req.n  ::  %feed
        ?~  solved.n
          :-  :~  ship-token
                  'Requested access to your feed. Your decision is pending.'
                  'He left the following request message: '
                   msg.n
              ==
              /req/begs/feed/(scot %p ship)/pending
        ::
          ?.  approved.u.solved.n
            :-  :~  ship-token
                  'Requested access to your feed but you rejected his request'
              ==
              /req/begs/feed/(scot %p ship)/ng
          ::
            :-  :~  ship-token
                  'Requested and was granted one-time access to your feed'
              ==
              /req/begs/feed/(scot %p ship)/ok
      ::  %thread
        =/  ids  (scot %ud `@`+.p.req.n)
        ?~  solved.n
          :-  :~  ship-token
                  'Requested access to your thread with id: '
                  ids
                  'Your decision is pending.'
                  'He left the following request message: '
                   msg.n
              ==
              /req/begs/thread/[ids]/(scot %p ship)/pending
        ::
          ?.  approved.u.solved.n
            :-  :~  ship-token
                    'Requested access to your thread with id: '
                    ids
                    ', but you rejected his request'
                ==
                /req/begs/thread/[ids]/(scot %p ship)/ng
          ::
            :-  :~  ship-token
                    'Requested and was granted one-time access to your thread with id: '
                    ids
                ==
                /req/begs/thread/[ids]/(scot %p ship)/ok

    %res
      =/  ship  (user-to-atom:lib user.n)
      =/  ship-token  [%ship ship]
      ?-  -.res.n
        %fols  
          ?^  +.res.n  ::  approved
            :-  :~  ship-token
                  ' accepted your follow request.'
                ==
                /res/fols/(scot %p ship)/ok
          ::
            :-  :~  ship-token
                  ' rejected your follow request.'
                ==
                /res/fols/(scot %p ship)/ng
        %begs
          ?-  +<.res.n
            %feed
              ?^  +>.res.n
                :-  :~  ship-token
                        ' accepted your request to access his feed'
                    ==
                    /res/begs/feed/(scot %p ship)/ok
              ::
                :-  :~  ship-token
                        ' rejected your request to access his feed'
                    ==
                    /res/begs/feed/(scot %p ship)/ng
            %thread
              =/  ids  (scot %ud `@ud`id.res.n)
              =/  mt=(approval:sur thread-data:comms)  +>+.res.n
              ?^  mt
                :-  :~  ship-token
                        ' accepted your request to access his thread of id:'
                        ids
                    ==
                    /res/begs/thread/[ids]/(scot %p ship)/ok
              ::
                :-  :~  ship-token
                        ' rejected your request to access his thread of id:'
                        ids
                    ==
                    /res/begs/thread/[ids]/(scot %p ship)/ng
            ==
          ==
    %post
      =/  ship  (user-to-atom:lib user.n)
      =/  ship-token  [%ship ship]

      =/  a=engagement:comms  +>+.n
      :: =/  ids  (scot %ud `@`id.pid.n)
      :: =/  hosts  (scot %p ship.pid.n)
      :: =/  pids  %-  spat  /[hosts]/[ids]
      ?-  -.a
        %reply
          =/  host  host.child.a
          =/  parents  (scot %ud `@`parent.a)
          =/  ids    (scot %ud `@`id.child.a)
          =/  hosts  (scot %p host)
          =/  parent-pids  (spat /[hosts]/[parents])
          :-  :~(ship-token 'Replied to post:' parent-pids)     /post/reply/(scot %p ship)/[hosts]/[parents]/[ids]
        %mention
          =/  host  host.post.a
          =/  ids    (scot %ud `@`id.post.a)
          =/  hosts  (scot %p host)
          =/  pids  (spat /[hosts]/[ids])
          :: TODO show some text of the mention
          :-  :~(ship-token 'Mentioned you in post:' pids)     /post/mention/(scot %p ship)/[hosts]/[ids]
        %quote
          =/  host  host.post.a
          =/  parents  (scot %ud `@`src.a)
          =/  ids    (scot %ud `@`id.post.a)
          =/  hosts  (scot %p host)
          =/  parent-pids  (spat /[hosts]/[parents])
          :: TODO show some text of the quote 
          :-  :~([%ship ship] 'Quoted the post:' parent-pids)     /post/quote/(scot %p ship)/[parents]/[hosts]/[ids]
        %rp
          =/  parents  (scot %ud `@`src.a)
          =/  ids    (scot %ud `@`target.a)
          :-  :~([%ship ship] 'Reposted the post:' ids)   /post/rp/(scot %p ship)/[parents]/[ids]
        %reaction
          =/  ids    (scot %ud `@`post.a)
          :-  :~([%ship ship] 'Reacted to post:' ids reaction.a)   /post/react/(scot %p ship)/[ids]
        %del-reply
          =/  parents  (scot %ud `@`parent.a)
          =/  ids    (scot %ud `@`child.a)
          :-  :~([%ship ship] 'Deleted his reply on:' parents)    /post/del-reply/(scot %p ship)/[parents]/[ids]
        %del-parent
          =/  parents  (scot %ud `@`parent.a)
          =/  ids    (scot %ud `@`child.a)
          :-  :~([%ship ship] 'Deleted the parent to the post on:' parents)    /post/del-parent/(scot %p ship)/[parents]/[ids]
        %del-quote
          =/  parents  (scot %ud `@`src.a)
          =/  ids    (scot %ud `@`quote.a)
          :-  :~([%ship ship] 'Deleted his quote of:' parents)    /post/del-quote/(scot %p ship)/[parents]/[ids]
      ==
      %nostr
        ?-  +<.n
          %relay-down
          :-  :~('The relay: ' url.n 'closed the websockets connection. Try to reconnect in the settings page.')
            /nostr/relay-down/[url.n]
          %new-relay
          :-  :~('A new relay has become available: ' url.n 'Try it out some time. You can add it to the settings page.')
            /nostr/new-relay/[url.n]
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
  |=  [n=notif:noti =bowl:gall]  ^-  card:agent:gall
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
