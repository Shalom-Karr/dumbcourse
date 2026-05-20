# Changelog

All notable changes to the `discourse-mod` plugin (module
`DiscourseModCategories`) are recorded here.

## Unreleased

### Moderator-notes header-level indicators

- Added a staff-only **header shield pip** showing the moderator-notes
  unread count in the page header next to the avatar. Visible whenever
  the user menu is closed and `mod_note_unread_count > 0`; clicking it
  opens the user menu on the shield tab. Rendered via the
  `before-header-panel` plugin outlet so the indicator works across
  Discourse versions.
- Added a **browser tab-title prefix** (`(N) original-title`) mirroring
  the bell's behaviour, so an inactive browser tab still announces unread
  moderator notes. Implemented as a pure `applyUnreadPrefix` helper +
  a `document.title` setter wrapper so route transitions keep the prefix.
- Both indicators are reactive: the count updates on initial bootstrap,
  drops to 0 when the staff member opens the shield tab, and bumps live
  on new notes via a dedicated `/mod-note-unread-count/{user_id}`
  MessageBus channel — published from `notify_staff_of_note` (a
  `{ delta: 1 }` per recipient) and from `notes_feed_seen` (a
  `{ reset: true }` to the staff member themselves, so multi-tab
  sessions stay in lockstep).

### Per-topic prompt checklist — modes, frequency, audience cap

- Added a **Statement** mode to the per-topic prompt checklist: a single
  Markdown-cooked message + a single accept button. Replaces the legacy
  per-topic before-reply prompt as the supported way to set it.
- Added a **Frequency** selector (`once` — the default, per-user-version-
  tracked — or `every_reply` — always prompt; no acceptance recorded).
- Added a **`max_tl`** trust-level audience cap to the per-topic prompt,
  mirroring the global checklist's `max_tl`. Staff always see the prompt
  regardless of cap; targeted checklists still override.
- Removed the legacy **Before-reply prompt** textarea + audience combo-box
  from the topic admin "Moderator Actions" modal. Staff now configure
  the per-topic prompt exclusively through the dedicated **Prompt
  Checklist** editor.
- The legacy `mod_topic_reply_prompt` and `mod_topic_reply_prompt_max_tl`
  custom fields stay registered — opening the new editor on a topic that
  still has them pre-fills the editor in Statement mode and saving
  clears the legacy fields. The legacy composer gate continues to work
  for any unmigrated topic.

## 0.1.0

Initial release. The plugin gives moderators a set of category and
per-topic controls without granting full admin access.

### Category management

- Moderators can create, edit, and delete categories — abilities normally
  reserved for admins — via prepended `Guardian` overrides.
- Category deletion by a moderator is limited to empty categories with no
  sub-categories, and never the uncategorized category.
- Gated by the `mod_categories_enabled` site setting (default off), which
  is also the plugin's master switch.

### Moderator topic tools

Set from the topic admin (wrench) menu → **Moderator Actions** modal, which
is split into *What users see* and *Moderation tools* sections and confirms
with a save toast:

- **Per-topic footer message** — a moderator-trusted HTML banner pinned at
  the bottom of a topic. Site setting `topic_footer_message_enabled`
  (default on).
- **Per-topic reply prompt** — a confirm-or-go-back dialog shown before a
  user replies, with a trust-level cap (a Discourse combo-box) and
  clickable links in the message. Site setting `topic_reply_prompt_enabled`
  (default on).
- **Per-topic reply approval** — flags a topic so non-staff replies route
  to the review queue instead of publishing directly, enforced by a
  `NewPostManager` handler.
- **Private moderator note** — a staff-only note shown like a post (author,
  avatar, relative timestamp), positionable at the top or bottom of the
  topic, with a staff-only reply thread. Never serialized to non-staff.

### Per-category new-topic prompt

- A confirm-or-go-back dialog shown before a user starts a new topic in a
  category, set on the category Settings tab with a live preview, a
  trust-level cap, and clickable links. Site setting
  `precheck_new_topic_enabled` (default on).

### Pin a post to the bottom

- Moderators can pin any post so a rendered copy also appears at the end of
  the topic with a pin badge; the original is badged in place. If the
  pinned post is already last, only the badge shows.

### Moderator-note notifications and user-menu tab

- Staff get a shield tab in the user menu listing moderator notes from
  across the forum, with an unread count.
- Setting a note or replying to one sends a real Discourse notification
  (bell + live pop-up) to the other staff members, linking to the topic.

### First-post checklist

- A forum-wide checklist a not-yet-trusted user must tick before their
  first post. Configured by staff in a modal opened from the **First-post
  checklist** link in the sidebar's Community section.
- Each item is a line of text with an optional link. Staff can set a
  trust-level audience (TL0, TL0–TL1, or TL0–TL2) and custom accept-button
  text.
- The checklist is versioned: every save bumps the version and re-prompts
  everyone who already accepted.
- Every acceptance is written to an append-only audit log (latest 500
  entries) shown in the editor.

### Permissions

- All moderator-set content is gated server-side by `Guardian` checks
  (`can_manage_mod_messages?` / `can_edit_category?`); regular and
  anonymous users receive a `403`.
