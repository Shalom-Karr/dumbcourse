# Settings & features reference

The site settings below live under **Moderator Category Management** at `/admin/site_settings/category/discourse_mod_categories`. They only switch capabilities **on** — the message content is set by moderators, per topic or per category.

Each setting and feature has its own page:

## Site settings

| Setting | Default | Documentation |
|---|---|---|
| `mod_categories_enabled` | `false` | [Master switch & category management](mod-categories-enabled.md) |
| `topic_footer_message_enabled` | `true` | [Per-topic footer message](topic-footer-message.md) |
| `precheck_new_topic_enabled` | `true` | [Per-category new-topic prompt](precheck-new-topic.md) |
| `topic_reply_prompt_enabled` | `true` | [Per-topic reply prompt](topic-reply-prompt.md) |
| `mod_whisper_enabled` | `true` | [Moderator whisper](mod-whisper-enabled.md) |

`mod_categories_enabled` defaults to `false` — the whole plugin is inactive until an admin turns it on. The feature switches default to `true`, so each feature works as soon as the master switch is on; an admin can turn an individual feature off without disabling the plugin.

## Moderator-set features (no site setting)

| Feature | Documentation |
|---|---|
| Pin a post to the bottom of a topic | [Pin a post to the bottom](pin-post-to-bottom.md) |
| Require approval for replies to a topic | [Per-topic reply approval](topic-reply-approval.md) |
| Private moderator note on a topic | [Private moderator note](private-moderator-note.md) |
| Staff "Moderator notes" user-menu tab | [Moderator-notes user-menu tab](moderator-notes-tab.md) |
| Forum-wide first-post checklist (configured from the sidebar) | [First-post checklist](first-post-checklist.md) |
| Moderator whisper (staff-only side conversations in a topic) | [Moderator whisper](whisper.md) |

## Who can set what

Only **moderators and admins** can set the per-topic and per-category content. The persistence endpoints (`PUT /discourse-mod-categories/topic/:id` and `/category/:id`) are Guardian-gated; regular and anonymous users get `403`.

## Related pages

- [Feature list](features.md) — everything the plugin adds.
- [Category management](categories.md) — what moderators can do with categories.
- [Moderators vs Admins](comparison.md) — how the plugin changes the role split.

## Tests & screenshots

See [Tests & screenshots](testing.md) for the test-suite overview and a screenshot of every feature.
