|%
  ++  give-ws-payload
    |=  [wid=@ event=websocket-event:eyre]
    ^-  (list card:agent:gall)
    =/  =cage
      [%websocket-response !>([wid event])]
    =/  wsid  (scot %ud wid)
    :~  [%give %fact ~[/websocket-server/[wsid]] cage]
    ==
  ++  accept-handshake  |=  wid=@
    =/  response  [%accept ~]
    (give-ws-payload wid response)

--
