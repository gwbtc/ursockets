{ click, pierBus, pierFun, pkgs, urbitBin }:

let
  poke = ''
    =>
    |%
    ++  take-poke-ack
      |=  =wire
      =/  m  (strand ,?)
      ^-  form:m
      |=  tin=strand-input:strand
      ?+  in.tin  `[%skip ~]
          ~  `[%wait ~]
          [~ %agent * %poke-ack *]
        ?.  =(wire wire.u.in.tin)
          `[%skip ~]
        ?~  p.sign.u.in.tin
          `[%done %.y]
        `[%done %.n]
      ==
    ++  poke
      |=  [=dock =cage]
      =/  m  (strand ,?)
      ^-  form:m
      =/  =card:agent:gall  [%pass /poke %agent dock %poke cage]
      ;<  ~  bind:m  (send-raw-card card)
      (take-poke-ack /poke)
    --

  '';

  pokeHood = mark: hoon:
    pkgs.writeTextFile {
      name = "${mark}.hoon";
      text = ''
        ${poke}
        =/  m  (strand ,vase)
        ;<  [=ship =desk =case]  bind:m  get-beak
        ;<  now=@da  bind:m  get-time
        ;<  ok=?  bind:m  (poke [ship %hood] ${mark}+!>(${hoon}))
        (pure:m !>(ok))
      '';
    };

  pokePost = content:
    pkgs.writeTextFile {
      name = ":$nostrill-json-post.hoon";
      text = ''
        ${poke}
        =/  m  (strand ,vase)
        =/  dat=json
          %-  pairs:enjs:format
          :~  ['post' (frond:enjs:format 'add' (frond:enjs:format 'content' s+'${content}'))]
          ==
        ;<  [=ship =desk =case]  bind:m  get-beak
        ;<  ok=?  bind:m  (poke [ship %nostrill] %json !>(dat))
        (pure:m !>(ok))
      '';
    };

  pokePostAct = ship: action:
    pkgs.writeTextFile {
      name = ":nostrill-json-${action}.hoon";
      text = ''
        ${poke}
        =/  m  (strand ,vase)
        ;<  [=ship =desk =case]  bind:m  get-beak
        ;<  now=@da  bind:m  get-time
        =/  pax  /(scot %p ship)/nostrill/(scot %da now)/feed-ids/(scot %p ~${ship})/noun
        =/  action=@tas  %${action}
        =/  id-t=@t  
          %-  crip
          %-  a-co:co
          %-  rear
          .^((list @da) %gx pax)
        =/  dat=json
          ?:  =(action %reply)
            %-  frond:enjs:format  :-  'reply'
            %-  pairs:enjs:format
            :~  ['content' s+'Reply']
                ['host' s+'~${ship}']
                ['id' s+id-t]
                ['thread' s+id-t]
            ==
          ?:  =(action %quote)
            %-  frond:enjs:format  :-  'quote'
            %-  pairs:enjs:format
            :~  ['content' s+'Quote']
                ['host' s+'~${ship}']
                ['id' s+id-t]
            ==
          ?:  =(action %rp)
            %-  frond:enjs:format  :-  'rp' 
            %-  pairs:enjs:format 
            :~  ['host' s+'~${ship}']
                ['id' s+id-t]
            ==
          %-  frond:enjs:format  :-  'reaction' 
          %-  pairs:enjs:format 
          :~  ['host' s+'~${ship}']
              ['id' s+id-t]
              ['reaction' s+'100!']
          ==
        =/  jon=json
          %-  pairs:enjs:format
          :~  :-  'post'  dat
          ==
        ;<  ok=?  bind:m  (poke [ship %nostrill] %json !>(jon))
        (pure:m !>(ok))
      '';
    };
  
  pokeProfile = ship:
    pkgs.writeTextFile {
      name = ":nostrill-json-profile.hoon";
      text = ''
        ${poke}
        =/  m  (strand ,vase)
        =/  dat=json
          %-  pairs:enjs:format
          :~  :-  'prof'
              %-  frond:enjs:format  :-  'add'
              %-  pairs:enjs:format
              :~  ['name' s+'${ship}']
                  ['about' s+'about me']
                  ['picture' s+'pic']
                  ['other' (pairs:enjs:format ~[['location' s+'Urbit'] ['status' s+'testing']])]
              ==
          ==
        ;<  [=ship =desk =case]  bind:m  get-beak
        ;<  ok=?  bind:m  (poke [ship %nostrill] %json !>(dat))
          (pure:m !>(ok))
      '';
    };

  pokeFollow = ship:
    pkgs.writeTextFile {
      name = ":nostrill-json-follow-${ship}.hoon";
      text = ''
        ${poke}
        =/  m  (strand ,vase)
        =/  dat=json
          %-  pairs:enjs:format
          :~
            :-  'fols'
            (frond:enjs:format 'add' (frond:enjs:format 'urbit' s+(scot %p ~${ship})))
          ==
        ;<  [=ship =desk =case]  bind:m  get-beak
        ;<  ok=?  bind:m  (poke [ship %nostrill] %json !>(dat))
        (pure:m !>(ok))
      '';
    };

  pokeUnfollow = ship:
    pkgs.writeTextFile {
      name = ":nostrill-json-unfollow-${ship}.hoon";
      text = ''
        ${poke}
        =/  m  (strand ,vase)
        =/  dat=json
          %-  pairs:enjs:format
          :~
            :-  'fols'
            (frond:enjs:format 'del' (frond:enjs:format 'urbit' s+(scot %p ~${ship})))
          ==
        ;<  [=ship =desk =case]  bind:m  get-beak
        ;<  ok=?  bind:m  (poke [ship %nostrill] %json !>(dat))
        (pure:m !>(ok))
      '';
    };

  scryFeedData = target-ship:
    pkgs.writeTextFile {
      name = "scry-${target-ship}-feed-data.hoon";
      text = ''
        ${poke}
        =/  m  (strand ,vase)
        ;<  [=ship =desk =case]  bind:m  get-beak
        ;<  now=@da  bind:m  get-time
        =/  pax  /(scot %p ship)/nostrill/(scot %da now)/feed/(scot %p ~${target-ship})/json
        =/  result=json  .^(json %gx pax)
        (pure:m !>((en:json:html result)))
      '';
    };

  # Pre-generate scry scripts for both ships
  scryBusFeed = scryFeedData "bus";
  scryFunFeed = scryFeedData "fun";


in pkgs.stdenvNoCC.mkDerivation {
  name = "test-nostrill";

  phases = [ "buildPhase" "checkPhase" ];

  nativeBuildInputs = [ pkgs.netcat pkgs.jq ];

  buildPhase = ''
    set -x
    set -e

    cp -R ${pierBus} ./bus
    chmod -R u+rw ./bus

    cp -R ${pierFun} ./fun
    chmod -R u+rw ./fun


    # Boot ships in daemon mode
    ${urbitBin} -d ./bus 2>&1 | tee bus.log &
    BUS_PID=$!

    ${urbitBin} -d ./fun > fun.log 2>&1 &
    FUN_PID=$!

    tail -F bus.log 2>&1 | sed -u "s/^/~bus: /" >&2 &
    tail -F fun.log 2>&1 | sed -u "s/^/~fun: /" >&2 &

    echo "Booting ~bus"
    for i in {1..120}; do
      if grep -q "ames: live" bus.log 2>/dev/null || grep -q "http: live" bus.log 2>/dev/null; then
        echo "~bus is ready!"
        break
      fi
      sleep 1
    done

    echo "Booting ~fun"
    for i in {1..120}; do
      if grep -q "ames: live" fun.log 2>/dev/null || grep -q "http: live" fun.log 2>/dev/null; then
        echo "~fun is ready!"
        break
      fi
      sleep 1
    done


    # Extra buffer
    sleep 5

    #Compare JSON data from two ships
    # Usage: compare_feed_data <target-feed-ship> <test-name>
    # This will scry the target-feed (e.g., ~bus) on both ~bus and ~fun, then compare the JSON
    compare_feed_data() {
      local target_feed=$1
      local test_name=$2

      echo ">>> TEST: $test_name - comparing $target_feed feed on ~bus vs ~fun" | tee -a test-output.log

      # Select the appropriate scry script
      local feed_scry
      case $target_feed in
        bus) feed_scry="${scryBusFeed}" ;;
        fun) feed_scry="${scryFunFeed}" ;;
        *) echo "Unknown feed: $target_feed"; return 1 ;;
      esac

      # Scry feed data on bus
      ${click} -kp -i $feed_scry ./bus 2>&1 | tee bus_''${target_feed}_feed.log

      # Scry feed data on fun
      ${click} -kp -i $feed_scry ./fun 2>&1 | tee fun_''${target_feed}_feed.log

      # Extract JSON from vase
      sed -n "s/.*%noun '\(.*\)'\]$/\1/p" bus_''${target_feed}_feed.log > bus_''${target_feed}_feed.json || echo "{}" > bus_''${target_feed}_feed.json
      sed -n "s/.*%noun '\(.*\)'\]$/\1/p" fun_''${target_feed}_feed.log > fun_''${target_feed}_feed.json || echo "{}" > fun_''${target_feed}_feed.json

      # Compare JSON using jq (normalize then compare)
      if jq -S . bus_''${target_feed}_feed.json > bus_normalized.json && \
         jq -S . fun_''${target_feed}_feed.json > fun_normalized.json && \
         diff -u bus_normalized.json fun_normalized.json > /dev/null; then
        echo "Pass: Feed data matches" | tee -a test-output.log
        return 0
      else
        echo "Fail: Feed data mismatch" | tee -a test-output.log
        echo "  Diff:" | tee -a test-output.log
        diff -u bus_normalized.json fun_normalized.json | tee -a test-output.log || true
        return 1
      fi
    }

    # Poking ~bus with post and profile data
    echo ">>> TEST: bus-poke-nostrill-json-post" | tee -a test-output.log
    ${click} -kp -i ${pokePost "Hello world"} ./bus 2>&1 | tee -a test-output.log
    sleep 1

    echo ">>> TEST: bus-poke-nostrill-json-profile" | tee -a test-output.log
    ${click} -kp -i ${pokeProfile "bus"} ./bus 2>&1 | tee -a test-output.log
    sleep 1

    echo ">>> TEST: bus-poke-nostrill-json-post-2" | tee -a test-output.log
    ${click} -kp -i ${pokePost "Post 2"} ./bus 2>&1 | tee -a test-output.log
    sleep 1

    # Poking ~fun with post and profile data
    echo ">>> TEST: fun-poke-nostrill-json-post" | tee -a test-output.log
    ${click} -kp -i ${pokePost "Post from ~fun"} ./fun 2>&1 | tee -a test-output.log
    sleep 1

    echo ">>> TEST: fun-poke-nostrill-json-profile" | tee -a test-output.log
    ${click} -kp -i ${pokeProfile "fun"} ./fun 2>&1 | tee -a test-output.log
    sleep 1

    # Poking ~fun with subscription to ~bus feed
    echo ">>> TEST: fun-poke-nostrill-json-follow-bus" | tee -a test-output.log
    ${click} -kp -i ${pokeFollow "bus"} ./fun 2>&1 | tee -a test-output.log
    sleep 5

    #  Compare full feed data: ~bus feed on bus should be exact to ~bus feed on ~fun
    compare_feed_data bus "bus-feed-sync-check-1" || echo "Feed comparison failed" | tee -a test-output.log
    sleep 1

    # Poking ~bus with subscription to ~fun feed
    echo ">>> TEST: bus-poke-nostrill-json-follow-fun" | tee -a test-output.log
    ${click} -kp -i ${pokeFollow "fun"} ./bus 2>&1 | tee -a test-output.log
    sleep 5

    #  Compare ~fun feed data
    compare_feed_data fun "fun-feed-sync-check-1" || echo "Feed comparison failed" | tee -a test-output.log
    sleep 1

    # Poking ~bus with another post data
    echo ">>> TEST: bus-poke-nostrill-json-post-3" | tee -a test-output.log
    ${click} -kp -i ${pokePost "Post 3"} ./bus 2>&1 | tee -a test-output.log
    sleep 4

    #  Compare ~bus feed data
    compare_feed_data bus "bus-feed-sync-check-2" || echo "Feed comparison failed" | tee -a test-output.log
    sleep 1

    #  Poking ~fun with reply post to latest post from ~bus
    echo ">>> TEST: fun-poke-nostrill-json-reply" | tee -a test-output.log
    ${click} -kp -i ${pokePostAct "bus" "reply"} ./fun 2>&1 | tee -a test-output.log
    sleep 2

    #  Compare data for ~fun and ~bus feed
    compare_feed_data bus "bus-feed-sync-check-3" || echo "Feed comparison failed" | tee -a test-output.log
    compare_feed_data fun "fun-feed-sync-check-2" || echo "Feed comparison failed" | tee -a test-output.log
    sleep 1

    #  Poking ~bus with reply to latest post from ~bus
    echo ">>> TEST: bus-poke-nostrill-json-reply" | tee -a test-output.log
    ${click} -kp -i ${pokePostAct "bus" "reply"} ./bus 2>&1 | tee -a test-output.log
    sleep 1

    #  Poking ~bus with quote of latest post from ~fun
    echo ">>> TEST: bus-poke-nostrill-json-quote" | tee -a test-output.log
    ${click} -kp -i ${pokePostAct "fun" "quote"} ./bus 2>&1 | tee -a test-output.log
    sleep 4

    #  Compare data for ~bus and ~fun feed
    compare_feed_data bus "bus-feed-sync-check-4" || echo "Feed comparison failed" | tee -a test-output.log
    compare_feed_data fun "fun-feed-sync-check-3" || echo "Feed comparison failed" | tee -a test-output.log
    sleep 1

    #  Poking ~bus with repost of latest post from ~fun
    echo ">>> TEST: bus-poke-nostrill-json-repost" | tee -a test-output.log
    ${click} -kp -i ${pokePostAct "fun" "rp"} ./bus 2>&1 | tee -a test-output.log
    sleep 4

    #  Compare data for ~bus and ~fun feed
    compare_feed_data bus "bus-feed-sync-check-5" || echo "Feed comparison failed" | tee -a test-output.log
    compare_feed_data fun "fun-feed-sync-check-4" || echo "Feed comparison failed" | tee -a test-output.log
    sleep 1

    echo ">>> TEST: bus-poke-nostrill-json-react" | tee -a test-output.log
    ${click} -kp -i ${pokePostAct "bus" "reaction"} ./bus 2>&1 | tee -a test-output.log
    sleep 2

    #  Compare data for ~bus
    compare_feed_data bus "bus-feed-sync-check-6" || echo "Feed comparison failed" | tee -a test-output.log
    sleep 1

    echo ">>> TEST: bus-poke-nostrill-json-reply" | tee -a test-output.log
    ${click} -kp -i ${pokePostAct "fun" "reply"} ./bus 2>&1 | tee -a test-output.log
    sleep 2

    #  Compare data for ~bus and ~fun feed
    compare_feed_data bus "bus-feed-sync-check-7" || echo "Feed comparison failed" | tee -a test-output.log
    compare_feed_data fun "fun-feed-sync-check-5" || echo "Feed comparison failed" | tee -a test-output.log
    sleep 1

    echo ">>> TEST: bus-poke-nostrill-json-react" | tee -a test-output.log
    ${click} -kp -i ${pokePostAct "fun" "reaction"} ./bus 2>&1 | tee -a test-output.log
    sleep 2

    #  Compare data for ~bus and ~fun feed
    compare_feed_data bus "bus-feed-sync-check-8" || echo "Feed comparison failed" | tee -a test-output.log
    compare_feed_data fun "fun-feed-sync-check-6" || echo "Feed comparison failed" | tee -a test-output.log
    sleep 1

    #  Poking ~bus with unsubscribe to ~fun feed
    echo ">>> TEST: bus-poke-nostrill-json-unfollow-bus" | tee -a test-output.log
    ${click} -kp -i ${pokeUnfollow "fun"} ./bus 2>&1 | tee -a test-output.log
    sleep 1

    #  Test to prove that ~bus unsubscribed and doesn't get updates from ~fun

    # Poking ~fun with post after unfollow
    echo ">>> TEST: fun-poke-nostrill-json-post-after-unfollow" | tee -a test-output.log
    ${click} -kp -i ${pokePost "foobar"} ./fun 2>&1 | tee -a test-output.log
    sleep 2

    # Verify feeds are NOT synced (should be different)
    echo ">>> TEST: verify-unfollow-no-sync - ~bus should NOT see ~fun's new post" | tee -a test-output.log

    # Scry fun feed on bus
    ${click} -kp -i ${scryFunFeed} ./bus 2>&1 | tee bus_fun_after_unfollow.log
    # Scry fun feed on fun
    ${click} -kp -i ${scryFunFeed} ./fun 2>&1 | tee fun_fun_after_unfollow.log

    # Extract JSON
    sed -n "s/.*%noun '\(.*\)'\]$/\1/p" bus_fun_after_unfollow.log > bus_fun_unfollow.json || echo "{}" > bus_fun_unfollow.json
    sed -n "s/.*%noun '\(.*\)'\]$/\1/p" fun_fun_after_unfollow.log > fun_fun_unfollow.json || echo "{}" > fun_fun_unfollow.json

    # Check if ~bus's view has "foobar" (it shouldn't)
    if grep -q "foobar" bus_fun_unfollow.json; then
      echo "Fail: ~bus still receiving updates from ~fun after unfollow!" | tee -a test-output.log
    else
      echo "Pass: ~bus correctly not receiving ~fun updates after unfollow" | tee -a test-output.log
    fi

    # Check if ~fun's own view has "foobar" (it should)
    if grep -q "foobar" fun_fun_unfollow.json; then
      echo "Pass: ~fun correctly has its own post" | tee -a test-output.log
    else
      echo "Failed: ~fun missing its own post" | tee -a test-output.log
    fi

    sleep 1


    # Exit both ships
    echo "Shut down ~bus"
    ${click} -kp -i ${pokeHood "drum-exit" "~"} ./bus 2>&1
    echo "Shut down ~fun"
    ${click} -kp -i ${pokeHood "drum-exit" "~"} ./fun 2>&1
    sleep 5

    pkill -P $$ tail || true

    set +x

    # Combine all logs
    {
      echo "=== TEST OUTPUT ==="
      if [ -f test-output.log ]; then
        cat test-output.log
      else
        echo "test-output.log not found"
      fi
      echo ""

      echo "=== BUS LOG ==="
      if [ -f bus.log ]; then
        cat bus.log
      else
        echo "bus.log not found"
      fi
      echo ""

      echo "=== FUN LOG ==="
      if [ -f fun.log ]; then
        cat fun.log
      else
        echo "fun.log not found"
      fi
    } > $out
  '';

  checkPhase = ''

    # Check for all types of failures
    has_app_errors=$(grep -E "(bad-ui-poke)" $out >/dev/null && echo "yes" || echo "no")

    has_crashes=$(grep -E "(bail:|mote:|crud:|gall:.*failed|%lost)" $out >/dev/null && echo "yes" || echo "no")

    has_errors=$(grep -E "(FAILED|CRASHED)" $out >/dev/null && echo "yes" || echo "no")

    has_failed_acks=$(grep -E "\[0 %avow (0 %noun )?1\]" $out >/dev/null && echo "yes" || echo "no")

    has_feed_comparison_failures=$(grep "Feed comparison failed" $out >/dev/null && echo "yes" || echo "no")

    if [ "$has_app_errors" = "yes" ] || [ "$has_crashes" = "yes" ] || [ "$has_errors" = "yes" ] || [ "$has_failed_acks" = "yes" ] || [ "$has_feed_comparison_failures" = "yes" ]; then

      echo ""
      echo "TESTS FAILED"
      echo "=============================="
      echo ""

      # Show agent crashes
      if [ "$has_crashes" = "yes" ]; then
        echo "--- Agent Crashes ---"
        echo ""
        grep -B 5 -A 3 -E "(bail:|mote:|crud:|gall:.*failed|%lost)" $out | head -100
        echo ""
      fi

      # Show general errors
      if [ "$has_errors" = "yes" ]; then
        echo "--- Error Keywords Found ---"
        echo ""
        grep -E "(FAILED|CRASHED|Failed|warn:)" $out | head -10
        echo ""
      fi

      # Show detailed failed tests
      echo "--- Failed Tests ---"
      echo ""

      # Process failed acks
      if [ "$has_failed_acks" = "yes" ]; then
        grep -n -E "\[0 %avow (0 %noun )?1\]" $out | while IFS=: read line_num _; do
          # Find the most recent test before this line
          test_name=$(sed -n "1,''${line_num}p" $out | grep ">>> TEST:" | tail -1 | sed 's/>>> TEST: //')
          if [ -n "$test_name" ]; then
            echo "  - $test_name: Failed poke (bad ack)"
          fi
        done
      fi

      # Process app errors (bad-ui-poke)
      if [ "$has_app_errors" = "yes" ]; then
        grep -n "bad-ui-poke" $out | while IFS=: read line_num error_text; do
          # Find the most recent test before this line
          test_name=$(sed -n "1,''${line_num}p" $out | grep ">>> TEST:" | tail -1 | sed 's/>>> TEST: //')
          # Get logs around the error
          context=$(sed -n "''${line_num},$((line_num + 5))p" $out | head -6)
          echo "  - $test_name failed with: bad-ui-poke"
          echo "$context" | sed 's/^/      /'
          echo ""
        done
      fi

      # Process feed comparison failures
      if [ "$has_feed_comparison_failures" = "yes" ]; then
        grep -n "Feed comparison failed" $out | while IFS=: read line_num _; do
          # Find the most recent test before this line
          test_name=$(sed -n "1,''${line_num}p" $out | grep ">>> TEST:" | tail -1 | sed 's/>>> TEST: //')
          if [ -n "$test_name" ]; then
            echo "  - $test_name: Feed comparison failed"
          fi
        done
      fi

      echo ""
      echo "======================================"
      exit 1
    fi

    echo "Tests passed!"
  '';

  doCheck = true;

  # Fix 'bind: operation not permitted' on macOS
  __darwinAllowLocalNetworking = true;
}