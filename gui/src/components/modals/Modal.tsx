import useLocalState from "@/state/state";
import { useEffect, useRef, useState, type ReactNode } from "react";

function Modal({
  children,
  close,
}: {
  children: ReactNode;
  close?: () => void;
}) {
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
    if (!modalRef.current || !modalRef.current.contains(e.target as Node))
      if (close) close();
    setModal(null);
  }
  const modalRef = useRef<HTMLDivElement>(null);
  return (
    <div id="modal-background" onClick={clickAway}>
      <div id="modal" ref={modalRef}>
        {children}
      </div>
    </div>
  );
}
export default Modal;


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
