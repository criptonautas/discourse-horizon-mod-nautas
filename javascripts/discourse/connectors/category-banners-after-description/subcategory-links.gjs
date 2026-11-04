import Component from "@glimmer/component";
import { trustHTML } from "@ember/template";
import categoryListSubcategories from "discourse/helpers/category-list-subcategories";
import { categoryBadgeHTML } from "discourse/ui-kit/helpers/d-category-link";

// The subcategories inside the category banner (discourse-category-banners), under the
// description: a row on wide screens, pills on phones (scss/categories-view.scss). Replaces core's subcategory boxes, whose fixed grid
// left gaps with fewer than four. Same subcategories as those boxes (page "category").
export default class SubcategoryLinks extends Component {
  get subcategories() {
    return categoryListSubcategories(this.args.outletArgs.category, {
      page: "category",
    });
  }

  badge(category) {
    return trustHTML(
      categoryBadgeHTML(category, { allowUncategorized: true, link: false })
    );
  }

  <template>
    {{#if this.subcategories.length}}
      <nav class="subcategory-links">
        {{#each this.subcategories as |category|}}
          <a class="subcategory-links__item" href={{category.url}}>
            {{this.badge category}}
          </a>
        {{/each}}
      </nav>
    {{/if}}
  </template>
}
