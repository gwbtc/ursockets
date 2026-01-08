import Modal from "./Modal";
import useLocalState from "@/state/state";
import Composer from "@/components/composer/Composer";

export default function () {
  const { setComposerData } = useLocalState((s) => ({
    setComposerData: s.setComposerData,
  }));
  function close() {
    setComposerData(null);
  }
  return (
    <Modal close={close}>
      <div id="composer-modal">
        <Composer />
      </div>
    </Modal>
  );
}
