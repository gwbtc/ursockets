import { RADIO, versionNum } from "@/logic/constants";
import { useLocation } from "wouter";
import useLocalState from "@/state/state";
import logo from "@/assets/icons/logo.png";
import Icon from "@/components/Icon";
import { ThemeSwitcher } from "@/styles/ThemeSwitcher";

function SlidingMenu() {
  const [_, navigate] = useLocation();
  const { api, notifications } = useLocalState((s) => ({
    api: s.api,
    notifications: s.notifications,
  }));

  function goto(to: string) {
    navigate(to);
  }

  return (
    <div id="left-menu">
      <div id="logo">
        <img src={logo} />
        <h3> Nostrill </h3>
      </div>
      <h3>Feeds</h3>
      <div className="opt" role="link" onClick={() => goto(`/f`)}>
        <Icon name="home" size={20} />
        <div>Home</div>
      </div>
      <div
        className="opt notification-item"
        role="link"
        onClick={() => goto("/notifications")}
      >
        <div className="notification-icon-wrapper">
          <Icon name="bell" size={20} />
          {notifications.length > 0 && (
            <span className="notification-badge">
              {notifications.length > 99 ? "99+" : notifications.length}
            </span>
          )}
        </div>
        <div>Notifications</div>
      </div>
      <hr />

      {/*<div
        className="opt tbd"
        role="link"
        // onClick={() => setModal(<p>lmao</p>)}
      >
        <Icon name="messages" size={20} />
        <div>Messages</div>
      </div>
    */}
      <div className="opt" role="link" onClick={() => goto("/pals")}>
        <Icon name="pals" size={20} />
        <div>Pals</div>
      </div>
      <hr />
      <div
        className="opt"
        role="link"
        onClick={() => goto(`/u/${api!.airlock.our}`)}
      >
        <Icon name="profile" size={20} />
        <div>Profile</div>
      </div>
      <hr />
      <div className="opt" role="link" onClick={() => goto("/sets")}>
        <Icon name="settings" size={20} />
        <div>Settings</div>
      </div>
      <ThemeSwitcher />
    </div>
  );
}
export default SlidingMenu;
