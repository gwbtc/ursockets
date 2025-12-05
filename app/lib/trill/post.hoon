/-  tp=trill-post, md=markdown
/+  sr=sortug, mdlib=markdown
|%

++  get-ref
  |=  p=post:tp
  ^-  (unit [ship @da])
  =/  refs=(list block:tp)
    %-  zing
    %+  turn  (tap:corm:tp contents.p)
    |=  [t=time cl=content-list:tp]
    %+  skim  cl
    |=(b=block:tp =(%ref -.b)) 
  ?~  refs  ~
  =/  ref  (head refs)
  ?.  ?=([%ref @ ship=@ path=*] ref)  ~
  ?~  ref-id=(slaw:sr %ud (head path.ref))  ~
  `[ship.ref u.ref-id]

++  build-sp
  |=  [host=@p author=@p input=@t parent=(unit @) thread=(unit @)]
  ^-  sent-post:tp
  =/  cl  (tokenise input)
  ~|  "parsing error!!"
  ?:  ?=(%| -.cl)  !!
  =|  sp=sent-post:tp
  %=  sp
    host      host
    author    author
    contents  +.cl
    parent    parent
    thread    thread
  ==
++  build-post
  |=  [now=@da pubkey=@ux sp=sent-post:tp]
  ^-  post:tp
  =/  cm  (init-content-map contents.sp now)
  =/  thread  ?~  thread.sp  now  u.thread.sp
  =/  =post:tp
    :*  id=now
        host.sp
        author.sp
        thread
        parent.sp
        ~
        cm
        read.sp
        write.sp
        *engagement:tp
        `@uvH`pubkey
        *signature:tp
        ~
    ==
  post
:: new! using wispem's lib
++  tokenise
|=  t=@t  ^-  (each content-list:tp @t)
  =/  parsed  (rush t markdown:de:md:mdlib)
  ?~  parsed  [%| 'parsing error']
  :-  %&
  %+  turn  u.parsed  de-node  
++  de-node  |=  =node:markdown:md  ^-  block:tp
  ?~  node  [%paragraph ~]
  ?-  -.node
    %leaf       (de-leaf +.node)
    %container  (de-cont +.node)
  ==

++  de-leaf  |=  =node:leaf:markdown:md  ^-  block:tp
  ?~  node  [%paragraph ~]
  ?-  -.node
    %heading              (de-heading node)
    %break                [%paragraph :~([%break ~])]
    %indent-codeblock     [%codeblock text.node '']
    %fenced-codeblock     [%codeblock text.node info-string.node]
    %html                 [%codeblock text.node 'html']
    %link-ref-definition  [%paragraph :~([%link '' label.node])]
    %paragraph            [%paragraph (de-inline contents.node)]
    %blank-line           [%paragraph :~([%break ~])]
    %table                [%paragraph :~([%break ~])]  :: TODO
  ==
++  de-heading  |=  h=heading:leaf:markdown:md
  :+  %heading  (flatten-inline contents.h)
  ?:  .=(1 level.h)  %h1
  ?:  .=(2 level.h)  %h2
  ?:  .=(3 level.h)  %h3
  ?:  .=(4 level.h)  %h4
  ?:  .=(5 level.h)  %h5  %h6
++  de-inline  |=  inls=contents:inline:md
  =|  res=(list inline:tp)
  |-  ?~  inls  (flop res)
    =/  inl  i.inls
    =/  r=inline:tp  ?-  -.inl
      %escape           [%codespan char.inl]
      %entity           [%codespan code.inl]
      %code-span        [%codespan text.inl]
      %line-break       [%break ~]
      %soft-line-break  [%break ~]
      %text             [%text text.inl]
      %emphasis         (de-strong +.inl)
      %strong           (de-strong +.inl)
      %link             [%link (de-target target.inl) (flatten-inline contents.inl)]
      %image            [%link (de-target target.inl) (de-target target.inl)]
      :: %image            [%img (de-target target.inl) alt-text.inl]
      %autolink         [%text '']
      %html             [%codespan text.inl]
    ==
    $(inls t.inls, res [r res])
++  de-strong  |=  [char=@t inls=contents:inline:md]
?:  .=('_' char)  [%italic (flatten-inline inls)]
                  [%bold (flatten-inline inls)]
++  de-target  |=  tar=target:ln:md
:: TODO lotsa stuff here
  ?-  -.tar
    %direct  text.url.urlt.tar
    %ref     label.tar
  ==
++  flatten-inline  |=  inls=contents:inline:md  ^-  @t
  =/  res  ""
  |-  ?~  inls  (crip res)
    =/  inl  i.inls
    =/  r  ?+  -.inl  ""
      %escape           (trip char.inl)
      %entity           (trip code.inl)
      %code-span        (trip text.inl)
      %text             (trip text.inl)
      %emphasis         (trip (flatten-inline contents.inl))
      %strong           (trip (flatten-inline contents.inl))
      %link             (trip (flatten-inline contents.inl))
      %image            (trip (de-target target.inl))
      %html             (trip text.inl)
    ==
    $(inls t.inls, res "{res} {r}")
++  de-cont  |=  =node:container:markdown:md  ^-  block:tp
  ?~  node  [%paragraph ~]
  ?-  -.node
    %block-quote  [%blockquote (denest +.node)]
    %ol           [%list (de-list contents.node) .y]
    %ul           [%list (de-list contents.node) .n]
    %tl  [%paragraph ~]
  ==
++  de-list  |=  lmd=(list markdown:md)  ^-  (list inline:tp)
:: TODO
~
  :: =|  res=(list li:tp)
  :: |-  ?~  lmd  (flop res)
  ::   =/  nodelist  i.lmd
  ::   =/  blocks=(list block:tp)
  ::     %+  turn  nodelist  de-node
  ::   $(lmd t.lmd, res [blocks res])
    
++  denest  |=  mde=markdown:md  ^-  paragraph:tp
  =|  res=paragraph:tp
  |-  ?~  mde  (flop res)
    =/  block  (de-node i.mde)
    =/  r=paragraph:tp  (break-block block)
    =/  nr  (weld res r)
    $(mde t.mde, res nr)

++  break-block  |=  =block:tp  ^-  paragraph:tp
?+  -.block  ~
  %paragraph   p.block
  %blockquote  p.block
  %heading     :~([%text p.block])
  %codeblock   :~([%text code.block])
  %eval        :~([%text hoon.block])
  :: %list        (break-list p.block)
==
++  break-list  |=  lis=(list li:tp)  ^-  paragraph:tp
  =|  res=paragraph:tp
  |-  ?~  lis  (flop res)
    =/  par  (ibreak-list i.lis)
    =/  nr  (weld res par)
    $(lis t.lis, res nr)
++  ibreak-list  |=  blocks=(list block:tp)  ^-  paragraph:tp
  =|  res=paragraph:tp
  |-  ?~  blocks  (flop res)
    =/  par  (break-block i.blocks)
    =/  nr  (weld res par)
    $(blocks t.blocks, res nr)

::  tape -> post:trill, parsing user input from Sail
+$  heading  $?(%h1 %h2 %h3 %h4 %h5 %h6)

++  parse  :: Markdown parser. Actually udon parser but it'll do
  |=  s=tape  ^-  (unit marl:hoot) :: finally
  :: Annoying it requires a line break but then parses it as a space wtf
  =,  vast
  (rust s cram:(sail .y))
++  tokenize  
|=  s=@t  ^-  content-list:tp
  =/  t  (weld (trip s) "\0a")
  =/  parsed  (parse t)
  :: =/  parsed2  (parse:md t)
  :: ~&  >    diary-parser=parsed2
  ::  \0a can't be followed by a space. ever. those are the rules
  ?~  parsed  ~&  error-parsing-markdown=t  ~
  (marl-to-cl u.parsed)
++  marl-to-cl
|=  =marl:hoot  ^-  content-list:tp
  %-  flop
  %+  roll  marl
  |=  [=tuna:hoot acc=content-list:tp]
  :: man this is an annoying type if I ever saw one
  ?@  -.tuna  acc
  =/  blk  (manx-to-block tuna)
  ?~  blk  acc  :_  acc  u.blk
++  manx-to-block
  |=  =manx:hoot  ^-  (unit block:tp)
  ?+  n.g.manx  ~
  :: TODO
  :: heading      %-  some   [%heading (phead n.g.manx c.manx)]
  %p           %-  some   [%paragraph (inline-list c.manx)]
  %blockquote  %-  some   [%blockquote (inline-list c.manx)]
  %pre         %-  some   [%codeblock (pre c.manx)]
  %hr          %-  some   [%paragraph ~[[%break ~]]]
  %ul          %-  some   [%list (inline-list c.manx) .n]
  %ol          %-  some   [%list (inline-list c.manx) .y]
  :: %table       %-  some   (table-rows c.manx)
  ==
:: ++  list-items
:: |=  =marl:hoot  ^-  (list li:tp)
:: %-  flop
::   %+  roll  marl  |=  [=tuna:hoot acc=(list li:tp)]
::   ?@  -.tuna  acc
::   ?.  ?=(%li n.g.tuna)  acc  :_  acc  (marl-to-cl c.tuna)
::   ++  phead
::   |=  [h=heading c=marl:hoot]  ^-  [p=cord q=heading]
::   :-  (get-tag-text c)  h
++  inline-list
  |=  c=marl:hoot  ^-  (list inline:tp)
  %-  flop
  %+  roll  c
  |=  [=tuna:hoot acc=(list inline:tp)]
  ?@  -.tuna  acc  :_  acc  (inline tuna)
  ++  inline
  |=  =manx:hoot  ^-  inline:tp
  ?:  ?=(%$ n.g.manx)  [%text (get-attrs-text a.g.manx)]
  =/  text=@t  (get-tag-text c.manx)
  ?+  n.g.manx  [%text text]
  %i     [%italic text]
  %b     [%bold text]
  %code  [%codespan text]
  %br    [%break ~]
  %a    :+  %link  (get-attrs-text a.g.manx)  (get-tag-text c.manx)
  %img  :+  %link  (get-attr-text a.g.manx %src)  (get-attr-text a.g.manx %alt)
  ==
::
++  reduce-block
|=  c=marl:hoot  ^-  @t
  %+  roll  c
  |=  [=tuna:hoot acc=@t]
  ?@  -.tuna  acc
  ?+  n.g.tuna  acc
  %p  (get-tag-text c.tuna)
  ==
++  get-attr-text
|=  [a=mart:hoot attr=@tas]  ^-  @t
  %-  crip  %-  flop
  %+  roll  a
  |=  [[n=mane v=(list beer:hoot)] acc=tape]
  ?.  .=(attr n)  acc
  %+  roll  v
  |=  [b=beer:hoot acc=tape]
  ?^  b  acc  [b acc]
++  get-attrs-text  :: this assumes we don't care about which attr, which we usually don't
|=  a=mart:hoot  ^-  @t
  :: ?:  (gte (lent a) 1)  
  %-  crip  %-  flop
  %+  roll  a
  |=  [[n=mane v=(list beer:hoot)] acc=tape]
  %+  roll  v
  |=  [b=beer:hoot acc=tape]
  ?^  b  acc  [b acc]
++  get-tag-text
|=  c=marl:hoot  ^-  @t
::  there's only really one child in these things
  %+  roll  c
  |=  [=tuna:hoot acc=@t]
  ?@  -.tuna  acc
  %-  crip
  %-  flop
  %+  roll  a.g.tuna
  |=  [[n=mane v=(list beer:hoot)] acc=tape]
  %+  roll  v
  |=  [b=beer:hoot acc=tape]
  ?^  b  acc  [b acc]

++  pre
  |=  c=marl:hoot  ^-  [cord cord]
  :_  ''  :: lang not supported, duh
  %+  roll  c
  |=  [=tuna:hoot acc=@t]
  ?@  -.tuna  acc
  (get-attrs-text a.g.tuna)

++  parse-tags
|=  t=@t  ^-  (unit (set @t))
  =/  lst  (rush t (csplit:sr com))
  ?~  lst  ~  (some (sy u.lst))
:: post:trill -> (markdown) tape for display on sail
++  block-to-md
|=  b=block:tp  ^-  tape
  ?+  -.b  ""
%paragraph    
  %^  foldi:sr  p.b  ""  |=  [in=@ud i=inline:tp acc=tape]
    =/  il  (inline-to-tape i)  
    ?:  .=(+(in) (lent p.b))
    "{acc}{il}"
    "{acc}{il} "
%blockquote   
  %+  weld  "> "
  %^  foldi:sr  p.b  ""  |=  [in=@ud i=inline:tp acc=tape]
  =/  il  (inline-to-tape i)  
  ?:  .=(+(in) (lent p.b))
  "{acc}{il}"
  "{acc}{il} "
%list  
  %^  foldi:sr  p.b  ""  |=  [in=@ud i=inline:tp acc=tape]
  =/  li-tape  (inline-to-tape i)
  =/  line  ?:  ordered.b  
  "{<+(in)>}. {li-tape}"
  "- {li-tape}"
  ?:  .=(+(in) (lent p.b))
  "{acc}{line}"
  "{acc}{line}\0a"
%media  
  ?+  -.media.b  "![{(trip p.media.b)}]({(trip p.media.b)})"
  :: TODO
%images
  :: %^  foldi:sr  p.media.b  ""  |=  [i=@ud [url=@t caption=@t] acc=tape]
  :: =/  line  "![{(trip caption)}]({(trip url)})"
  :: ?:  .=(+(i) (lent p.media.b))
  :: "{acc}{line}"
  :: "{acc}{line}\0a"
  ""
  ==
%codeblock
  """
  ```
  {(trip code.b)}
  ```
  """
%heading  =/  dashes=tape  ?-  q.b
  %h1  "# "
  %h2  "## "
  %h3  "### "
  %h4  "#### "
  %h5  "##### "
  %h6  "###### "
  ==  "{dashes}{(trip p.b)}"
:: %tasklist  ""  ::TODO
  ::
  :: %table  acc
  :: %eval  acc
  :: %ref   acc
  :: %json  acc
  ==  
++  content-map-to-md  |=  cm=content-map:tp  ^-  tape
  =/  latest  (latest-post-content cm)
  (content-list-to-md latest)

++  latest-post-content
|=  cm=content-map:tp  ^-  content-list:tp
  =/  last  (pry:corm:tp cm)
  ?~  last  ~
  +.u.last

++  content-list-to-md
|=  =content-list:tp  ^-  tape
  %^  foldi:sr  content-list  ""  |=  [i=@ud b=block:tp acc=tape]
  =/  block-tape  (block-to-md b)
  ?:  .=(+(i) (lent content-list))
  "{acc}{block-tape}"
  "{acc}{block-tape}\0a\0a"
++  inline-to-tape
|=  i=inline:tp  ^-  tape
  ?+  -.i  ""
  %text  (trip p.i)
  %italic  "_{(trip p.i)}_"
  %bold    "*{(trip p.i)}*" 
  %strike   "~~{(trip p.i)}~~"
  %ship     (scow %p p.i)
  %codespan   "`{(trip p.i)}`"  
  %link   "[{(trip show.i)}]({(trip href.i)})"
  :: %img    "![{(trip alt.i)}]({(trip src.i)})"
  %break  "\0a"
  ==
++  tags-to-tape
|=  t=(set @t)  ^-  tape
  %^  foldi:sr  ~(tap in t)  ""  |=  [i=@ud c=@t acc=tape]
  ?:  .=(+(i) ~(wyt in t))
  "{acc}{(trip c)}"
  "{acc}{(trip c)},"

++  init-content-map  |=  [cl=content-list:tp date=@da]  ^-  content-map:tp
  (put:corm:tp *content-map:tp date cl)

--
