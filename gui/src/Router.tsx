import Sidebar from "@/components/layout/Sidebar";
import useLocalState from "@/state/state";
import Feed from "@/pages/Feed";
import User from "@/pages/User";
import Settings from "@/pages/Settings";
import Thread, { NostrThreadLoader } from "@/pages/Thread";
import { Switch, Router, Redirect, Route } from "wouter";
import { P404 } from "./pages/Error";
import WelcomeModal from "@/components/modals/WelcomeModal";
import { useEffect } from "react";

const WELCOME_SHOWN_KEY = "nostrill-welcome-shown";

export default function r() {
  const { modal, setModal } = useLocalState((s) => ({
    modal: s.modal,
    setModal: s.setModal,
  }));

  useEffect(() => {
    const hasSeenWelcome = localStorage.getItem(WELCOME_SHOWN_KEY);
    if (!hasSeenWelcome) {
      setModal(<WelcomeModal />);
      localStorage.setItem(WELCOME_SHOWN_KEY, "true");
    }
  }, []);

  return (
    <Switch>
      <Router base="/apps/nostrill">
        <Sidebar />
        <main>
          <Route path="/" component={toMain} />
          <Route path="/sets" component={Settings} />
          <Route path="/f" component={Feed} />
          <Route path="/f/:taip" component={Feed} />
          <Route path="/u/:user" component={User} />
          <Route path="/t/:host/:id" component={Thread} />
          <Route path="/t/:id" component={NostrThreadLoader} />
        </main>
        {modal && modal}
      </Router>
      <Route component={P404} />
    </Switch>
  );
}
function toMain() {
  return <Redirect to="/f" />;
}
