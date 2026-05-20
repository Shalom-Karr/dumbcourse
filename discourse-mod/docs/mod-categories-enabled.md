# `mod_categories_enabled`

- **Type:** boolean
- **Default:** `false`
- **Client-exposed:** yes
- **Admin path:** `/admin/site_settings/category/discourse_mod_categories`

The plugin's master switch and the category-management capability.

## What it does

When enabled:

- Members of the built-in **moderators** group can create, edit, and delete categories — abilities normally reserved for admins.
- The plugin's frontend assets load (the topic and category moderator UIs).
- Moderators may set the plugin's per-topic and per-category messages, gated by `Guardian#can_manage_mod_messages?`.

When disabled, the plugin is inactive and only admins have the usual core abilities.

## Category deletion rule

A moderator may delete a category only when it has **no topics**, **no sub-categories**, and is **not** the uncategorized category. Admins are unaffected.

## Implementation

`lib/discourse_mod_categories/guardian_extensions.rb` prepends overrides onto `Guardian`: `can_create_category?`, `can_edit_category?`, `can_edit_serialized_category?`, `can_delete_category?`, and `can_manage_mod_messages?`. Each falls back to the moderator grant only after the core check (`super`) declines.
