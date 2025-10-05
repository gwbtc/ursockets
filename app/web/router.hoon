/-  sur=nostrill
/+  lib=nostrill, sr=sortug
/+  server
::  pages and components
/=  layout        /web/layout
/=  navbar        /web/components/navbar
/=  index         /web/pages/index
::  assets
/*  css       %css    /web/assets/style/css
/*  spinner   %noun   /web/assets/spinner/svg
/*  favicon   %noun   /web/assets/favicon/ico
/*  favicon1  %noun   /web/assets/favicon-32x32/png
/*  favicon2  %noun   /web/assets/favicon-16x16/png
::
|%
+$  order  [id=@ta req=inbound-request:eyre]
++  json-body  json-to-octs:server
++  ebail  |=  id=@t  %-  give-simple-payload:app:server  [id pbail]
++  pbail  (manx-payload manx-bail)
++  manx-bail  ^-  manx  ;div:"404"
++  manx-payload
  |=  =manx
  ^-  simple-payload:http
  %-  html-response:gen:server
  %-  manx-to-octs:server  manx
::  main
++  router
  |_  [=state:sur =bowl:gall]
  ++  rout
    |=  =order
    ^-  (list card:agent:gall)
    =/  rl  (parse-request-line:server url.request.req.order)
    =.  site.rl  ?~  site.rl  ~  t.site.rl
    =/  met  method.request.req.order
    =/  fpath=(pole knot)  [met site.rl]
    |^
    (ebail -.order)
    --
  --
--
