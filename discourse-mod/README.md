# discourse-mod-categories

A Discourse plugin that grants **moderators** the ability to create, edit, and delete categories — capabilities that are normally reserved for admins.

Everything else moderators already have in core Discourse (editing topics, moving posts, bulk-changing topic categories, managing tags, etc.) is left untouched.

## How it works

1. Install the plugin
2. Enable `mod_categories_enabled` in site settings
3. Anyone in the built-in moderators group can now create, edit, and delete categories

## Settings

Admins use these site settings only to switch the capabilities on. The
**content** of every message is set by moderators, per topic or per
category (see below).

| Setting | Default | Description | Docs |
|---------|---------|-------------|------|
| `mod_categories_enabled` | `false` | Allow moderators to create, edit, and delete categories; also the plugin's overall enable switch | [docs](docs/mod-categories-enabled.md) |
| `topic_footer_message_enabled` | `true` | Enable the per-topic pinned footer message | [docs](docs/topic-footer-message.md) |
| `precheck_new_topic_enabled` | `true` | Enable the per-category "before you post a new topic" prompt | [docs](docs/precheck-new-topic.md) |
| `topic_reply_prompt_enabled` | `true` | Enable the per-topic "before you post a reply" prompt | [docs](docs/topic-reply-prompt.md) |
| `mod_whisper_enabled` | `true` | Enable moderator whisper posts (staff-only side conversations in a topic) | [docs](docs/whisper.md) |

`mod_categories_enabled` is `false` by default, so the whole plugin is off until an admin turns it on. The other settings default to `true`, so once `mod_categories_enabled` is on, the footer message, new-topic prompt, reply prompt, and moderator whisper are all available unless an admin explicitly turns them off.

## Enabling the features

All four settings live at **Admin → Settings**, in the **Moderator Category Management** category (`/admin/site_settings/category/discourse_mod_categories`). To change one, search for its name and tick or untick the checkbox.

1. **`mod_categories_enabled`** (default off) — turn this on **first**. It is the plugin's master switch; nothing else works until it is on. Moderators can then create, edit, and delete categories, and the plugin's moderator UIs load.
2. **`topic_footer_message_enabled`** (default on) — enables the per-topic **footer message** and **pinned posts**. Moderators set content from a topic's admin (wrench) menu → **Moderator Actions**. Untick to disable.
3. **`precheck_new_topic_enabled`** (default on) — enables the per-category **new-topic prompt**. Moderators set the message on each category's **Settings** tab. Untick to disable.
4. **`topic_reply_prompt_enabled`** (default on) — enables the per-topic **reply prompt**. Moderators set it in the topic admin menu's **Moderator Actions** modal. Untick to disable.

Per-topic **reply approval** and the **private moderator note** are also set from the topic admin menu → **Moderator Actions** (no separate site setting). The whole plugin can be switched off at any time by un-ticking `mod_categories_enabled`.

## Who can set the messages

Only **moderators and admins** can set the messages. The endpoints that
persist them are gated by `Guardian#can_manage_mod_messages?`; regular and
anonymous users get a `403`. Moderators have this ability while the plugin
is enabled (`mod_categories_enabled`); admins always do.

## Per-topic footer message

When `topic_footer_message_enabled` is on, a moderator opens a topic, uses
the topic admin (wrench) menu → **Moderator Actions**, and sets the
**Pinned footer message**. It renders in an official-notice box at the
bottom of that topic (below the last post, above suggested topics) — a
shield icon and a "Moderator message" label above the content. Stored on
the topic as the `mod_topic_footer_message` custom field and cooked as
Markdown for display; not shown in private messages or when blank.

## Per-topic reply prompt (now under Prompt Checklist)

The legacy stand-alone reply prompt has moved into the
[Per-topic prompt checklist](docs/topic-prompt-checklist.md) entry under
its **Statement mode** — a single Markdown-cooked message + an accept
button. Staff configure it from the topic admin (wrench) menu →
**Prompt Checklist**, alongside the existing **Checklist mode** for
multi-item flows. The legacy `mod_topic_reply_prompt` /
`mod_topic_reply_prompt_max_tl` custom fields remain registered for any
topic that hasn't been migrated; opening the new editor for such a topic
pre-fills it in Statement mode so saving migrates it. See
[Per-topic reply prompt (legacy)](docs/topic-reply-prompt.md) for the
older details.

## Per-category new-topic prompt

When `precheck_new_topic_enabled` is on, a moderator edits a category
(category → Settings tab) and sets the **Before-new-topic prompt**. The
field shows a live preview of how the message will look in the dialog, and
a **Show this prompt to** combo-box caps it by trust level. When a user
starts a new topic in that category, a confirmation dialog shows the
moderator's message before the topic posts. Stored as the
`mod_category_new_topic_prompt` and `mod_category_new_topic_prompt_max_tl`
category custom fields.

