// https://github.com/discourse/discourse/pull/31933#discussion_r2019739410
export function changedDescendants(old, cur, f, offset = 0) {
  const oldSize = old.childCount,
    curSize = cur.childCount;
  outer: for (let i = 0, j = 0; i < curSize; i++) {
    const child = cur.child(i);
    for (let scan = j, e = Math.min(oldSize, i + 5); scan < e; scan++) {
      if (old.child(scan) === child) {
        j = scan + 1;
        offset += child.nodeSize;
        continue outer;
      }
    }
    f(child, offset);
    if (j < oldSize && old.child(j).sameMarkup(child)) {
      changedDescendants(old.child(j), child, f, offset + 1);
    } else {
      child.nodesBetween(0, child.content.size, f, offset + 1);
    }
    offset += child.nodeSize;
  }
}
