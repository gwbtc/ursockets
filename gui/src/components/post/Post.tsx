import type { PostID, Poast, Reference } from "@/types/trill";

import Header from "./Header";
import Body from "./Body";
import Footer from "./Footer";
import { useLocation } from "wouter";
import useLocalState from "@/state/state";
import RP from "./RP";
import ShipModal from "../modals/ShipModal";
import type { Ship } from "@/types/urbit";
import Sigil from "../Sigil";
import type { UserProfile } from "@/types/nostrill";

export interface PostProps {
  poast: Poast;
  fake?: boolean;
  rter?: Ship;
  rtat?: number;
  rtid?: PostID;
  nest?: number;
  refetch?: Function;
  profile?: UserProfile;
}
function Post(props: PostProps) {
  console.log("post", props);
  const { poast } = props;
  if (!poast || poast.contents === null) {
    return null;
  }
  const isRP =
    poast.contents.length === 1 &&
    "ref" in poast.contents[0] &&
    poast.contents[0].ref.type === "trill";
  if (isRP) {
    const ref = (poast.contents[0] as Reference).ref;
    return (
      <RP
        host={ref.ship}
        id={ref.path.slice(1)}
        rter={poast.author}
        rtat={poast.time}
        rtid={poast.id}
      />
    );
  } else return <TrillPost {...props} />;
}
export default Post;

function TrillPost(props: PostProps) {
  const { poast, profile, fake } = props;
  const setModal = useLocalState((s) => s.setModal);
  const [_, navigate] = useLocation();
  function openThread(_e: React.MouseEvent) {
    const sel = window.getSelection()?.toString();
    if (!sel) navigate(`/feed/${poast.host}/${poast.id}`);
  }

  function openModal(e: React.MouseEvent) {
    e.stopPropagation();
    setModal(<ShipModal ship={poast.author} />);
  }
  const avatar = profile ? (
    <div className="avatar cp" role="link" onMouseUp={openModal}>
      <img src={profile.picture} />
    </div>
  ) : (
    <div className="avatar sigil cp" role="link" onMouseUp={openModal}>
      <Sigil patp={poast.author} size={46} />
    </div>
  );
  return (
    <div
      className={`timeline-post trill-post cp`}
      role="link"
      onMouseUp={openThread}
    >
      <div className="left">{avatar}</div>
      <div className="right">
        <Header {...props} />
        <Body {...props} />
        {!fake && <Footer {...props} />}
      </div>
    </div>
  );
}
