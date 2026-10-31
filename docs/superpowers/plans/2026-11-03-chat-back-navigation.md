# Chat back navigation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** One "back" per chat screen, top left, one level up: chat → chat list → forum.

**Architecture:** Theme only. Desktop reuses core's `BackToForum` in a sidebar outlet. Mobile is CSS: the chat's navbar is fixed over the forum header's row. Any plugin class rename falls back to today's two rows.

**Tech Stack:** Discourse theme component, Glimmer `.gjs`, SCSS.

**Spec:** `docs/superpowers/specs/2026-11-03-chat-back-navigation-design.md`

## Global Constraints

- No plugin or core changes; no `{{{ }}}` or `innerHTML`.
- The floating chat and the sidebar chat toggle don't change.
- The repo has no automated test for chat UI. Checks are `npx prettier --check`, `npx stylelint`, `npx eslint`, then Task 3 by hand with a signed-in session.
- Commits: short subject, no trailer, explicit paths only.

---

### Task 1: Desktop back link

**Files:**
- Create: `javascripts/discourse/api-initializers/chat-sidebar-back.gjs`

**Interfaces:**
- Consumes: outlet `before-sidebar-sections`; `service:sidebar-state` `currentPanelKey`; `service:chat-state-manager` `lastKnownAppURL`; core `discourse/components/sidebar/back-to-forum` (`@href`).
- Produces: `.sidebar-sections__back-to-forum` above the chat panel. Task 2 scopes it with `.chat-sidebar-back`.

- [ ] **Step 1: Create the initializer**

```gjs
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
    return this.site.desktopView && this.sidebarState.currentPanelKey === "chat";
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
```

- [ ] **Step 2: Add its spacing at the end of the chat rules in `scss/main.scss`**

```scss
.chat-sidebar-back {
  padding: var(--space-3) var(--space-4) var(--space-2);
}
```

- [ ] **Step 3: Lint**

Run: `npx eslint javascripts/discourse/api-initializers/chat-sidebar-back.gjs && npx prettier --check javascripts/discourse/api-initializers/chat-sidebar-back.gjs scss/main.scss && npx stylelint scss/main.scss`
Expected: no errors.

- [ ] **Step 4: Commit**

```bash
git add javascripts/discourse/api-initializers/chat-sidebar-back.gjs scss/main.scss
git commit -m "Add a back link above the chat sidebar"
```

### Task 2: Mobile single top row

**Files:**
- Modify: `scss/mobile-stuff.scss` (append)

**Interfaces:**
- Consumes: core `.mobile-view`, `.has-full-page-chat`, `--header-offset`; plugin `.c-navbar-container`, `.c-navbar__back-button`, `.back-to-forum`; core `.btn-sidebar-toggle`, `.d-header-icons`.
- Produces: no new classes.

- [ ] **Step 1: Append the rules**

```scss
// Full-page chat on a phone: one top row. The chat's navbar moves into the forum header's
// row, which keeps its background as the "you are here", and profile icons leave so they
// don't mix with the chat's. Class renames in the plugin fall back to two rows.
.mobile-view.has-full-page-chat,
.mobile-view .has-full-page-chat {
  .btn-sidebar-toggle,
  .d-header-icons {
    display: none;
  }

  .full-page-chat .c-navbar-container,
  .c-routes .c-navbar-container {
    position: fixed;
    top: 0;
    right: 0;
    left: 7rem; // room for the list's "← Volver"
    z-index: 1001; // over the header (1000)
    height: var(--header-offset);
    align-items: center;
    border: 0;
    background: transparent;
  }

  // Inside a chat the navbar's own back is the only one, so it takes the whole row.
  &:has(.c-navbar__back-button) {
    .back-to-forum {
      display: none;
    }

    .c-routes .c-navbar-container {
      left: 0;
    }
  }

  // Labelled like docs and profile; title is the plugin's translated "back".
  .c-navbar__back-button::after {
    content: attr(title);
    margin-left: var(--space-1);
    color: var(--primary);
  }
}
```

- [ ] **Step 2: Lint**

Run: `npx prettier --check scss/mobile-stuff.scss && npx stylelint scss/mobile-stuff.scss`
Expected: no errors.

- [ ] **Step 3: Commit**

```bash
git add scss/mobile-stuff.scss
git commit -m "Merge the mobile chat navbar into the header row"
```

### Task 3: Signed-in verification and docs

**Files:**
- Modify: `README.md`, `README.es.md` (`mobile-stuff.scss` row; add `chat-sidebar-back.gjs`)

- [ ] **Step 1: Install the branch on a test instance or update the component, signed in**

- [ ] **Step 2: Check at 375 and 320 px, light and dark**

Channels list, personal list, channel, personal chat, thread: one back arrow, no avatar or bell, name truncates, actions tappable, unread dot visible, messages not hidden under the row.

- [ ] **Step 3: Check on a real phone with the keyboard open, iPhone included**

Expected: the top row stays in place. If it moves and CSS can't fix it, stop and bring it to the user as a design decision.

- [ ] **Step 4: Check whether the bottom bar shows inside a chat; report it**

- [ ] **Step 5: Desktop**

Scroll a long channel list: back stays visible and goes to the last forum page. The top right button still opens the floating chat, and the sidebar toggle still follows each user's preference.

- [ ] **Step 6: Update both READMEs, commit, push**

```bash
git add README.md README.es.md
git commit -m "DOCS: chat back navigation"
git push origin main
```
