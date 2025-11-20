import type { NostrPost } from "@/types/nostrill";
import Post from "../Post";
import useLocalState from "@/state/state";

export default NostrPost;
function NostrPost({ data }: { data: NostrPost }) {
  const { profiles } = useLocalState((s) => ({ profiles: s.profiles }));
  const profile = profiles.get(data.event.pubkey);

  return (
    <Post
      user={{ urbit: data.post.author }}
      poast={data.post}
      profile={profile}
    />
  );
}

export function NostrSnippet({ eventId, pubkey, relay, post }: NostrPost) {
  return <Post user={{ nostr: pubkey }} poast={post} />;
}
