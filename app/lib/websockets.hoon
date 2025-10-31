|%
  ++  give-ws-payload-client
    |=  [wid=@ msg=websocket-message:eyre]
    ^-  card:agent:gall
    =/  =cage
      [%message !>(msg)]
    =/  wsid  (scot %ud wid)
    [%give %fact ~[/websocket-client/[wsid]] cage]
  ++  close-ws-client
    |=  wid=@
    ^-  card:agent:gall
    =/  =cage
      [%disconnect !>(~)]
    =/  wsid  (scot %ud wid)
    [%give %fact ~[/websocket-client/[wsid]] cage]

  ++  give-ws-payload-server
    |=  [wid=@ event=websocket-event:eyre]
    ^-  card:agent:gall
    =/  =cage
      [%websocket-response !>([wid event])]
    =/  wsid  (scot %ud wid)
    [%give %fact ~[/websocket-server/[wsid]] cage]
  
  ++  accept-handshake  |=  wid=@
    =/  response  [%accept ~]
    :~
    (give-ws-payload-server wid response)
    ==
  ++  refuse-handshake  |=  wid=@
    =/  response  [%reject ~]
    :~
    (give-ws-payload-server wid response)
    ==

  ++  get-url
    |=  [wid=@ud =bowl:gall]  ^-  @t
    =/  scry-path=path  /(scot %p our.bowl)/ws/(scot %da now.bowl)/id/(scot %ud wid)
    =/  conn  .^(websocket-connection:iris %ix scry-path)
    url.conn
  ++  check-connected
    |=  [url=@t =bowl:gall]  ^-  (unit websocket-connection:iris)
    =/  scry-path=path  /(scot %p our.bowl)/ws/(scot %da now.bowl)/url/[url]
    =/  conn  .^((unit websocket-connection:iris) %ix scry-path)
    conn
--
