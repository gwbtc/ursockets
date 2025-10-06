import Modal from "./Modal";
import Avatar from "../Avatar";
import Icon from "@/components/Icon";
import useLocalState from "@/state/state";
import { useLocation } from "wouter";
import toast from "react-hot-toast";
import type { UserType } from "@/types/nostrill";

export default function ({
  user,
  userString,
}: {
  user: UserType;
  userString: string;
}) {
  const { setModal, api, pubkey } = useLocalState((s) => ({
    setModal: s.setModal,
    api: s.api,
    pubkey: s.pubkey,
  }));
  const [_, navigate] = useLocation();
  function close() {
    setModal(null);
  }
  const itsMe =
    "urbit" in user
      ? user.urbit === api?.airlock.our
      : "nostr" in user
        ? user.nostr === pubkey
        : false;
  async function copy(e: React.MouseEvent) {
    e.stopPropagation();
    await navigator.clipboard.writeText(userString);
    toast.success("Copied to clipboard");
  }
  return (
    <Modal close={close}>
      <div id="ship-modal">
        <div className="flex">
          <Avatar user={user} userString={userString} size={60} />
          <Icon
            name="copy"
            size={20}
            className="copy-icon cp"
            onClick={copy}
            title="Copy ship name"
          />
        </div>
        <div className="buttons f1">
          <button onClick={() => navigate(`/feed/${userString}`)}>Feed</button>
          <button onClick={() => navigate(`/pals/${userString}`)}>
            Profile
          </button>
          {itsMe && (
            <>
              <button onClick={() => navigate(`/chat/dm/${userString}`)}>
                DM
              </button>
            </>
          )}
        </div>
      </div>
    </Modal>
  );
}
