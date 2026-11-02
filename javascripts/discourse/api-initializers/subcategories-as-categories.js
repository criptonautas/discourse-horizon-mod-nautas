import { apiInitializer } from "discourse/lib/api";

// Lets a category sit inside another and still get its own box on /categories. The list
// only keeps top-level categories, so the chosen parents' children are added after them.
// shortcut: core's loadMore skips this transformer, so pages after the first aren't
// expanded; move to a server filter if /categories ever paginates here.
export default apiInitializer((api) => {
  const parentIds = settings.subcategories_as_categories
    .split("|")
    .filter(Boolean)
    .map(Number);

  if (!parentIds.length) {
    return;
  }

  api.registerValueTransformer(
    "category-list-attributes",
    ({ value, context }) => {
      if (context.parentCategory) {
        return value;
      }

      const site = api.container.lookup("service:site");
      value.categories = value.categories.flatMap((category) =>
        parentIds.includes(category.id)
          ? [
              category,
              ...site.categories.filter(
                (child) => child.parent_category_id === category.id
              ),
            ]
          : [category]
      );
      return value;
    }
  );
});