## First-post checklist

While the plugin is enabled, staff can define a forum-wide checklist that a
new member must tick before posting for the first time. Each item is a line
of text with an optional link to a post or page. A user at or below a
configurable trust-level cap (TL0, TL0–TL1, or TL0–TL2) who creates a topic
or replies is shown a modal listing the items; every box must be ticked
before the post goes through. Staff configure the list — items, trust-level
cap, and accept-button text — in a modal opened from the **First-post
checklist** link in the sidebar's Community section; saving bumps a version
that re-prompts everyone who already accepted. See
[the docs](docs/first-post-checklist.md) for details.

## Per-topic prompt checklist

Staff can attach a **Prompt Checklist** to a single topic from the topic
admin (wrench) menu's dedicated **Prompt Checklist** entry. Two modes:
**Statement** (single Markdown-cooked message + accept button — replaces
the legacy per-topic reply prompt) and **Checklist** (multiple items,
all of which must be ticked). Configurable frequency
(once-per-user-per-topic or on every reply) and a trust-level audience
cap. Acceptance in `once` mode is recorded per-topic per-user with a
version, so a staff edit re-prompts every previously-accepted user. See
[the docs](docs/topic-prompt-checklist.md) for details.

## Pin a post to the bottom

From any post's admin (moderator actions) menu, a moderator can choose
**Pin to Bottom**. The pinned post is shown at the bottom of the topic as
a regular-looking post (avatar, username, content) marked with a pin
symbol. **Unpin from Bottom** clears it. Stored as the
`mod_topic_pinned_post_id` topic custom field.

## Per-topic reply approval

In the topic admin menu modal, a moderator can tick **Require approval for
replies**. While on, replies to that topic are routed to the review queue
for a moderator to approve instead of being published directly; staff
replies still post immediately. Stored as the
`mod_topic_require_reply_approval` topic custom field, and enforced server
-side via a `NewPostManager` handler — the per-topic analogue of a
category's "require reply approval".

## Moderator-notes user-menu tab

While the plugin is enabled, staff get an extra **shield** tab in their user
menu (next to the notifications bell). It carries an unread count and lists
the moderator notes set on topics across the forum, each linking to its
topic. Visible to staff only. See
[the docs](docs/moderator-notes-tab.md) for details.

## Moderator whisper

When `mod_whisper_enabled` is on (default), staff can post **whispers** —
in-topic replies visible only to the post author, all staff, the chosen
target users, and the topic's whisper participants. Staff arm a whisper from
the composer's eye button and pick up to 10 targets. A non-staff user who
has been whispered to can whisper *back* staff-only. Whispers are filtered
out of the topic stream for everyone else. Staff can also add a user to a
topic's whisper conversation from a whisper post's admin menu, so that user
sees every whisper in the topic. See
[the docs](docs/whisper.md) for details.

## Documentation

Each setting and feature has a dedicated page in [`docs/`](docs/):

- [Feature list](docs/features.md)
- [Settings & features index](docs/settings.md)
- [`mod_categories_enabled` — master switch & category management](docs/mod-categories-enabled.md)
- [Category management](docs/categories.md)
- [Moderators vs Admins](docs/comparison.md)
- [Per-topic footer message](docs/topic-footer-message.md)
- [Pin a post to the bottom](docs/pin-post-to-bottom.md)
- [Per-topic reply prompt](docs/topic-reply-prompt.md)
- [Per-topic reply approval](docs/topic-reply-approval.md)
- [Per-category new-topic prompt](docs/precheck-new-topic.md)
- [First-post checklist](docs/first-post-checklist.md)
- [Per-topic prompt checklist](docs/topic-prompt-checklist.md)
- [Private moderator note](docs/private-moderator-note.md)
- [Moderator-notes user-menu tab](docs/moderator-notes-tab.md)
- [Moderator whisper](docs/whisper.md)
- [`mod_whisper_enabled`](docs/mod-whisper-enabled.md)
- [Tests & screenshots](docs/testing.md)
- [Changelog](CHANGELOG.md)

## Permissions granted

| Action | Default |
|--------|---------|
| Create categories | All categories |
| Edit categories | All categories |
| Delete categories | All categories (must be empty, no children) |

## Installation

Add the plugin's repository URL to your `app.yml`:

```yaml
hooks:
  after_code:
    - exec:
        cd: $home/plugins
        cmd:
          - git clone https://github.com/Shalom-Karr/discourse-mod.git
```

Then rebuild the container:

```
./launcher rebuild app
```
