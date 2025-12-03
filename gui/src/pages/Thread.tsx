import { useParams } from "wouter";
import useLocalState from "@/state/state";
import { ErrorPage } from "@/pages/Error";
import "@/styles/trill.css";
import "@/styles/feed.css";
import { stringToUser } from "@/logic/nostrill";
import TrillThread from "@/components/trill/Thread";
import NostrThread from "@/components/nostr/Thread";
import { decodeNostrKey } from "@/logic/nostr";

export default function ThreadLoader() {
  const { profiles, following } = useLocalState((s) => ({
    profiles: s.profiles,
    following: s.following,
  }));

  const params = useParams<{ host: string; id: string }>();
  const { host, id } = params;

  const uuser = stringToUser(host);
  if ("error" in uuser) return <ErrorPage msg={uuser.error} />;
  const feed = following.get(host);
  const profile = profiles.get(host);
  if ("urbit" in uuser.ok)
    return (
      <TrillThread
        feed={feed}
        profile={profile}
        host={uuser.ok.urbit}
        id={id}
      />
    );
  if ("nostr" in uuser.ok)
    return (
      <NostrThread
        feed={feed}
        profile={profile}
        host={uuser.ok.nostr}
        id={id}
      />
    );
  else return <ErrorPage msg="weird" />;
}

export function NostrThreadLoader() {
  const params = useParams<{ id: string }>();
  const { id } = params;
  if (!id) return <ErrorPage msg="No thread id passed" />;
  const dec = decodeNostrKey(id);
  if (!dec) return <ErrorPage msg="Unknown thread id format" />;
  return <NostrThread id={dec} host="" />;
}
