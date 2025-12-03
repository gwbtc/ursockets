import type { Poast } from "@/types/trill";
import Modal from "../modals/Modal";
import { useState } from "react";
import Post from "./Post";
import RP from "./RP";
import Avatar from "../Avatar";
import { stringToReact } from "./Reactions";

function StatsModal({ poast, close }: { close: any; poast: Poast }) {
  const [tab, setTab] = useState("replies");
  const replies = poast.children || [];
  const quotes = poast.engagement.quoted;
  const reposts = poast.engagement.shared;
  const reacts = poast.engagement.reacts;
  function set(e: React.MouseEvent, s: string) {
    e.stopPropagation();
    setTab(s);
  }
  // TODO revise the global thingy here
  return (
    <Modal close={close}>
      <div id="stats-modal">
        <Post poast={poast} user={{ urbit: poast.author }} refetch={() => {}} />
        <div id="tabs">
          <div
            role="link"
            className={"tab" + (tab === "replies" ? " active-tab" : "")}
            onClick={(e) => set(e, "replies")}
          >
            <h4>Replies</h4>
          </div>
          <div
            role="link"
            className={"tab" + (tab === "quotes" ? " active-tab" : "")}
            onClick={(e) => set(e, "quotes")}
          >
            <h4>Quotes</h4>
          </div>
          <div
            role="link"
            className={"tab" + (tab === "reposts" ? " active-tab" : "")}
            onClick={(e) => set(e, "reposts")}
          >
            <h4>Reposts</h4>
          </div>
          <div
            role="link"
            className={"tab" + (tab === "reacts" ? " active-tab" : "")}
            onClick={(e) => set(e, "reacts")}
          >
            <h4>Reacts</h4>
          </div>
        </div>
        <div id="engagement">
          {tab === "replies" ? (
            <div id="replies">
              {replies.map((p) => (
                <div key={p} className="reply-stat">
                  <RP
                    host={poast.host}
                    id={p}
                    rter={undefined}
                    rtat={undefined}
                    rtid={undefined}
                  />
                </div>
              ))}
            </div>
          ) : tab === "quotes" ? (
            <div id="quotes">
              {quotes.map((p) => (
                <div key={p.pid.id} className="quote-stat">
                  <RP
                    host={p.pid.ship}
                    id={p.pid.id}
                    rter={undefined}
                    rtat={undefined}
                    rtid={undefined}
                  />
                </div>
              ))}
            </div>
          ) : tab === "reposts" ? (
            <div id="reposts">
              {reposts.map((p) => (
                <div key={p.pid.id} className="repost-stat">
                  <Avatar user={{ urbit: p.pid.ship }} size={40} />
                </div>
              ))}
            </div>
          ) : tab === "reacts" ? (
            <div id="reacts">
              {Object.keys(reacts).map((p) => (
                <div key={p} className="react-stat btw">
                  <Avatar user={{ urbit: p }} size={32} />
                  {stringToReact(reacts[p])}
                </div>
              ))}
            </div>
          ) : null}
        </div>
      </div>
    </Modal>
  );
}
export default StatsModal;
