# Private moderator note

A staff-only note on a topic, for moderator coordination — never shown to regular users.

## How a moderator sets it

Topic → admin (wrench) menu → **Moderator Actions** → the **Private moderator note** field. Choose whether the note shows **at the top** or **at the bottom** of the topic, then **Save**.

## What it looks like

The note renders like a post — the moderator who set it, with their avatar and name, in a muted whisper-style card:

![A private moderator note shown to staff](../screenshots/40_private_note_staff_view.png)

## Behaviour

- Visible **only to staff** (moderators and admins). The note is not even serialized to regular users — a non-staff user's topic JSON never contains it.
- Shown like a post: the moderator who set it, with their avatar, name, and a relative timestamp.
- Renders at the top or the bottom of the topic, per the chosen position.
- Updates live when saved — no page reload.

## Reply thread

The note card has a **Reply** button that opens an inline box for another
moderator to add to it. Replies form a staff-only thread, each entry showing
its author and time. Setting the note or adding a reply also sends a
[notification to the other staff members](moderator-notes-tab.md) and bumps
the topic's note activity timestamp, which drives the moderator-notes
user-menu tab.

## Editing & deleting entries

Every entry in the note thread is editable and removable by staff:

- Each **reply** carries a small pencil (edit) and trash-can (delete) control.
  Edit opens an inline textarea with save/cancel; delete asks for confirmation,
  then removes that reply. Each reply has a stable `id` so edit/delete targets
  the right entry even after other entries are removed (legacy replies without
  an `id` are backfilled one on first read).
- The **note body** itself has an edit control (reopens the Moderator Actions
  modal) and a delete control that clears the note, its author/created-at, and
  the entire reply thread after confirmation.

After any edit or delete the note card refreshes in place — no page reload.

## Storage & API

- **Topic custom fields:** `mod_topic_private_note` (string), `mod_topic_private_note_position` (`top` / `bottom`), `mod_topic_private_note_user_id` (the author), `mod_topic_private_note_created_at` (ISO-8601), `mod_topic_private_note_replies` (JSON array of `{ id, user_id, raw, created_at }`), `mod_topic_private_note_activity_at` (ISO-8601, bumped on every note/reply change).
- **Endpoints:**
  - `PUT /discourse-mod-categories/topic/:topic_id` with `private_note` and `private_note_position` — set or clear the note.
  - `POST /discourse-mod-categories/topic/:topic_id/note-reply` with `raw` — append a reply to the thread.
  - `PUT /discourse-mod-categories/topic/:topic_id/note-reply` with `reply_id` and `raw` — edit a single reply's body (blank `raw` is rejected).
  - `DELETE /discourse-mod-categories/topic/:topic_id/note-reply` with `reply_id` — remove a single reply.
  - `DELETE /discourse-mod-categories/topic/:topic_id/note` — clear the note body, its author/created-at, and the whole reply thread.
- Each reply carries a stable `id` (`SecureRandom.hex(8)`), so edit/delete targets a specific entry even as the array shifts. Legacy replies without one are backfilled an `id` whenever the array is read.
- The edit/delete endpoints return the updated note + replies JSON so the frontend refreshes in place.
- The note, its position, author, created-at, and replies (each including `id`) are serialized with `include_condition: scope.is_staff?`, so they reach staff only.
- Setting the note triggers a staff notification (see the [moderator-notes tab](moderator-notes-tab.md)).

## Who can use it

Only **moderators and admins** may set, reply to, edit, or delete the note and its entries — every endpoint is gated by `Guardian#can_manage_mod_messages?`; regular and anonymous users get a `403`. The note and its UI never render for non-staff.
