import useLocalState from "@/state/state";
import { useEffect } from "react";
import Icon from "@/components/Icon";
import "@/styles/Lightbox.css";

interface LightboxProps {
  src: string;
  type?: "image" | "video";
}

export default function Lightbox({ src, type = "image" }: LightboxProps) {
  const { setModal } = useLocalState((s) => ({ setModal: s.setModal }));

  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === "Escape") setModal(null);
    };
    window.addEventListener("keydown", handleKeyDown);
    return () => window.removeEventListener("keydown", handleKeyDown);
  }, [setModal]);

  return (
    <div className="lightbox-overlay" onClick={() => setModal(null)}>
      <button className="lightbox-close" onClick={() => setModal(null)}>
        <Icon name="settings" size={24} /> {/* Using settings icon as close for now, or finding 'x' */}
      </button>
      <div className="lightbox-content" onClick={(e) => e.stopPropagation()}>
        {type === "video" ? (
          <video src={src} controls autoPlay className="lightbox-media" />
        ) : (
          <img src={src} alt="Full screen" className="lightbox-media" />
        )}
      </div>
    </div>
  );
}
