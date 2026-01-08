import { useParams } from "wouter";
import useLocalState from "@/state/state";
import { ErrorPage } from "@/pages/Error";
import "@/styles/trill.css";
import "@/styles/feed.css";
import { stringToUser } from "@/logic/nostrill";
import ComposerModal from "@/components/modals/ComposerModal";
import TrillThread from "@/components/trill/Thread";
import NostrThread from "@/components/nostr/Thread";
import { decodeNostrKey } from "@/logic/nostr";

export default function ThreadLoader() {
  const { profiles, following, composerData } = useLocalState((s) => ({
    profiles: s.profiles,
    following: s.following,
    composerData: s.composerData,
  }));

  console.log({ composerData });
  const params = useParams<{ host: string; id: string }>();
  const { host, id } = params;

  const uuser = stringToUser(host);
  if ("error" in uuser) return <ErrorPage msg={uuser.error} />;
  const feed = following.get(host);
  const profile = profiles.get(host);

  return (
    <>
      {"urbit" in uuser.ok ? (
        <TrillThread
          feed={feed}
          profile={profile}
          host={uuser.ok.urbit}
          id={id}
        />
      ) : "nostr" in uuser.ok ? (
        <NostrThread
          feed={feed}
          profile={profile}
          host={uuser.ok.nostr}
          id={id}
          idString={id}
        />
      ) : (
        <ErrorPage msg="weird" />
      )}
      {composerData && <ComposerModal />}
    </>
  );
}

export function NostrThreadLoader() {
  const params = useParams<{ id: string }>();
  const { id } = params;
  if (!id) return <ErrorPage msg="No thread id passed" />;
  const dec = decodeNostrKey(id);
  if (!dec) return <ErrorPage msg="Unknown thread id format" />;
  return <NostrThread idString={id} id={dec} host="" />;
}
