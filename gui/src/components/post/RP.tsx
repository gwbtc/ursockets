import Post from "./Post";
import type { Ship } from "@/types/urbit";
import type { Poast, FullNode, ID } from "@/types/trill";
import type { UserType } from "@/types/nostrill";
import PostData from "./Loader";
import { isValidPatp } from "urbit-ob";
export default function (props: {
  host: string;
  id: string;
  rter: Ship;
  rtat: number;
  rtid: ID;
  refetch?: Function;
}) {
  return PostData(props)(RP);
}

function RP({
  data,
  refetch,
  rter,
  rtat,
  rtid,
}: {
  data: FullNode;
  refetch: Function;
  rter: Ship;
  rtat: number;
  rtid: ID;
}) {
  const poast = toFlat(data);
  const user: UserType = poast.event
    ? { nostr: poast.event.pubkey }
    : isValidPatp(poast.author)
      ? { urbit: poast.author }
      : { nostr: poast.author };
  return (
    <Post
      poast={poast}
      user={user}
      rter={rter}
      rtat={rtat}
      rtid={rtid}
      refetch={refetch}
    />
  );
}

export function toFlat(n: FullNode): Poast {
  return {
    ...n,
    children: !n.children
      ? []
      : Object.keys(n.children).map((c) => n.children[c].id),
  };
}
