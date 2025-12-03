import Post from "./Post";
import type { Ship } from "@/types/urbit";
import type { Poast, FullNode, ID } from "@/types/trill";
import PostData from "./Loader";
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
  return (
    <Post
      poast={toFlat(data)}
      user={{ urbit: data.author }}
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
