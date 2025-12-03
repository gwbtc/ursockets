/-  feed=trill-feed, post=trill-post, sur=nostrill
/+  common=json-common, sr=sortug
|%
++  en
=,  enjs:format
  |%
  ++  feed-with-cursor
    |=  [f=feed:^feed start=(unit @da) end=(unit @da)]  ^-  json
    %:  pairs
      feed+(feed f)
      start+(cursor start)
      end+(cursor end)
    ~
    ==
  ++  cursor  |=  c=(unit @da)
    ?~  c  ~  (time u.c)
  ++  feed
    |=  f=feed:^feed  ^-  json
      %-  pairs
      %+  turn  (tap:orm:^feed f)
      |=  [post-id=@da p=post:post]
      ^-  [@ta json]
      :-  (crip (scow:sr %ud `@ud`post-id))
          (poast p)

    ++  branch-user  |=  p=@p  ^-  user:sur
      =/  bitsize  (met 3 p)
      :: TODO surely there's proper verification methods
      ?:  .=(32 bitsize)  [%nostr `@ux`p]  [%urbit p]
    ++  user  |=  u=user:sur  ^-  json
    ?-  -.u
      %urbit  (patp:en:common +.u)
      %nostr  (hex:en:common +.u)
    ==
    ++  poast
    |=  p=post:post  ^-  json
      %-  pairs
      :~  id+(ud:en:common id.p)
          host+(user (branch-user host.p))
          author+(user (branch-user author.p))
          thread+(ud:en:common thread.p)
          parent+?~(parent.p ~ (ud:en:common u.parent.p))
          contents+(content contents.p)
          :: hash+(b64:en:common hash.p)
          hash+(hex:en:common `@ux`hash.p)
          engagement+(engagement engagement.p)
          children+a+(turn ~(tap in children.p) ud:en:common)
          time+(time id.p)
      ==

    ++  content
    |=  cm=content-map:post  ^-  json
      =/  last  (pry:corm:post cm)
      ?~  last  ~
      =/  blocks=content-list:post  +.u.last
      :-  %a  %+  turn  blocks  en-block
      ++  en-block
      |=  b=block:post  ^-  json
      %+  frond  -.b
      ?-  -.b
      %paragraph   a+(turn p.b inline)
      %blockquote  a+(turn p.b inline)
      %table       a+(turn rows.b table-row)
      %heading     (heading +.b)
      %list        (ilist +.b)
      %media       (media media.b)
      %codeblock   (codespan +.b)
      %eval        s+hoon.b
      %ref         (en-ref +.b)
      %json        (external +.b)
      %poll        ~
      ==
    ++  table-row
    |=  l=(list content-list:post)
      :-  %a  %+  turn  l
      |=  b=content-list:post
      :-  %a  %+  turn  b  en-block
      ++  heading
      |=  [p=cord q=@]
      %-  pairs
      :~  text+s+p
          num+(numb q)
      ==
    ++  ilist
    |=  [p=(list inline:post) q=?]
      %-  pairs
      :~  text+a+(turn p inline)
          ordered+b+q
      ==
    ++  media
    |=  =media:post
      %+  frond  -.media
      ?-  -.media
      %images  a+(turn p.media string)
      %video   s+p.media
      %audio   s+p.media
      ==
    ++  string
    |=  c=cord  s+c
      ++  en-ref  :: TODO should the backend fetch this shit
      |=  [type=term s=@p p=^path]
      %-  pairs
      :~  type+s+type
          ship+(patp:en:common s)
          path+(path p)
      ==
    ++  external
    |=  [p=term q=cord]
      %-  pairs
      :~  origin+s+p
          content+s+q
      ==
    ++  inline
    |=  i=inline:post  ^-  json
      %+  frond  -.i
      ?+  -.i    s+p.i
      %ship      (patp:en:common p.i)
      %link      (link +.i)
      %ruby      (ruby +.i)
      %break     ~
      ==
    ++  ruby
    |=  [p=@t q=@t]
      %-  pairs
      :~  text+s+p
          ruby+s+q
      ==
    ++  codespan
    |=  [code=cord lang=cord]
      %-  pairs
      :~  code+s+code
          lang+s+lang
      ==
    ++  link
    |=  [href=cord show=cord]
      %-  pairs
      :~  href+s+href
          show+s+show
      ==

    ++  engagement
    |=  =engagement:post  ^-  json
      %-  pairs
      :~  reacts+(reacts reacts.engagement)
          quoted+a+(turn ~(tap in quoted.engagement) signed-pid)
          shared+a+(turn ~(tap in shared.engagement) signed-pid)
      ==
    ++  reacts
    |=  rs=(map @p [react:post signature:post])
      ^-  json
      %-  pairs
      %+  turn  ~(val by rs)
      |=  [r=react:post s=signature:post]
      ^-  [@ta json]
      :-  (scot %p q.s)
          s+r
    ++  signed-pid
    |=  =signed-pid:post
      ^-  json
      %-  pairs
      :~  ship+(patp:en:common q.signature.signed-pid)
          pid+(pid pid.signed-pid)
      == 
    ++  time-pid
    |=  [t=@da s=@p =id:post]
      %-  pairs
      :~  id+(ud:en:common id)
          ship+(patp:en:common s)
          time+(time t)
      ==
    ++  time-ship
    |=  [t=@da s=@p]  ^-  json
      %-  pairs
      :~  ship+(patp:en:common s)
          time+(time t)
      ==
    ++  mention
    |=  [t=@da s=@p p=pid:post]  ^-  json
      %-  pairs
      :~  pid+(pid p)
          ship+(patp:en:common s)
          time+(time t)
      ==
    ++  react
    |=  [t=@da s=@p p=pid:post react=@t]  ^-  json
    %-  pairs
      :~  pid+(pid p)
          ship+(patp:en:common s)
          react+s+react
          time+(time t)
      ==
    ++  pid
    |=  =pid:post
      %-  pairs
      :~  ship+(patp:en:common ship.pid)
          id+(ud:en:common id.pid)
      ==
    ++  thread
    |=  [p=full-node:post q=(list full-node:post)]  ^-  json
      %-  pairs
      :~  :-  %node    (full-node p)
          :+  %thread  %a  (turn q full-node)
      ==
    ++  full-node
    |=  p=full-node:post  ^-  json
      %-  pairs
      :~  id+(ud:en:common id.p)
          host+(patp:en:common host.p)
          author+(patp:en:common author.p)
          thread+(ud:en:common thread.p)
          parent+?~(parent.p ~ (ud:en:common u.parent.p))
          contents+(content contents.p)
          hash+(b64:en:common hash.p)
          engagement+(engagement engagement.p)
          children+(internal-graph children.p)
          time+(time id.p)
      ==
    ++  internal-graph
    |=  int=internal-graph:post  ^-  json
      ?-  -.int
          %empty  ~
          %full  (full-graph +.int)
      ==
    ++  full-graph
    |=  f=full-graph:post
      ^-  json
      %-  pairs
      %+  turn  (tap:form:post f)
      |=  [post-id=@da fn=full-node:post]
      ^-  [@ta json]
      :-  (crip (scow:sr %ud `@ud`post-id))
          (full-node fn)
    ::
  --
--
