import Sidebar from "@/components/layout/Sidebar";
import useLocalState from "@/state/state";
import Feed from "@/pages/Feed";
import User from "@/pages/User";
import Settings from "@/pages/Settings";
import Follows from "@/pages/Follows";
import Thread, { NostrThreadLoader } from "@/pages/Thread";
import { Switch, Router, Redirect, Route } from "wouter";
import { P404 } from "./pages/Error";
import WelcomeModal from "@/components/modals/WelcomeModal";
import RelayStatusButton from "@/components/RelayStatusButton";
import { useEffect } from "react";
import Modal from "./components/modals/Modal";
import toast from "react-hot-toast";
import RelayDroppedDialog from "./components/modals/RelayDropped";

const WELCOME_SHOWN_KEY = "nostrill-welcome-shown";

export default function r() {
  const { modal, setModal, dropped, dismiss } = useLocalState((s) => ({
    modal: s.modal,
    setModal: s.setModal,
    dropped: s.lastDroppedWs,
    dismiss: s.dismissDroppedWs,
  }));

  useEffect(() => {
    const hasSeenWelcome = localStorage.getItem(WELCOME_SHOWN_KEY);
    if (!hasSeenWelcome) {
      setModal(<WelcomeModal />);
      localStorage.setItem(WELCOME_SHOWN_KEY, "true");
    }
  }, []);

  useEffect(() => {
    if (!dropped) return;
    setModal(<RelayDroppedDialog url={dropped} />);
  }, [dropped]);
  return (
    <Switch>
      <Router base="/apps/nostrill">
        <Sidebar />
        <RelayStatusButton />
        <main>
          <Route path="/" component={toMain} />
          <Route path="/sets" component={Settings} />
          <Route path="/fols" component={Follows} />
          <Route path="/f" component={Feed} />
          <Route path="/f/:taip" component={Feed} />
          <Route path="/u/:user" component={User} />
          <Route path="/t/u/:host/:id" component={Thread} />
          <Route path="/t/n/:id" component={NostrThreadLoader} />
        </main>
        {modal && <Modal close={() => setModal(null)}>{modal}</Modal>}
      </Router>
      <Route component={P404} />
    </Switch>
  );
}
function toMain() {
  return <Redirect to="/f" />;
}
