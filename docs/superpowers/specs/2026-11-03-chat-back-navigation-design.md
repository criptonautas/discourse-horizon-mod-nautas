# Chat back navigation

## Rule

One "back" per screen, top left, one level up: chat → chat list → forum.

## Mobile, full-page chat

One top row, with the title and the chat's own actions only. The forum header's avatar
and notification bell are hidden on these screens.

| Screen | Top row | Back goes to |
|---|---|---|
| Chat list | `← Volver` + `CHATS` | The forum |
| Channel | `← Volver` + channel name + its actions | The list the chat belongs to |
| Personal chat | `← Volver` + person's name + its actions | The personal chats list |

- The back target inside a chat is the plugin's own (`getChannelsRoute`): it returns to
  channels, personal chats, browse or starred, depending on where the user came from.
- The bottom bar (channels, personal, threads, search) does not change.
- Long names keep the plugin's one-line `…` truncation.
- "Back" looks the same as in the docs and profile sidebars.

## Desktop, full-page chat

- Core's `BackToForum` above the chat sidebar, rendered in the `before-sidebar-sections`
  outlet only while the chat panel is active. It sits outside the scrolling area.
- The top right button keeps opening the floating chat.

## Floating chat

No change. The sidebar chat button keeps following each user's drawer or full-page
preference.

## Mechanism

- Theme only, no plugin changes. New rules go in `scss/mobile-stuff.scss` and `scss/main.scss`;
  the desktop link goes in `javascripts/discourse/api-initializers/`.
- Mobile: the chat's `.c-navbar-container` is placed in the forum header's row, and
  `.back-to-forum`, `.current-user` and the avatar are hidden when the screen has
  `.c-navbar__back-button`. The list keeps `.c-header`, with `.c-heading` shown there.
- If the plugin renames these classes, the layout falls back to today's two rows.

## Verification

Needs a signed-in session, because chat isn't visible anonymously:

- Each table row above at 375 and 320 px wide, in light and dark.
- A real phone with the keyboard open, iPhone included: the top row must stay in place.
- Whether the bottom bar shows inside a chat.
- Desktop: back link while scrolling a long channel list; opening and closing the floating chat.

If the keyboard moves the top row and it can't be fixed with CSS, stop and bring it back as a
design decision.
