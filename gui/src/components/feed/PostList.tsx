import TrillPost from "@/components/post/Post";
import type { FC } from "@/types/trill";
// import { useEffect } from "react";
// import { useQueryClient } from "@tanstack/react-query";
// import { toFull } from "../thread/helpers";

function TrillFeed({ data, refetch }: { data: FC; refetch: Function }) {
  // const qc = useQueryClient();
  // useEffect(() => {
  //   Object.values(data.feed).forEach((poast) => {
  //     const queryKey = ["trill-thread", poast.host, poast.id];
  //     const existing = qc.getQueryData(queryKey);
  //     if (!existing || !("fpost" in (existing as any))) {
  //       qc.setQueryData(queryKey, {
  //         fpost: toFull(poast),
  //       });
  //     }
  //   });
  // }, [data]);
  return (
    <>
      {Object.keys(data.feed)
        // omit replies
        .filter((i) => !data.feed[i].parent)
        .sort()
        .reverse()
        .slice(0, 50)
        .map((i) => (
          <TrillPost key={i} poast={data.feed[i]} refetch={refetch} />
        ))}
    </>
  );
}

export default TrillFeed;
