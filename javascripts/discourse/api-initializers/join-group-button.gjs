import GroupMembershipButton from "discourse/components/group-membership-button";
import { apiInitializer } from "discourse/lib/api";
import DiscourseURL from "discourse/lib/url";

// Core's group membership button inside a post, so readers join (or request to join)
// without leaving the topic: [wrap=join-group group=lideres][/wrap]. Join or request
// follows the group's own settings; who sees it can be narrowed in scss/groups.scss.
const JoinGroup = <template>
  <GroupMembershipButton
    @model={{@data.group}}
    @showLogin={{@data.showLogin}}
    class="join-group-wrap"
  />
</template>;

export default apiInitializer((api) => {
  const store = api.container.lookup("service:store");
  const showLogin = () => DiscourseURL.routeTo("/login");

  api.decorateCookedElement((element, helper) => {
    element
      .querySelectorAll('.d-wrap[data-wrap="join-group"][data-group]')
      .forEach(async (wrap) => {
        try {
          const group = await store.find("group", wrap.dataset.group);
          helper.renderGlimmer(wrap, JoinGroup, { group, showLogin });
        } catch {
          // A group the reader can't see renders nothing
        }
      });
  });
});
