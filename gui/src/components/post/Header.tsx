import { date_diff } from "@/logic/utils";
import type { PostProps } from "./Post";
import { useLocation } from "wouter";
function Header(props: PostProps) {
  const [_, navigate] = useLocation();
  const { profile } = props;
  // console.log("profile", profile);
  // console.log(props.poast.author.length, "length");
  function go(e: React.MouseEvent) {
    e.stopPropagation();
    navigate(`/u/${poast.host}`);
  }
  function openThread(e: React.MouseEvent) {
    e.stopPropagation();
    const sel = window.getSelection()?.toString();
    const id = "urbit" in props.user ? poast.id : poast.hash;
    if (!sel) navigate(`/t/${poast.host}/${id}`);
  }
  const { poast } = props;
  const name = profile ? (
    profile.name
  ) : "urbit" in props.user ? (
    <p className="p-only">{props.user.urbit}</p>
  ) : (
    <p className="p-only">{props.user.nostr}</p>
  );
  return (
    <header>
      <div className="cp author flex-align name" role="link" onMouseUp={go}>
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
