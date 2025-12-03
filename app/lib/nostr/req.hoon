/-  sur=nostr
/+  js=json-nostr, sr=sortug,
    server,
    ws=websockets
|%
++  parse-client-msg
  |=  jon=json  ^-  (unit client-msg:sur)
  (client-msg:de:js jon)
++  ok-client-event  |=  [=event:sur ok=? msg=@t]
  ^-  relay-msg:sur
  [%ok id.event ok msg]
++  ws-response
  |=  [wid=@ msg=relay-msg:sur]  ^-  (list card:agent:gall)
  =/  jon    (relay-msg:en:js msg)
  =/  octs   (json-to-octs:server jon)
  =/  res-event=websocket-event:eyre  [%message 1 `octs]
  :~
    (give-ws-payload-server:ws wid res-event)
  ==
--
