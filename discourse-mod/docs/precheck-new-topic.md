# Per-category new-topic prompt

Feature switch: **`precheck_new_topic_enabled`** — boolean, default `false`, client-exposed.

A confirmation dialog shown before a user posts a **new topic** in a category.

## How a moderator sets it

Category → **Settings** tab → **Before-new-topic prompt** field → **Save message**.

## What it looks like

![The new-topic confirmation prompt](../screenshots/28_new_topic_prompt_dialog.png)

## Behaviour

- When a user starts a new topic in that category and clicks submit, a dialog shows the moderator's message.
- **Post anyway** submits the topic; **Go back** returns to the composer with content intact.
- Categories without a message set never prompt.
- Replies and edits are never gated by this feature — see the [reply prompt](topic-reply-prompt.md).
- URLs in the message render as clickable links.

## Limit by trust level

The **Show this prompt to** dropdown (below the message field) caps the
prompt by the poster's trust level:

- **Everyone** (default) — every user sees it.
- **New users only (TL0)** — only brand-new accounts.
- **New and basic users (TL0 and TL1)** — TL0 and TL1.
- **Up to members (TL0 to TL2)** / **Up to regulars (TL0 to TL3)**.

A user above the cap skips the dialog. This lets a category require, say,
only TL0 and TL1 users to confirm they read the guidelines before posting,
while established members post without the extra step.

## Storage & API

- **Category custom fields:** `mod_category_new_topic_prompt` (string),
  `mod_category_new_topic_prompt_max_tl` (integer 0-4; 4/blank means everyone)
- **Endpoint:** `PUT /discourse-mod-categories/category/:category_id` with
  the `new_topic_prompt` and `new_topic_prompt_max_tl` params
- Gated by `Guardian#can_edit_category?` (moderators have this while the plugin is enabled; admins always).

## Implementation

The composer initializer (`assets/javascripts/discourse/initializers/precheck-prompt.js`) hooks `composerBeforeSave`; for a new topic it reads `composer.category.mod_category_new_topic_prompt`.
