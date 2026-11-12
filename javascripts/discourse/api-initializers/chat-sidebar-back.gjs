import Component from "@glimmer/component";
import { getOwner } from "@ember/owner";
import { service } from "@ember/service";
import BackToForum from "discourse/components/sidebar/back-to-forum";
import { apiInitializer } from "discourse/lib/api";
import getURL from "discourse/lib/get-url";

// Full-page chat and the AI bot had no "back" at the top left, unlike docs, profile and
// admin: the same link, on phones too (their sidebar is the hamburger dropdown there).
// discourse-ai draws its own only when the bot is not in the header
// (ai_bot_add_to_header), so ours covers the other case. Sticky in scss/main.scss.
class SidebarBack extends Component {
  @service sidebarState;
  @service siteSettings;

  // Looked up, not injected: either plugin may be off.
  get chatStateManager() {
    return getOwner(this).lookup("service:chat-state-manager");
  }

  get aiManager() {
    return getOwner(this).lookup("service:ai-conversations-sidebar-manager");
  }

  // Chat by route too: coming from the bot, the panel can still be the bot's.
  get inChat() {
    return (
      this.chatStateManager?.isFullPageActive ||
      this.sidebarState.currentPanelKey === "chat"
    );
  }

  get inBot() {
    return (
      this.aiManager &&
      this.siteSettings.ai_bot_add_to_header &&
      this.sidebarState.currentPanelKey === "ai-conversations"
    );
  }

  get href() {
    if (this.inChat) {
      return this.chatStateManager.lastKnownAppURL || getURL("/");
    }
    if (this.inBot) {
      return getURL(this.aiManager.lastKnownAppURL || "/");
    }
  }

  <template>
    {{#if this.href}}
      <div class="chat-sidebar-back">
        <BackToForum @href={{this.href}} />
      </div>
    {{/if}}
  </template>
}

export default apiInitializer((api) => {
  api.renderInOutlet("before-sidebar-sections", SidebarBack);
});
