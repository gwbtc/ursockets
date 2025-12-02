import { useState, useEffect, useRef } from "react";
import { useLocation } from "wouter";
import useLocalState from "@/state/state";
import Icon, { type IconName } from "@/components/Icon";
import Avatar from "@/components/Avatar";
import "@/styles/CommandPalette.css";
import { Search } from "lucide-react";

interface CommandItem {
  id: string;
  title: string;
  subtitle?: string;
  icon?: IconName;
  type: "page" | "user" | "action";
  action: () => void;
}

export default function CommandPalette() {
  const [isOpen, setIsOpen] = useState(false);
  const [query, setQuery] = useState("");
  const [selectedIndex, setSelectedIndex] = useState(0);
  const [_, navigate] = useLocation();
  const { profiles, api } = useLocalState((s) => ({
    profiles: s.profiles,
    api: s.api,
  }));
  const inputRef = useRef<HTMLInputElement>(null);
  const listRef = useRef<HTMLDivElement>(null);

  // Toggle open/close
  useEffect(() => {
    const onKeydown = (e: KeyboardEvent) => {
      if ((e.metaKey || e.ctrlKey) && e.key === "k") {
        e.preventDefault();
        setIsOpen((prev) => !prev);
        setQuery("");
        setSelectedIndex(0);
      }
      if (e.key === "Escape") {
        setIsOpen(false);
      }
    };
    window.addEventListener("keydown", onKeydown);
    return () => window.removeEventListener("keydown", onKeydown);
  }, []);

  // Focus input when opened
  useEffect(() => {
    if (isOpen) {
      setTimeout(() => inputRef.current?.focus(), 50);
    }
  }, [isOpen]);

  // Generate items based on query
  const items: CommandItem[] = [];

  // 1. Pages
  const pages: CommandItem[] = [
    { id: "home", title: "Home Feed", icon: "home", type: "page", action: () => navigate("/f") },
    { id: "notifications", title: "Notifications", icon: "bell", type: "page", action: () => navigate("/notifications") },
    { id: "profile", title: "My Profile", icon: "profile", type: "page", action: () => navigate(`/u/${api?.airlock.our}`) },
    { id: "settings", title: "Settings", icon: "settings", type: "page", action: () => navigate("/sets") },
    { id: "pals", title: "Pals", icon: "pals", type: "page", action: () => navigate("/pals") },
  ];

  if (query === "") {
    items.push(...pages);
  } else {
    items.push(...pages.filter(p => p.title.toLowerCase().includes(query.toLowerCase())));
  }

  // 2. Users
  if (query.length > 1) {
    const userMatches: CommandItem[] = [];
    // Convert Map to Array for filtering
    Array.from(profiles.entries()).forEach(([patp, profile]) => {
        const name = profile.name || patp;
        if (
            name.toLowerCase().includes(query.toLowerCase()) || 
            patp.toLowerCase().includes(query.toLowerCase())
        ) {
            userMatches.push({
                id: patp,
                title: profile.name || patp,
                subtitle: patp,
                type: "user",
                action: () => navigate(`/u/${patp}`)
            });
        }
    });
    // Limit to top 5 users
    items.push(...userMatches.slice(0, 5));
  }

  // Navigation
  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === "ArrowDown") {
        e.preventDefault();
        setSelectedIndex(prev => (prev + 1) % items.length);
    } else if (e.key === "ArrowUp") {
        e.preventDefault();
        setSelectedIndex(prev => (prev - 1 + items.length) % items.length);
    } else if (e.key === "Enter") {
        e.preventDefault();
        if (items[selectedIndex]) {
            items[selectedIndex].action();
            setIsOpen(false);
        }
    }
  };
  
  // Scroll selected into view
  useEffect(() => {
      if (listRef.current) {
          const selected = listRef.current.children[selectedIndex] as HTMLElement;
          if (selected) {
              selected.scrollIntoView({ block: "nearest" });
          }
      }
  }, [selectedIndex]);

  if (!isOpen) return null;

  return (
    <div className="command-palette-overlay" onClick={() => setIsOpen(false)}>
      <div className="command-palette" onClick={(e) => e.stopPropagation()}>
        <div className="cp-input-wrapper">
            <Search size={18} color="#888" />
            <input 
                ref={inputRef}
                value={query}
                onChange={(e) => { setQuery(e.target.value); setSelectedIndex(0); }}
                onKeyDown={handleKeyDown}
                placeholder="Type a command or search..."
                autoFocus
            />
        </div>
        <div className="cp-list" ref={listRef}>
            {items.length === 0 ? (
                <div className="cp-empty">No results found.</div>
            ) : (
                items.map((item, i) => (
                    <div 
                        key={item.id}
                        className={`cp-item ${i === selectedIndex ? "selected" : ""}`}
                        onClick={() => { item.action(); setIsOpen(false); }}
                        onMouseEnter={() => setSelectedIndex(i)}
                    >
                        {item.type === "user" ? (
                            <Avatar user={{ urbit: item.id }} size={24} />
                        ) : (
                            <div className="cp-icon">
                                {item.icon && <Icon name={item.icon} size={16} />}
                            </div>
                        )}
                        <div className="cp-info">
                            <div className="cp-title">{item.title}</div>
                            {item.subtitle && <div className="cp-subtitle">{item.subtitle}</div>}
                        </div>
                        {item.type === "page" && <span className="cp-hint">Jump to</span>}
                    </div>
                ))
            )}
        </div>
        <div className="cp-footer">
            <span><kbd>↑</kbd> <kbd>↓</kbd> to navigate</span>
            <span><kbd>↵</kbd> to select</span>
            <span><kbd>esc</kbd> to close</span>
        </div>
      </div>
    </div>
  );
}
