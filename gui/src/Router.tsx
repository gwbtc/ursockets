import Sidebar from "@/components/layout/Sidebar";

// new
import Feed from "@/pages/Feed";
import Settings from "@/pages/Settings";
import Thread from "@/pages/Thread";
import { Switch, Router, Redirect, Route } from "wouter";

export default function r() {
  return (
    <Switch>
      <Router base="/apps/nostrill">
        <Sidebar />
        <main>
          <Route path="/" component={toGlobal} />
          <Route path="/sets" component={Settings} />
          <Route path="/feed/:taip" component={Feed} />
          <Route path="/feed/:host/:id" component={Thread} />
        </main>
      </Router>
      <Route component={P404} />
    </Switch>
  );
}
function toGlobal() {
  return <Redirect to="/feed/nostr" />;
}

export function P404() {
  return <h1 className="x-center">404</h1>;
}
export function ErrorPage({ msg }: { msg: string }) {
  return (
    <div>
      <P404 />
      <h3>{msg}</h3>
    </div>
  );
}
