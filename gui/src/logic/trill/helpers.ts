import type { FullNode, Poast } from "@/types/trill";

export function toFlat(n: FullNode): Poast {
  return {
    ...n,
    children: !n.children
      ? []
      : Object.keys(n.children).map((c) => n.children[c].id),
  };
}
