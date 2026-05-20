# `mod_whisper_enabled`

- **Type:** boolean
- **Default:** `true`
- **Client-exposed:** yes
- **Admin path:** `/admin/site_settings/category/discourse_mod_categories`

Enables the moderator whisper feature.

## What it does

When enabled, staff (admins and moderators) can post **whispers** — in-topic
replies visible only to a limited audience instead of everyone. See
[Moderator whisper](whisper.md) for the full feature description.

When disabled:

- The composer eye button and target modal do not load.
- The visibility filter is bypassed — any post that previously carried the
  whisper custom field becomes a plain post visible to everyone.
- No whisper notifications are sent.

## Implementation

Registered in `config/settings.yml` under `discourse_mod_categories:`. The
server-side guards (`Guardian#can_see_post?`,
`DiscourseModCategories::WhisperQueryFilter`, the `before_create_post` /
`post_created` hooks) all short-circuit on `SiteSetting.mod_whisper_enabled`,
and the frontend initializer returns early when it is off.
