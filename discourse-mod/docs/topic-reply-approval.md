# Per-topic reply approval

Part of the topic moderator settings — set per topic, no separate site setting.

A moderator can require that replies to a specific topic be approved before they appear — the per-topic analogue of a category's "require reply approval".

## How a moderator enables it

Topic → admin (wrench) menu → **Moderator Actions** → tick **Require approval for replies** → **Save**.

## What it looks like

![The 'Require approval for replies' option in the topic modal](../screenshots/38_mod_messages_require_approval_checked.png)

## Behaviour

- While on, replies to that topic are routed to the **review queue** for a moderator to approve, instead of being published directly.
- **Staff** replies (moderators/admins, and anyone who can review the topic) are posted directly.
- **New topics** are unaffected — only replies to the flagged topic are gated.

## Storage & implementation

- **Topic custom field:** `mod_topic_require_reply_approval` (boolean)
- **Endpoint:** `PUT /discourse-mod-categories/topic/:topic_id` with the `require_reply_approval` param
- The current value is exposed on the topic view as `mod_topic_require_reply_approval` so the modal can pre-fill the checkbox.
- Enforced server-side in `plugin.rb` by a `NewPostManager.add_handler` block: for a reply whose topic has the flag set (and whose author cannot review the topic), it calls `manager.enqueue("mod_topic_requires_reply_approval")`, creating a `ReviewableQueuedPost`.

## Who can use it

Only **moderators and admins** can change the flag — the persistence endpoint is gated by `Guardian#can_manage_mod_messages?`; regular and anonymous users get a `403`. The checkbox itself only renders for staff.
