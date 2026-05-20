# Moderators vs Admins

This compares a Discourse moderator with the plugin enabled against a Discourse admin.

In terms of **core capabilities**, the plugin only extends category
create/edit/delete to moderators — every other core moderator/admin ability
is unchanged. On top of that, the plugin adds a set of **new
moderator-only tools** that core does not have at all (per-topic footer
message, new-topic and reply prompts, pin-a-post-to-bottom, per-topic reply
approval, the private moderator note and its user-menu tab, and the
first-post checklist). Those are listed under [Features](features.md); the
tables below cover only how the plugin changes the moderator/admin split
for core abilities.

## Content organization

| Ability | Admin | Moderator (with plugin) | Source |
|---------|-------|-------------------------|--------|
| Create categories | All | All | Plugin |
| Edit categories | All | All | Plugin |
| Delete categories | All (empty) | All (empty, no children) | Plugin |
| Create/edit/delete tags | Yes | Yes | Core |
| Edit topics | Yes | Yes | Core |
| Bulk change topic category | Yes | Yes | Core |

## Topic moderation

| Ability | Admin | Moderator | Source |
|---------|-------|-----------|--------|
| Close / reopen topics | Yes | Yes | Core |
| Reply on closed topics | Yes | Yes | Core |
| Archive / pin / unlist topics | Yes | Yes | Core |
| Split / merge topics | Yes | Yes | Core |
| Move posts | Yes | Yes | Core |
| Delete topics / posts | Yes | Yes | Core |

## User and site administration

| Ability | Admin | Moderator |
|---------|-------|-----------|
| Suspend / silence users | Yes | Yes |
| Review queue / handle flags | Yes | Yes |
| View deleted content | Yes | Yes |
| Access admin panel | Yes | Yes (limited) |
| Manage site settings | Yes | No |
| Install plugins | Yes | No |
| Manage admin users | Yes | No |

## Summary

The plugin closes a specific gap in core: moderators can manage almost
every aspect of the forum, but cannot create, edit, or delete categories
themselves. With this plugin enabled, they can — without elevating them to
full admins. The plugin also gives moderators several brand-new per-topic
and per-category tools (see [Features](features.md)) that no role has in
core Discourse.
