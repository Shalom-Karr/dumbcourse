# Moderator whisper

A **whisper** is an in-topic post that is visible only to a limited audience
instead of everyone reading the topic. It lets staff hold a side
conversation — with a specific member, or staff-only — without leaving the
thread or creating a separate private message.

Controlled by the [`mod_whisper_enabled`](mod-whisper-enabled.md) site
setting (default **on**).

## Who sees a whisper

A whisper post is visible to, and only to:

- the **post author**;
- **all staff** (admins and moderators), for oversight;
- the post's **explicit user targets** — the users staff picked;
- members of any of the post's **explicit target groups**;
- the topic's **whisper participants** — every non-staff user who has ever
  been whispered to in that topic.

Everyone else, and anonymous visitors, never see the post: it is filtered
out of the topic stream at the SQL level and hidden by `Guardian`.

## Posting a whisper

Open the reply composer and click the **eye** button in the toolbar.

- **Staff** get a modal to pick up to 10 targets — individual **users**,
  whole **groups**, or a mix of both. Posting the reply marks it as a
  whisper to that audience; every member of a target group can see it. The
  non-staff user targets are recorded as the topic's cumulative whisper
  participants.
- A **non-staff whisper participant** (someone staff whispered to earlier in
  the topic) can whisper *back*. Their whisper is always **staff-only** — it
  carries an empty target list, so only staff and the author see it.
- A **non-staff non-participant** has no whisper ability; the eye button
  does nothing for them.

When replying directly to a whisper, the composer auto-arms a whisper-back
so the side conversation stays contained.

## Adding a user to a whisper conversation

Staff can add a user to a topic's whisper conversation after the fact. On any
whisper post, open the post admin (wrench) menu and choose **Add user to
whisper**. A modal opens a user chooser; the chosen users are merged into the
topic's `mod_whisper_participant_ids`. From then on each added user sees
**every** whisper in that topic — past and future — and can whisper back.

This is staff-only (`Guardian#can_manage_mod_messages?` — admins always,
moderators while the plugin is enabled) and requires `mod_whisper_enabled`.
Adding the same user twice is a no-op (ids are de-duplicated). Each newly
added user receives a notification.

Endpoint: `POST /discourse-mod-categories/topic/:topic_id/whisper-participant`
with a `username` (or `user_id`); it returns the updated participant list.

## Visual treatment

A received whisper shows a full-width banner above its body and a coloured
left border on the post:

- **indigo** — a staff-authored whisper to chosen users;
- **amber** — a staff-only whisper (empty target list / whisper-back).

## Notifications

- A staff-authored whisper notifies its chosen targets.
- A non-staff whisper-back notifies all staff.

## Data model

| Field | Scope | Meaning |
|---|---|---|
| `mod_whisper_target_user_ids` | post custom field (json) | The whisper's target user ids. **Key presence** marks the post a whisper — even an empty `[]` (a staff-only whisper-back). |
| `mod_whisper_target_group_ids` | post custom field (json) | The whisper's target group ids. A member of any of these groups can see the whisper. May be empty even on a whisper with user targets. |
| `mod_whisper_participant_ids` | topic custom field (json) | Cumulative non-staff users ever whispered to in the topic. Gates "can whisper back" and is part of every whisper's audience. |

Constant `DiscourseModCategories::MAX_WHISPER_TARGETS` caps a single
whisper at 10 targets.

## Implementation

- `lib/discourse_mod_categories/guardian_extensions.rb` — `can_see_post?`
  and `can_whisper_in_topic?`.
- `lib/discourse_mod_categories/whisper_query_filter.rb` — the SQL stream
  filter, wired through `TopicView.apply_custom_default_scope`. It must
  agree with the Guardian override (a parity spec locks this).
- `plugin.rb` — the `before_create_post` hook that marks the post and
  updates the topic participants, the `post_created` notification hook, and
  the post serializer attributes (`mod_is_whisper`,
  `mod_whisper_target_user_ids`, `mod_whisper_targets`,
  `mod_whisper_target_group_ids`, `mod_whisper_target_groups`,
  `mod_whisper_is_staff_only`, `mod_whisper_author_is_staff`).
- `assets/javascripts/discourse/initializers/mod-whisper.js` — composer
  toolbar button, target modal, armed pill, and the cooked-element banner
  decorator.
- `app/controllers/discourse_mod_categories/messages_controller.rb` —
  `add_whisper_participant` adds a user to the topic's whisper conversation.
- `assets/javascripts/discourse/initializers/mod-whisper-add-participant.js`
  and `components/mod-whisper-add-participant-modal.gjs` — the "Add user to
  whisper" post-admin-menu button and its user-chooser modal.
