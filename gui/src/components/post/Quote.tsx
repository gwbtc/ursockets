import type { FullNode, Poast } from "@/types/trill";
import { date_diff } from "@/logic/utils";
import { useLocation } from "wouter";
import Body from "./Body";
import Sigil from "../Sigil";

type QuoteData = {
    node: Poast;
    thread: FullNode[];
  };

// function Quote({
//   data,
//   refetch,
//   nest,
// }: {
//   data: FullNode;
//   refetch?: Function;
//   nest: number;
// }) {
//   const [_, navigate] = useLocation();
//   function gotoQuote(e: React.MouseEvent) {
//     e.stopPropagation();
//     navigate(`/feed/${data.host}/${data.id}`);
//   }
//   return (
//     <div onMouseUp={gotoQuote} className="quote-in-post">
//       <header className="btw">
//         (
//         <div className="quote-author flex">
//           <Sigil patp={data.author} size={20} />
//           {data.author}
//         </div>
//         )<span>{date_diff(data.time, "short")}</span>
//       </header>
//       <Body poast={toFlat(data)} nest={nest} refetch={refetch!} />
//     </div>
//   );
// }
function Quote({
  data,
  refetch,
  nest,
}: {
  data: Poast | QuoteData;
  refetch?: Function;
  nest: number;
}) {
  const [_, navigate] = useLocation();
  const postData = 'node' in data ? data.node : data;

  function gotoQuote(e: React.MouseEvent) {
    e.stopPropagation();
    navigate(`/t/${postData.host}/${postData.id}`);
  }

  return (
    <div onMouseUp={gotoQuote} className="quote-in-post">
      <header className="btw">
        <div className="quote-author flex">
          <Sigil patp={postData.author} size={20} />
          {postData.author}
        </div>
        <span>{date_diff(postData.time, "short")}</span>
      </header>
      <Body user={{ urbit: postData.author }} poast={postData} nest={nest} refetch={refetch!} />
    </div>
  );
}

export default Quote;
