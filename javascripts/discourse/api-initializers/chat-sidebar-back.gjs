import Component from "@glimmer/component";
import { service } from "@ember/service";
import BackToForum from "discourse/components/sidebar/back-to-forum";
import { apiInitializer } from "discourse/lib/api";

// Full-page chat had no "back" at the top left, unlike docs and profile. The outlet
// sits above the scrolling sections, so the link stays in view.
class ChatSidebarBack extends Component {
  @service chatStateManager;
  @service sidebarState;
  @service site;

  get shouldRender() {
    return (
      this.site.desktopView && this.sidebarState.currentPanelKey === "chat"
    );
  }

  <template>
    {{#if this.shouldRender}}
      <div class="chat-sidebar-back">
        <BackToForum @href={{this.chatStateManager.lastKnownAppURL}} />
      </div>
    {{/if}}
  </template>
}

export default apiInitializer((api) => {
  // lookup returns undefined when the chat plugin is off
  if (!api.container.lookup("service:chat")?.userCanChat) {
    return;
  }

  api.renderInOutlet("before-sidebar-sections", ChatSidebarBack);
});
