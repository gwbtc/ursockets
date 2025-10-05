/-  tp=post
/+  sr=sortug
|%
++  content
  |=  c=content-list:tp
  ^-  marl
  (turn c block)
::
++  block
  |=  b=block:tp
  ^-  manx
  ?+  -.b  ;p;
    %paragraph   (pg +.b)
    %blockquote  (bq +.b)
    %heading     (heading +.b)
    %list        (htmlist +.b)
    %media       (media +.b)
    %codeblock   (codeblock +.b)
    %eval        (eval +.b)
  ==
++  eval
  |=  txt=@t
  ^-  manx
  ::  +ream can crash if the cord is wrong, so soften instead
  =/  uhoon  (rush txt vest)
  ?~  uhoon  ;p:"The hoon you tried to run ({(trip txt)}) is invalid."
  =/  run  (mule |.((slap !>(..zuse) u.uhoon)))
  ?:  ?=(%.n -.run)  ::  if virtualization fails get a (list tank)
    ;p
    ;span:"Evaluation of {(trip txt)} failed:"
    ;br;
    ;*  %+  turn  p.run  |=  t=tank  ;span:"{~(ram re t)}"
    ==
  ;p:"{(text p.run)}"
++  pg
  |=  l=(list inline:tp)
  ^-  manx
  ;p
  ;*  %+  turn  l  inline
  ==
++  bq
  |=  l=(list inline:tp)
  ^-  manx
  ;blockquote
  ;*  %+  turn  l  inline
  ==
++  htmlist
  |=  [l=(list content-list:tp) ordered=?]
  ?:  ordered
  ;ol
    ;*  %+  turn  l  li
  ==
  ;ul
    ;*  %+  turn  l  li
  ==
++  li
  |=  l=content-list:tp  ^-  manx
  ;li
    ;*  (turn l block)
  ==
++  media
  |=  m=media:tp
  ^-  manx
  ?-  -.m
    %video    ;video@"{(trip p.m)}";
    %audio    ;audio@"{(trip p.m)}";
    %images   ;div.images
                ;*  %+  turn  p.m
                  |=  [url=@t caption=@t]
                  ;img@"{(trip url)}"(alt (trip caption));
                ==
  ==
++  codeblock
  |=  [code=@t lang=@t]  :: TODO lang suff
  ;pre
    ;code:"{(trip code)}"
  ==
++  heading
  |=  [pp=@t q=@]
  ^-  manx
  =/  p  (trip pp)
  ?:  .=(1 q)  ;h1:"{p}"
  ?:  .=(2 q)  ;h2:"{p}"
  ?:  .=(3 q)  ;h3:"{p}"
  ?:  .=(4 q)  ;h4:"{p}"
  ?:  .=(5 q)  ;h5:"{p}"
  ?:  .=(6 q)  ;h6:"{p}"
  ;p:""
++  inline
  |=  l=inline:tp
  ^-  manx
  ?+  -.l  ;span;
    %text      (parse-text p.l)
    %italic    ;i:"{(trip p.l)}"
    %bold      ;strong:"{(trip p.l)}"
    :: %strike    ;del:"{(trip p.l)}"
    %ship      ;span.ship:"{(trip (scot %p p.l))}"
    %codespan  ;code:"{(trip p.l)}"
    %break     ;br;
    %img       ;a/"{(trip src.l)}"
                 ;img@"{(trip src.l)}"(alt (trip alt.l));
               ==
    %link  ?.  (is-image:parsing:sr href.l)      
                ;a/"{(trip href.l)}"(target "_blank"):"{(trip show.l)}"
                ;a/"{(trip href.l)}"
                  =target  "_blank"
                  ;img@"{(trip href.l)}"(alt (trip show.l));
                ==
  ==
++  parse-text
  |=  txt=@t
  ^-  manx
  =/  tpe  (trip txt)
  =/  youtube  (rush txt youtube:parsing:sr)
  ?^  youtube  
  :: ;a/"{tpe}"
  ::   ;img@"https://i.ytimg.com/vi/{u.youtube}/hqdefault.jpg";
  :: ==
  ;iframe.youtube-frame@"https://www.youtube.com/embed/{u.youtube}";
  =/  twatter-status  (rush txt twatter:parsing:sr)
  ?^  twatter-status 
  ;div ::  goddamn twatter embeds insert themselves as last child
    ;a.parsed-twatter(status u.twatter-status):"{tpe}"
  ==
  =/  trimmed  (rush txt trim:parsing:sr)
  ?~  trimmed  ~&  parsing-error=txt  ;span.parsing-error;
  =/  link=(unit purl:eyre)  (rust u.trimmed link:parsing:sr)
  ?^  link
    ?^  p.q.u.link  
      ?:  (is-img:parsing:sr u.p.q.u.link)  ;img@"{u.trimmed}";
      ;a.parsed-link/"{tpe}"(target "_blank"):"{tpe}"  :: normal link
      ;a.parsed-link/"{tpe}"(target "_blank"):"{tpe}"  :: normal link
  ;span:"{tpe}"
--
