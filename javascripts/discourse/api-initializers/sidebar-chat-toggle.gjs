import Component from "@glimmer/component";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { apiInitializer } from "discourse/lib/api";
import DButton from "discourse/ui-kit/d-button";
import ChatHeaderIconUnreadIndicator from "discourse/plugins/chat/discourse/components/chat/header/icon/unread-indicator";

// Chat toggle next to the light/dark selector, replacing the sidebar's "chat" panel
// switch button (hidden in main.scss). Opening mirrors core's header chat icon
// (chat/header/icon.gjs), so drawer vs full page follows the user's preference;
// unlike that icon, a second press closes the drawer instead of going full page.
//
// In the AI bot's panel it gives way to the bot's "new question", moved here from the
// top of the sidebar (hidden in main.scss), where it stacked under "back".
class SidebarChatToggle extends Component {
  @service appEvents;
  @service chat;
  @service chatStateManager;
  @service currentUser;
  @service header;
  @service router;
  @service sidebarState;

  get inAiPanel() {
    return this.sidebarState.isCurrentPanel("ai-conversations");
  }

  // Inside the full-page chat, "back" at the top of its sidebar leads out
  // (chat-sidebar-back.gjs), as on every other panel.
  get showChatToggle() {
    return !this.chatStateManager.isFullPageActive;
  }

  get isActive() {
    return this.chatStateManager.isActive;
  }

  // On a phone the sidebar is the hamburger dropdown, and it stayed open over the chat.
  // Through its own button, because that's what also releases the body scroll lock.
  closeHamburger() {
    if (this.header.hamburgerVisible) {
      document
        .querySelector(".header-sidebar-toggle button, #toggle-hamburger-menu")
        ?.click();
    }
  }

  // Same as discourse-ai's ai-bot-sidebar-new-conversation.gjs routeTo
  @action
  newQuestion() {
    this.closeHamburger();
    this.appEvents.trigger("discourse-ai:new-conversation-btn-clicked");

    if (this.router.currentRouteName !== "discourse-ai-bot-conversations") {
      this.router.transitionTo("/discourse-ai/ai-bot/conversations");
    } else {
      document.getElementById("ai-bot-conversations-input")?.focus();
    }
  }

  @action
  toggleChat() {
    this.closeHamburger();

    if (this.chatStateManager.isDrawerActive) {
      // same as the drawer's own close button (chat/navbar/close-drawer-button.gjs)
      this.chatStateManager.didCloseDrawer();
      this.chat.activeChannel = null;
    } else if (this.chatStateManager.isFullPageActive) {
      this.router.transitionTo(this.chatStateManager.lastKnownAppURL || "/");
    } else {
      if (this.chatStateManager.isDrawerPreferred) {
        this.chatStateManager.prefersDrawer();
      }
      this.router.transitionTo(
        this.chatStateManager.lastKnownChatURL || "/chat"
      );
    }
  }

  <template>
    {{#if this.inAiPanel}}
      {{#if this.currentUser}}
        <DButton
          class="btn-default sidebar-chat-toggle"
          @action={{this.newQuestion}}
          @icon="plus"
          @label="discourse_ai.ai_bot.conversations.new"
        />
      {{/if}}
    {{else if this.showChatToggle}}
      <DButton
        class="btn-default sidebar-chat-toggle
          {{if this.isActive 'sidebar-chat-toggle--active'}}"
        @action={{this.toggleChat}}
        @icon="d-chat"
        @label="chat.title_capitalized"
        @title={{if this.isActive "chat.close" "chat.title_capitalized"}}
      >
        {{! counts and the user's indicator preference are read by the component itself;
      it reads currentUser.user_option, so anonymous visitors don't get it }}
        {{#if this.currentUser}}
          <ChatHeaderIconUnreadIndicator />
        {{/if}}
      </DButton>
    {{/if}}
  </template>
}

export default apiInitializer((api) => {
  // lookup returns undefined when the chat plugin is off. Not userCanChat: anonymous
  // visitors read public channels too, and open them from here.
  if (!api.container.lookup("service:chat")) {
    return;
  }

  api.renderInOutlet("sidebar-footer-actions", SidebarChatToggle);
});
