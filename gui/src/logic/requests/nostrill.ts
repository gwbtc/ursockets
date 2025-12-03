import type Urbit from "urbit-api";
import type { Cursor, FC, FullNode, PostID } from "@/types/trill";
import type { Ship } from "@/types/urbit";
import { FeedPostCount } from "../constants";
import type { UserProfile, UserType } from "@/types/nostrill";
import type { AsyncRes } from "@/types/ui";
import type { Skein } from "../hark";

// Subscribe
type Handler = (date: any) => void;
export default class IO {
  airlock;
  subs: Map<string, number> = new Map();
  constructor(airlock: Urbit) {
    this.airlock = airlock;
  }
  private async thread(threadName: string, json: any) {
    return this.airlock.thread({
      body: json,
      inputMark: "json",
      outputMark: "json",
      threadName,
    });
  }
  private async poke(json: any) {
    try {
      const res = await this.airlock.poke({
        app: "nostrill",
        mark: "json",
        json,
      });
      return { ok: res };
    } catch (e) {
      return { error: `${e}` };
    }
  }
  private async scry(path: string, agent?: string) {
    try {
      const app = agent ? agent : "nostrill";
      const res = await this.airlock.scry({ app, path });
      return { ok: res };
    } catch (e) {
      return { error: `${e}` };
    }
  }
  private async sub(path: string, handler: Handler, agent?: string) {
    const has = this.subs.get(path);
    if (has) return;

    const err = (err: any, _id: string) =>
      console.log(err, "error on nostrill subscription");
    const quit = (data: any) => {
      console.log(data, "nostrill subscription kicked");
      this.subs.delete(path);
    };
    const app = agent ? agent : "nostrill";
    const res = await this.airlock.subscribe({
      app,
      path,
      event: handler,
      err,
      quit,
    });
    this.subs.set(path, res);
    console.log(res, `subscribed to /${app}${path}`);
    return res;
  }
  async unsub(sub: number) {
    return await this.airlock.unsubscribe(sub);
  }
  // subs
  async subscribeStore(handler: Handler) {
    const res = await this.sub("/ui", handler);
    return res;
  }
  async subscribeHark(handler: Handler) {
    const res = await this.sub("/ui", handler, "hark");
    return res;
  }
  // scries

  async scryFeed(
    host: Ship,
    start: Cursor,
    end: Cursor,
    desc = true,

    replies = false,
  ) {
    const order = desc ? 1 : 0;
    const rp = replies ? 1 : 0;

    const path = `/j/feed/${host}/${start}/${end}/${FeedPostCount}/${order}/${rp}`;
    return await this.scry(path);
  }
  async scryThread(
    host: Ship,
    id: PostID,
    // start: Cursor,
    // end: Cursor,
    // desc = true,
  ): AsyncRes<{ node: FullNode; thread: FullNode[] }> {
    // const order = desc ? 1 : 0;

    // const path = `/j/thread/${host}/${id}/${start}/${end}/${FeedPostCount}/${order}`;
    const path = `/j/thread/${host}/${id}`;
    const res = await this.scry(path);
    if ("error" in res) return res;
    if (!("begs" in res.ok)) return { error: "wrong result" };
    if ("ng" in res.ok.begs) return { error: res.ok.begs.ng };
    if ("ok" in res.ok.begs) {
      if (!("data" in res.ok.begs.ok)) return { error: "wrong result on data" };
      if (!("thread" in res.ok.begs.ok.data)) return { error: "wrong result on thread" };
      else return { ok: res.ok.begs.ok.data.thread };
    } else return { error: "wrong result" };
  }
  // async scryHark(): AsyncRes<Skein[]> {
  async scryHark(): AsyncRes<Skein[]> {
    const path3 = "/all/skeins";
    const path4 = "/all/latest";
    const path = "/desk/nostrill/skeins";
    // const path2 = "/desk/nostrill/latest";
    // this returns Carpet
    const res = await this.scry(path, "hark");
    const res3 = await this.scry(path3, "hark");
    const res4 = await this.scry(path4, "hark");
    // const res2 = await this.scry(path2, "hark");
    console.log("hark scry", res);
    console.log("hark all skeins", res3);
    console.log("hark all latest", res4);
    return res;
  }

