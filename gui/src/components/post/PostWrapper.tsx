import useLocalState from "@/state/state";
import type { NostrPost, PostWrapper } from "@/types/nostrill";

export default Post;
function Post(pw: PostWrapper) {
  if ("nostr" in pw) return <NostrPost post={pw.nostr} />;
  else return <TrillPost post={pw.urbit.post} nostr={pw.urbit.nostr} />;
}

function NostrPost({ post, event, relay }: NostrPost) {
  const { profiles } = useLocalState();
  const profile = profiles.get(event.pubkey);
  return <></>;
}
