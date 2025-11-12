import type Urbit from "urbit-api";
import type { Cursor, FC, FullNode, PID, PostID } from "@/types/trill";
import type { Ship } from "@/types/urbit";
import { FeedPostCount } from "../constants";
import type { UserProfile, UserType } from "@/types/nostrill";
import type { AsyncRes } from "@/types/ui";

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
    return this.airlock.poke({ app: "nostrill", mark: "json", json });
  }
  private async scry(path: string) {
    return this.airlock.scry({ app: "nostrill", path });
  }
  private async sub(path: string, handler: Handler) {
    const has = this.subs.get(path);
    if (has) return;

    const err = (err: any, _id: string) =>
      console.log(err, "error on nostrill subscription");
    const quit = (data: any) => {
      console.log(data, "nostrill subscription kicked");
      this.subs.delete(path);
    };
    const res = await this.airlock.subscribe({
      app: "nostrill",
      path,
      event: handler,
      err,
      quit,
    });
    this.subs.set(path, res);
    console.log(res, "subscribed to nostrill agent");
  }
  async unsub(sub: number) {
    return await this.airlock.unsubscribe(sub);
  }
  // subs
  async subscribeStore(handler: Handler) {
    const res = await this.sub("/ui", handler);
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
  ): AsyncRes<FullNode> {
    // const order = desc ? 1 : 0;

    // const path = `/j/thread/${host}/${id}/${start}/${end}/${FeedPostCount}/${order}`;
    const path = `/j/thread/${host}/${id}`;
    const res = await this.scry(path);
    if (!("begs" in res)) return { error: "wrong result" };
    if ("ng" in res.begs) return { error: res.begs.ng };
    if ("ok" in res.begs) {
      if (!("thread" in res.begs.ok)) return { error: "wrong result" };
      else return { ok: res.begs.ok.thread };
    } else return { error: "wrong result" };
  }
  // pokes

  async pokeAlive() {
    return await this.poke({ alive: true });
  }
  async addPost(content: string) {
    const json = { add: { content } };
    return this.poke({ post: json });
  }
  async addReply(content: string, host: string, id: string, thread: string) {
    const json = { reply: { content, host, id, thread } };
    return this.poke({ post: json });
  }
  async addQuote(content: string, pid: PID) {
    const json = { quote: { content, host: pid.ship, id: pid.id } };
    return this.poke({ post: json });
  }
  async addRP(pid: PID) {
    const json = { rp: { host: pid.ship, id: pid.id } };
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

  async deletePost(host: Ship, id: string) {
    const json = {
      del: {
        host,
        id,
      },
    };
    return this.poke({ post: json });
  }

  async addReact(ship: Ship, id: PostID, reaction: string) {
    const json = {
      reaction: {
        reaction: reaction,
        id: id,
        host: ship,
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
  async deleteRelay(url: string) {
    const json = { del: url };
    return await this.poke({ rela: json });
  }
  async syncRelays() {
    // TODO make it choosable?
    const json = { sync: null };
    return await this.poke({ rela: json });
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
}

// notifications

// mark as read
