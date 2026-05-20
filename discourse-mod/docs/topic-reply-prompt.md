# Per-topic reply prompt (legacy — superseded)

> **Superseded.** This feature has been folded into the
> [Per-topic prompt checklist](topic-prompt-checklist.md) under its
> **Statement mode**. The per-topic reply prompt is no longer configured
> from the "Moderator Actions" modal — staff set it from the topic admin
> (wrench) menu → **Prompt Checklist** instead. The legacy fields below
> still work for any topic that hasn't been migrated yet; opening the
> Prompt Checklist editor for such a topic pre-fills it in Statement
> mode and saving migrates the topic.

## What it used to be

A confirmation dialog shown before a user posts a **reply** to a topic.
A moderator set the message + a trust-level audience cap.

- **Post anyway** submitted the reply; **Go back** kept the composer open.
- Only replies were gated — new topics and edits were not.
- Topics without a message set never prompted.
- URLs rendered as clickable links.

Feature switch: `topic_reply_prompt_enabled` — kept for backwards
compatibility; defaults to `false`.

## What replaced it

The [Per-topic prompt checklist](topic-prompt-checklist.md), specifically
its **Statement mode**:

- Single Markdown-cooked message + a single accept button (replaces the
  legacy dialog).
- A `max_tl` audience cap (replaces `mod_topic_reply_prompt_max_tl`).
- A `frequency` selector (new — pick once-per-user-per-topic or on every
  reply).
- A version that bumps on every save (new — staff edits re-prompt
  previously-accepted users).
- A unified storage shape covering both Statement and Checklist modes.

## Migration

When the new Prompt Checklist editor opens for a topic that still has
`mod_topic_reply_prompt` set, the editor pre-fills itself in Statement
mode with the legacy text and the legacy `mod_topic_reply_prompt_max_tl`
as the new `max_tl`. A notice in the editor calls this out. Clicking
**Save** writes the new config and clears the two legacy custom fields.

## Storage (legacy fields)

- `mod_topic_reply_prompt` — string. Still registered.
- `mod_topic_reply_prompt_max_tl` — integer 0-4; 4 / blank means everyone.

These are cleared automatically once a moderator saves the new per-topic
prompt config for the topic.

## Related

- [Per-topic prompt checklist](topic-prompt-checklist.md) — the
  current home for this feature.
- [Per-topic reply approval](topic-reply-approval.md) — for requiring
  moderator approval of replies (not just a prompt).
