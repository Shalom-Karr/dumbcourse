# Features

`discourse-mod` ("Mod") is a Discourse plugin that gives moderators a set of per-topic and per-category controls without needing admin access. This page lists everything the plugin adds; each feature has its own page with full details.

## Moderator category management

Lets the built-in moderators group create, edit, and delete categories — abilities normally reserved for admins. This is also the plugin's master switch (`mod_categories_enabled`). See [Category management](categories.md) and [`mod_categories_enabled`](mod-categories-enabled.md).

## Per-topic footer message

A moderator-set message shown in an official-notice box (shield icon + "Moderator message" label) at the bottom of a single topic, cooked as Markdown. See [Per-topic footer message](topic-footer-message.md).

## Per-category new-topic prompt

A confirm-or-go-back dialog shown to a user before they post a new topic in a category. The message is set per category by a moderator, and can be limited to users at or below a chosen trust level (e.g. only TL0 and TL1) via a Discourse combo-box. The category Settings field shows a live preview of the dialog, and URLs in the message render as clickable links. See [Per-category new-topic prompt](precheck-new-topic.md).

## Per-topic reply prompt (superseded)

Originally a stand-alone confirm-or-go-back dialog shown to a user before they reply to a topic. **This feature now lives under the [Per-topic prompt checklist](topic-prompt-checklist.md) entry in Statement mode** — staff configure it from the topic admin (wrench) menu → **Prompt Checklist**. The legacy `mod_topic_reply_prompt` field still works for any topic that hasn't been migrated yet, but opening the new editor pre-fills it in Statement mode so saving migrates the topic. See [Per-topic reply prompt (legacy)](topic-reply-prompt.md).

## First-post checklist

A forum-wide checklist of staff-defined items (each with an optional link) that a new member at trust level 0 to 2 must tick before posting for the first time. Staff configure it — items, trust-level audience, and accept-button text — in a modal opened from the **First-post checklist** link in the sidebar's Community section. Editing it bumps a version that re-prompts everyone who already accepted, and every acceptance is recorded in an audit log. From the audit log staff can also **require a specific user to re-accept**. Alongside the forum-wide list, staff can create **targeted checklists** — separate checklists aimed at specific users that apply regardless of trust level or staff status. See [First-post checklist](first-post-checklist.md).

## Per-topic prompt checklist

A topic-scoped confirmation a user must accept before their reply to that topic is allowed through. Staff attach it from the topic admin (wrench) menu via the dedicated **Prompt Checklist** entry. Two modes:

- **Statement** — a single Markdown-cooked message + a single accept button. Replaces the legacy per-topic reply prompt.
- **Checklist** — multiple items, each with an optional link, all of which must be ticked before the accept button enables.

Frequency can be **once per user per topic** (the default — a staff edit bumps the version and re-prompts) or **on every reply** (no acceptance is recorded). A trust-level cap (`max_tl`) filters out higher-TL non-staff users, mirroring the global checklist. Targeted checklists still take priority over the per-topic prompt. See [Per-topic prompt checklist](topic-prompt-checklist.md).

## Pin a post to the bottom

Lets a moderator pin any post so it also appears at the end of the topic with a pin badge; the original post is badged in place. If the pinned post is already last, only the badge is shown. See [Pin a post to the bottom](pin-post-to-bottom.md).

## Per-topic reply approval

Lets a moderator flag a topic so replies route to the review queue for moderator approval instead of being published directly. Staff replies still post directly. See [Per-topic reply approval](topic-reply-approval.md).

## Private moderator note

A staff-only note on a topic — shown like a post with the author's avatar, name, and a relative timestamp — with a staff-only reply thread. Never visible to, or even sent to, regular users. See [Private moderator note](private-moderator-note.md).

## Moderator-note notifications & user-menu tab

Staff get a shield tab in the user menu listing moderator notes from across the forum, with an unread count. Setting a note or replying to one also sends a real Discourse notification (bell + live pop-up) to the other staff members, linking to the topic. The shield-tab's unread count is also surfaced in the page header as a **shield pip** next to the avatar, and as a **`(N)` prefix on the browser-tab title** — both update live (no refresh) via a dedicated MessageBus channel. See [Moderator-notes user-menu tab](moderator-notes-tab.md).

## Moderator whisper

Staff can post a **whisper** — an in-topic reply visible only to a chosen audience (the targeted users, all staff, and the topic's whisper participants), marked with a full-width banner. Only staff can start one; once a user has been whispered to in a topic they can whisper back to staff. Staff can also add a user to a topic's whisper conversation from a whisper post's admin menu, so that user sees every whisper in the topic. Gated by `mod_whisper_enabled` (default on). See [Moderator whisper](whisper.md).

## Where moderators set things

| Feature | Where it is set |
|---|---|
| Footer message, reply approval, private note | Topic admin (wrench) menu → **Moderator Actions** modal — split into *What users see* and *Moderation tools* sections, with a save toast |
| Per-topic reply prompt (statement) | Topic admin (wrench) menu → **Prompt Checklist** entry (mode: Statement) |
| New-topic prompt | Category → **Settings** tab |
| Pin a post to the bottom | A post's admin (moderator actions) menu |
| First-post checklist | **First-post checklist** link in the sidebar's Community section (opens a modal) |
| Per-topic prompt checklist | Topic admin (wrench) menu → **Prompt Checklist** entry (opens its own modal) |
| Category create / edit / delete | The normal Discourse category UI |

## Permissions

Every moderator action is gated by a Guardian permission — `can_manage_mod_messages?` for the topic/checklist tools, `can_edit_category?` for the per-category prompt — so only moderators and admins can set this content; regular and anonymous users are blocked with a `403`. The private moderator note is sent only to staff. See [Settings & features reference](settings.md) for the full breakdown.
