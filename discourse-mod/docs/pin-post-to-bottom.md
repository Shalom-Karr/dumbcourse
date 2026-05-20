# Pin a post to the bottom

Part of the topic footer feature — uses the **`topic_footer_message_enabled`** switch.

A moderator can pin any post to the bottom of its topic.

## How a moderator pins a post

Open the post's admin (moderator actions) menu → **Pin to Bottom**. To remove it, choose **Unpin from Bottom** on the same post.

## What it looks like

This is the intended result — the pinned post as the last post in the topic, above the reply button:

![A pinned post shown as the bottom post of a topic](../screenshots/39_pinned_post_as_bottom_post.png)

## Behaviour

- The pinned post renders as the **last post in the topic** — at the end of the post stream, **above the reply button** — as a regular-looking post (avatar, username, cooked content) marked with a pin badge.
- A button at the top-right links up to the original post in the stream.
- It is a rendered copy: the original post keeps its own position, number, and likes. (Discourse does not let a plugin move the real post in the stream.)
- Appears and disappears live when pinned/unpinned — no page reload.

## Storage & API

- **Topic custom field:** `mod_topic_pinned_post_id` (integer)
- **Endpoint:** `PUT /discourse-mod-categories/topic/:topic_id` with the `pinned_post_id` param — a post id to pin, or an empty value / `0` to unpin.
- The post must belong to the topic, otherwise the endpoint returns `400`.
- Only moderators and admins may pin (`Guardian#can_manage_mod_messages?`); the menu button is staff-only.
