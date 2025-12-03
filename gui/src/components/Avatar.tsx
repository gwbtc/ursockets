import useLocalState from "@/state/state";
import Sigil from "./Sigil";
import { isValidPatp } from "urbit-ob";
import type { UserProfile, UserType } from "@/types/nostrill";
import Icon from "@/components/Icon";
import UserModal from "./modals/UserModal";

export default function ({
  user,
  size,
  color,
  noClickOnName,
  profile,
  picOnly = false,
}: {
  user: UserType;
  size: number;
  color?: string;
  noClickOnName?: boolean;
  profile?: UserProfile;
  picOnly?: boolean;
}) {
  const { setModal } = useLocalState((s) => ({ setModal: s.setModal }));
  // TODO revisit this when %whom updates
  const avatarInner = profile ? (
    <img src={profile.picture} width={size} height={size} />
  ) : "urbit" in user && isValidPatp(user.urbit) ? (
    <Sigil patp={user.urbit} size={size} bg={color} />
  ) : (
    <Icon name="comet" />
  );
  const avatar = (
    <div className="avatar cp" onClick={openModal}>
      {avatarInner}
    </div>
  );
  if (picOnly) return avatar;

  const tooLong = (s: string) => (s.length > 15 ? " too-long" : "");
  function openModal(e: React.MouseEvent) {
    if (noClickOnName) return;
    e.stopPropagation();
    setModal(<UserModal user={user} />);
  }
  const name = (
    <div className="name cp" role="link" onMouseUp={openModal}>
      {profile ? (
        <p>{profile.name}</p>
      ) : "urbit" in user ? (
        <p className={"p-only" + tooLong(user.urbit)}>
          {user.urbit.length > 28 ? "Anon" : user.urbit}
        </p>
      ) : (
        <p className={"p-only" + tooLong(user.nostr)}>{user.nostr}</p>
      )}
    </div>
  );
  return (
    <div className="ship-avatar">
      {avatar}
      {name}
    </div>
  );
}
