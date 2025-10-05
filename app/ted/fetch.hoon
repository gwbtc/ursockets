/-  spider
/+  strandio
=,  strand=strand:spider
=,  dejs-soft:format
=,  strand-fail=strand-fail:libstrand:spider
^-  thread:spider
|=  arg=vase
  =/  request  ;;(request:http q.arg) 
  =/  m  (strand ,vase)  ^-  form:m
  :: =/  m  (strand ,json)  ^-  form:m
  ;<  ~  bind:m  (send-request:strandio request)
  ;<  res=client-response:iris  bind:m  take-client-response:strandio
  ?.  ?=(%finished -.res)  (strand-fail:strand %no-body ~)
  :: =/  headers  headers.response-header.res  
  :: =/  redirect  (get-header:http 'location' headers)
  ::   ?^  redirect  (pure:m [%| u.redirect])  

  ::
  ?~  full-file.res  (strand-fail:strand %no-body ~)
  =/  body=@t  q.data.u.full-file.res
  (pure:m !>(body))
