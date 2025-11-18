import Sidebar from "@/components/layout/Sidebar";
import useLocalState from "@/state/state";
import Feed from "@/pages/Feed";
import User from "@/pages/User";
import Settings from "@/pages/Settings";
import Thread from "@/pages/Thread";
import { Switch, Router, Redirect, Route } from "wouter";
import { P404 } from "./pages/Error";

export default function r() {
  const modal = useLocalState((s) => s.modal);
  return (
    <Switch>
      <Router base="/apps/nostrill">
        <Sidebar />
        <main>
          <Route path="/" component={toGlobal} />
          <Route path="/sets" component={Settings} />
          <Route path="/f" component={Feed} />
          <Route path="/f/:taip" component={Feed} />
          <Route path="/u/:user" component={User} />
          <Route path="/t/:host/:id" component={Thread} />
        </main>
        {modal && modal}
      </Router>
      <Route component={P404} />
    </Switch>
  );
}
function toGlobal() {
  return <Redirect to="/f" />;
}
