# Nostrill

Poasting on Urbit and Nostr

## Get started

The Nostr network uses WebSockets as its only way of communication. Therefore this app required adding WebSockets support to the Urbit runtime and OS. Which we did.

To run this app you'll need to run an Urbit ship on this experimental runtime, and install an experimental fork of Arvo on it.
There's an easy way and a hard way to do that.

#### Easy way:

1. Download vere-ws (for linux x64) [from this link](https://s3/sortug.com/globs/vere-ws.tar.gz).
2. Download the arvo-ws pill [from this link](https://s3.sortug.com/globs/nostrill.pill.tar.gz).
3. Boot a new ship, e.g.: `vere-ws -F zod -B arvo-ws.pill`.

Your ship should already have Nostrill installed and running.

#### Hard way:

1. Clone this repo.
2. Build the runtime
2.1. Go to the `vere` folder and compile the runtime running `zig build`.
2.2. Locate the compiled executable from `vere/zig-out` (the rest of the path depends on your system). We suggest making a new folder in the repo root called `piers` and putting it there.
3. Build the kernel
3.1 Boot a new ship of your liking with the newly compiled runtime. Here let's assume your ship's pier is `piers/zod` in the repo root folder.
3.2. Once the ship is running, mount the base desk by running `|mount %base` on Dojo.
3.3. The Arvo source files with WebSockets support are in the `arvo` folder. Copy or symlink `arvo/lull.hoon` to your pier's `base/sys` folder, and the rest to `base/sys/vane`.
3.4. Recompile the Arvo kernel on Dojo by running `|commit %base`. This process is slow, can take 10-30 minutes
4. Install the app
4.1 Make a new desk in Dojo: `|new-desk %nostrill`.
4.2 Mount it: `|mount %nostrill`.
4.3 Go to your pier and delete the empty desk: `rm -rf piers/zod/nostrill` 
4.4 Copy the nostrill desk from the repo root `cp -r app piers/zod/nostrill`.
4.5 Back in Dojo commit the changes: `|commit %nostrill`.
4.6 Install the app `|install %nostrill`.

Your ship should already have Nostrill installed and running and you should be an hour or so older. And wiser.

## Features

### WebSockets support
This repo fullfills the [UIP-0125](https://github.com/urbit/UIPs/blob/main/UIPS/UIP-0125.md) with WebSockets support to both Eyre (server) and Iris (client), and their respective equivalents in Vere. Take a look at the proposal to see which types and data structures are used.

Below is a short explanation on how to use WebSockets in your typical Gall agent development. In `app/lib/websockets.hoon` there is a simple library which will help with most of the boilerplate.

#### Use as a server
Say you want to communicate from a frontend to an Urbit agent through WebSockets. Your agent will need to set an Eyre binding to a given path with the `%connect` task. This makes Eyre know where to route the WebSockets request.
Then have the frontend establish a WebSockets connection to that path. Eyre will receive that first connection attempt and send a `%websocket-handshake` poke to your agent.
If your agent accepts the handshake, Eyre will establish the connection, give it an id number, and subscribe to your agent with the path `/websocket-server/[id]`. You can send data to your client by sending `%give %fact` card to that path.
Further messages from that client will be received as pokes with the `%websocket-server-message` mark and vase of shape [id=@ud =path websocket-message:eyre] 

#### Use as a client
To connect from your Gall agent to a WebSockets server, you must pass Iris a `%websocket-connect` task.
If successful, Iris will subscribe to the agent witht he path `/websocket-client/[id]`. 
Other than that the flow is very similar. The agent sends WebSockets messages as `%fact` through the open subscription with the vane.
Incoming messages appear as pokes with a `%websocket-client-message` and a vase of shape [id=@ud websocket-message:eyre] 

### Urbit Microblogging

Nostrill is the spiritual successor to `%trill`. No import mechanism of `%triill` is planned but we will consider if there's demand.
As such you can poast, set a profile, follow people, and build a feed of your favorite content.
Not all the features of `%trill` are present of yet but Nostrill is *much* faster. And it will stay that way.

### Nostr integration

Add your favorite Nostr relay in the Settings page (or several), then sync in the Nostr tab at the Home page. Your ship will start receiving messages immediately.

You can follow users of Nostr, i.e. subscribe to them, and your `%nostrill` will keep receiving every post they publish on one of your set relays.

As of present only Nostr events kinds `0` (user profiles), `1` (short posts), `6` (reposts) and `7` (reactions) are handled but that will grow soon. 


