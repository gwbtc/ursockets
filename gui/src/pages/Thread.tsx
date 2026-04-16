import { useParams } from "wouter";
import useLocalState from "@/state/state";
import { ErrorPage } from "@/pages/Error";
import "@/styles/trill.css";
import "@/styles/feed.css";
import { stringToUser } from "@/logic/nostrill";
import ComposerModal from "@/components/modals/ComposerModal";
import TrillThread from "@/components/trill/Thread";
import NostrThread from "@/components/nostr/Thread";
import NostrThreadFetcher from "@/components/nostr/Fetcher";
import { decodeNostrKey } from "@/logic/nostr";

//TODO every post needs to know which relay it came from
export default function ThreadLoader() {
  const { profiles, following, composerData } = useLocalState((s) => ({
    profiles: s.profiles,
    following: s.following,
    composerData: s.composerData,
  }));
  const params = useParams<{ host: string; id: string }>();
  const { host, id } = params;
  const feed = following.get(host);
  const profile = profiles.get(host);

  return (
    <>
      <TrillThread feed={feed} profile={profile} host={host} id={id} />
      {composerData && <ComposerModal />}
    </>
  );
}

export function NostrThreadLoader() {
  const { globalFeed, nostrFeed, composerData } = useLocalState((s) => ({
    globalFeed: s.globalFeed,
    nostrFeed: s.nostrFeed,
    composerData: s.composerData,
  }));
  const params = useParams<{ id: string }>();
  const { id } = params;
  if (!id) return <ErrorPage msg="No thread id passed" />;
  const global = globalFeed.feed[id];
  if (global && global.event)
    return <NostrThread event={global.event} relays={global.event.relays} />;
  const nostr = nostrFeed.feed[id];
  if (nostr && nostr.event)
    return <NostrThread event={nostr.event} relays={nostr.event.relays} />;
  //
  const dec = decodeNostrKey(id);
  if (!dec) return <ErrorPage msg="Unknown thread id format" />;
  return <NostrThreadFetcher id={id} />;
}
