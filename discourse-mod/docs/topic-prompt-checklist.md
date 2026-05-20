# Per-topic prompt checklist

A topic-scoped confirmation a user must accept before their reply to that
topic is allowed through. Sits alongside (and integrates with) the
forum-wide first-post checklist and the targeted checklists. Two modes:

- **Statement** — a single Markdown-cooked message + an accept button.
  No checkboxes; the accept button is enabled immediately. Replaces the
  legacy per-topic before-reply prompt.
- **Checklist** — multiple items, each with an optional link, all of
  which must be ticked before the accept button enables.

## Audience

Configurable. By default everyone replying — including staff —
sees the prompt. A `max_tl` cap (Discourse combo-box) hides the prompt
from non-staff users above the chosen trust level; staff always see it.
A targeted checklist still takes priority over the per-topic prompt for
the users it targets.

## Frequency

Configurable per topic:

- **Once per user per topic** (default) — version-tracked acceptance.
  A staff edit bumps the version and re-prompts every previously-accepted
  user.
- **On every reply** — the prompt always fires. No acceptance is
  recorded, so the user is prompted again on their next reply.

## Staff: attaching a prompt to a topic

1. Open the topic.
2. Click the wrench (topic admin) menu.
3. Click **Prompt Checklist** (a dedicated entry, separate from
   "Moderator Actions").
4. Pick the **Mode** (Statement or Checklist).
5. Fill in the statement text *or* add one or more checklist items.
6. Pick the **frequency** (Once per user per topic, or On every reply).
7. Optionally set the **trust-level cap**.
8. Set the **accept-button text** and **Save**.

Saving bumps the prompt version. To clear, click **Clear** in the editor.

### Migrating from the legacy reply prompt

When the Prompt Checklist editor loads for a topic that has a legacy
`mod_topic_reply_prompt` set (and no new prompt-checklist config yet),
the editor pre-fills itself in **Statement mode** with the legacy text
and the legacy `mod_topic_reply_prompt_max_tl` as `max_tl`. A migration
notice is shown above the form. Clicking Save writes the new config and
clears the two legacy fields on the topic, so the new prompt is the
sole source of truth from then on.

## User: replying to a gated topic

When the composer opens for a reply to a topic with an active prompt,
the user is shown the same modal used by the forum-wide checklist.

- **Statement mode:** the statement is rendered as cooked Markdown
  (links, bold, etc.) and the accept button is enabled immediately.
- **Checklist mode:** every item must be ticked before the accept
  button enables.

Closing the modal cancels the reply.

Once a user accepts version N for a topic in `once` mode, they are not
re-prompted for subsequent replies in that topic until staff bump the
version. In `every_reply` mode they are prompted every time.

## Storage

- Topic custom field `mod_topic_prompt_checklist` (json), shape
  ```
  {
    "version": Int,
    "mode": "statement" | "checklist",
    "statement": String,                # used in statement mode
    "items": [{ "label", "url" }],      # used in checklist mode
    "frequency": "once" | "every_reply",
    "max_tl": 0-4,                      # 4 = everyone
    "button_label": String,
    "updated_at": ISO-8601
  }
  ```
  Absent / inactive (no items in checklist mode, or blank statement in
  statement mode) = no prompt.
- User custom field `mod_topic_checklist_accepted` (json), map of
  `{ topic_id => accepted_version }`. Only written for `frequency: once`.

The legacy custom fields `mod_topic_reply_prompt` and
`mod_topic_reply_prompt_max_tl` remain registered so any topic that
hasn't been migrated yet still works. Saving a new per-topic config
clears them.

## API

Staff-gated routes mounted under the plugin engine:

- `GET  /discourse-mod-categories/topic/:topic_id/prompt-checklist`
  - Returns the editor payload, including `mode`, `statement`,
    `frequency`, `max_tl`, and `from_legacy: true` when seeded from
    the legacy reply-prompt fields.
- `PUT  /discourse-mod-categories/topic/:topic_id/prompt-checklist`
  - Accepts `mode`, `statement`, `items` (index-keyed-hash also OK),
    `frequency`, `max_tl`, `button_label`. Bumps the version. Clears
    the legacy `mod_topic_reply_prompt*` fields.
- `DELETE /discourse-mod-categories/topic/:topic_id/prompt-checklist`

The composer gate uses the existing `GET /discourse-mod-categories/checklist/owed`
endpoint and passes `topic_id` so the server can include the per-topic
prompt in the owed result. Priority: targeted > per-topic > global.
When per-topic is owed, the returned payload has `kind: "topic"`,
`id: topic_id`, plus `mode`, `statement`, `items`, `frequency`, and
`max_tl`.

Acceptance reuses `POST /discourse-mod-categories/checklist/accept` with
`kind: "topic"` and `id: topic_id`; the accepted version is recorded
into `mod_topic_checklist_accepted[topic_id]`, clamped to the published
version. For `every_reply` frequency the write is harmless (the next
post is prompted again anyway).

## Interactions with the other checklists

Priority on `/checklist/owed`:

1. Targeted (regardless of trust level or staff status)
2. Per-topic (only when `topic_id` is supplied — i.e. replying)
3. Global forum-wide (non-staff, trust-level cap)

A user owing more than one is shown the highest-priority one.
