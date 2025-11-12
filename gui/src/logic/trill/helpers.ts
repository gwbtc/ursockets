import type { FullNode, Poast } from "@/types/trill";

export function toFlat(n: FullNode): Poast {
  return {
    ...n,
    children: !n.children
      ? []
      : Object.keys(n.children).map((c) => n.children[c].id),
  };
}

type res = { threadChildren: FullNode[]; replies: FullNode[] };
const bunt: res = { threadChildren: [], replies: [] };
export function extractThread(node: FullNode): res {
  if (!node.children) return bunt;
  const r = Object.keys(node.children)
    .sort()
    .reduce((acc, index) => {
      const n = node.children[index];
      // if (typeof n.post === "string") return acc;
      const nn = n as FullNode;
      return n.author !== node.author
        ? { ...acc, replies: [...acc.replies, nn] }
        : {
            ...acc,
            threadChildren: [
              ...acc.threadChildren,
              nn,
              ...extractThread(nn).threadChildren,
            ],
          };
    }, bunt);
  return r;
}
