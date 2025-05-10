import type { V1Menu } from '@gosaas/api';
import { MenuServiceApi } from '@gosaas/api';
export type MenuWithChildren = {
  children?: MenuWithChildren[];
} & V1Menu;

export async function getTreeData(): Promise<MenuWithChildren[]> {
  const resp = await new MenuServiceApi().menuServiceListMenu2({
    body: { pageOffset: 0, pageSize: -1 },
  });
  const all = resp.data?.items ?? [];
  //get children
  const findChildren = (parent = '') => {
    const children = all
      .filter((p) => p.parent === parent)
      .sort((a, b) => (a.priority ?? 0) - (b.priority ?? 0));
    for (const c of children) {
      (c as MenuWithChildren).children = findChildren(c.id ?? '');
    }
    if (children.length === 0) {
      return undefined;
    }
    return children;
  };
  const tree = findChildren('') ?? [];
  return tree;
}
