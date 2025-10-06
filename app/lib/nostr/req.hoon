/-  sur=nostr
/+  js=json-nostr, sr=sortug,
    lib=nostr,
    server,
    ws=websockets
|%
++  parse-client-msg
  |=  jon=json  ^-  (unit client-msg:nsur)
  (client-msg:de:js jon)
++  ok-client-event  |=  [=event:nsur ok=? msg=@t]
  ^-  relay-msg
  [%ok id.event ok msg]
++  ws-response
  |=  msg=relay-msg:sur  ^-  (list card:agent:gall)
  =/  jon    (relay-msg:en:js msg)
  =/  octs   (json-to-octs:server jon)
  =/  res-event=websocket-event:eyre  [%message 1 `octs]
    (give-ws-payload:ws wid res-event)
--
