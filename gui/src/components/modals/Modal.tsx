import useLocalState from "@/state/state";
import { useEffect, useRef, useState } from "react";

function Modal({ children }: any) {
  const { setModal } = useLocalState((s) => ({ setModal: s.setModal }));
  function onKey(event: any) {
    if (event.key === "Escape") setModal(null);
  }
  useEffect(() => {
    document.addEventListener("keyup", onKey);
    return () => {
      document.removeEventListener("keyup", onKey);
    };
  }, [children]);

  function clickAway(e: React.MouseEvent) {
    console.log("clicked away");
    e.stopPropagation();
    if (!modalRef.current || !modalRef.current.contains(e.target))
      setModal(null);
  }
  const modalRef = useRef(null);
  return (
    <div id="modal-background" onClick={clickAway}>
      <div id="modal" ref={modalRef}>
        {children}
      </div>
    </div>
  );
}
export default Modal;

export function Welcome() {
  return (
    <Modal>
      <div id="welcome-msg">
        <h1>Welcome to Nostril!</h1>
        <p>
          Trill is the world's only truly free and sovereign social media
          platform, powered by Urbit.
        </p>
        <p>
          Click on the crow icon on the top left to see all available feeds.
        </p>
        <p>The Global feed should be populated by default.</p>
        <p>Follow people soon so your Global feed doesn't go stale.</p>
        <p>
          Trill is still on beta. The UI is Mobile only, we recommend you use
          your phone or the browser dev tools. Desktop UI is on the works.
        </p>
        <p>
          If you have any feedback please reach out to us on Groups at
          ~hoster-dozzod-sortug/trill or here at ~polwex
        </p>
      </div>
    </Modal>
  );
}

export function Tooltip({ children, text, className }: any) {
  const [show, toggle] = useState(false);
  return (
    <div
      className={"tooltip-wrapper " + (className || "")}
      onMouseOver={() => toggle(true)}
      onMouseOut={() => toggle(false)}
    >
      {children}
      {show && <div className="tooltip">{text}</div>}
    </div>
  );
}
