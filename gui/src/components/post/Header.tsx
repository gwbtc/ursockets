import { date_diff } from "@/logic/utils";
import type { PostProps } from "./Post";
import { useLocation } from "wouter";
import useLocalState from "@/state/state";
function Header(props: PostProps) {
  const [_, navigate] = useLocation();
  const profiles = useLocalState((s) => s.profiles);
  const profile = profiles.get(props.poast.author);
  // console.log("profile", profile);
  // console.log(props.poast.author.length, "length");
  function go(e: React.MouseEvent) {
    e.stopPropagation();
  }
  function openThread(e: React.MouseEvent) {
    e.stopPropagation();
    const sel = window.getSelection()?.toString();
    if (!sel) navigate(`/feed/${poast.host}/${poast.id}`);
  }
  const { poast } = props;
  const name = profile ? (
    profile.name
  ) : (
    <div className="name cp">
      <p className="p-only">{poast.author}</p>
    </div>
  );
  return (
    <header>
      <div className="author flex-align" role="link" onMouseUp={go}>
        {name}
      </div>
      <div role="link" onMouseUp={openThread} className="date">
        <p title={new Date(poast.time).toLocaleString()}>
          {date_diff(poast.time, "short")}
        </p>
      </div>
    </header>
  );
}
export default Header;