  // pokes

  async pokeAlive() {
    return await this.poke({ alive: true });
  }
  async addPost(content: string) {
    const json = { add: { content } };
    return this.poke({ post: json });
  }
  async addReply(content: string, host: UserType, id: string, thread: string) {
    const json = { reply: { content, host, id, thread } };
    return this.poke({ post: json });
  }
  async addQuote(content: string, host: UserType, id: string) {
    const json = { quote: { content, host, id } };
    return this.poke({ post: json });
  }
  async addRP(host: UserType, id: string) {
    const json = { rp: { host, id } };
    return this.poke({ post: json });
  }

  // async addPost(post: SentPoast, gossip: boolean) {
  //   const json = {
  //     "new-post": {
  //       "sent-post": post,
  //       gossip,
  //     },
  //   };
  //   return this.poke(json);
  // }

  async deletePost(host: UserType, id: string) {
    const json = {
      del: {
        host,
        id,
      },
    };
    return this.poke({ post: json });
  }

  async addReact(host: UserType, id: PostID, reaction: string) {
    const json = {
      reaction: {
        reaction: reaction,
        id,
        host,
      },
    };

    return this.poke({ post: json });
  }

  //  follows
  async follow(user: UserType) {
    const json = { add: user };
    return this.poke({ fols: json });
  }

  async unfollow(user: UserType) {
    const json = { del: user };
    return await this.poke({ fols: json });
  }
  // profiles
  async createProfile(profile: UserProfile) {
    const json = { add: profile };
    return await this.poke({ prof: json });
  }
  async deleteProfile() {
    const json = { del: null };
    return await this.poke({ prof: json });
  }
  async cycleKeys() {
    return await this.poke({ keys: null });
  }
  // relaying
  async addRelay(url: string) {
    const json = { add: url };
    return await this.poke({ rela: json });
  }
  async deleteRelay(wid: number) {
    const json = { del: wid };
    return await this.poke({ rela: json });
  }
  async syncRelays() {
    // TODO make it choosable?
    const json = { sync: null };
    return await this.poke({ rela: json });
  }
  async getProfiles(users: UserType[]) {
    const json = { fetch: users };
    return await this.poke({ prof: json });
  }
  async relayPost(host: string, id: string, relays: string[]) {
    const json = { send: { host, id, relays } };
    return await this.poke({ rela: json });
  }
  // threads
  //
  async peekFeed(
    host: string,
  ): AsyncRes<{ feed: FC; profile: UserProfile | null }> {
    try {
      const json = { begs: { feed: host } };
      const res: any = await this.thread("beg", json);
      console.log("peeking feed", res);
      if (!("begs" in res)) return { error: "wrong request" };
      if ("ng" in res.begs) return { error: res.begs.ng };
      if (!("feed" in res.begs.ok)) return { error: "wrong request" };
      else return { ok: res.begs.ok };
    } catch (e) {
      return { error: `${e}` };
    }
  }
  async peekThread(host: string, id: string): AsyncRes<FullNode> {
    try {
      const json = { begs: { thread: { host, id } } };
      const res: any = await this.thread("beg", json);
      console.log("peeking feed", res);
      if (!("begs" in res)) return { error: "wrong request" };
      if ("ng" in res.begs) return { error: res.begs.ng };
      if (!("thread" in res.begs.ok)) return { error: "wrong request" };
      else return { ok: res.begs.ok.thread };
    } catch (e) {
      return { error: `${e}` };
    }
  }
  // nostr
  //
  async nostrFeed(pubkey: string): AsyncRes<number> {
    const json = { rela: { user: pubkey } };
    return await this.poke(json);
  }
  async nostrThread(id: string): AsyncRes<number> {
    const json = { rela: { thread: id } };
    return await this.poke(json);
  }
  async nostrProfiles() {
    const json = { prof: null };
    return await this.poke({ rela: json });
  }
}

// notifications

// mark as read
