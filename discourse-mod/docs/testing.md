# Tests & screenshots

## Test suite

The plugin is covered by four CI workflows (see `.github/workflows/`):

| Workflow | What it runs |
|---|---|
| **Plugin Tests** | rspec — `plugin_spec.rb`, `spec/lib`, `spec/requests` (Guardian, permissions, the message endpoints, serialization, reply-approval enforcement, moderator-note notifications, the prompt trust-level caps, and the first-post checklist) |
| **Category Save Tests** | rspec — `spec/saves` (category-save regression suite) |
| **QUnit Tests** | `test/javascripts/unit` — the pure-logic matrix suites (precheck-prompt resolution incl. trust-level caps, footer message, first-post checklist gate) |
| **Frontend System Tests** | `spec/system` — Capybara/Playwright end-to-end specs; uploads the screenshots below as the `ui-screenshots` artifact |

Every screenshot below is produced by a passing system spec, so they double as a visual regression record. Each one is explained under its own heading.

### Coverage for the newer features

These features are covered by request specs and QUnit unit tests; their
end-to-end screenshots are not yet part of the gallery below:

| Feature | Tests |
|---|---|
| Moderator-note pop-up notifications | `spec/requests/mod_messages_spec.rb` — notifications go to other staff, not the actor or regular users |
| Clickable links in the prompt dialogs | exercised by the prompt system specs |
| Prompt trust-level caps | `spec/requests/mod_messages_spec.rb` (persistence, clamping) + `test/javascripts/unit/precheck-prompt-test.js` (trust-level matrix) |
| First-post checklist | `spec/requests/checklist_spec.rb` (read/edit/accept gating, version bump, trust-level cap, button label, serializer audience), `test/javascripts/unit/first-post-checklist-test.js` (gate matrix), and the system spec below |
| Per-topic prompt checklist | `spec/requests/topic_prompt_checklist_spec.rb` (staff CRUD with `mode`/`statement`/`frequency`/`max_tl`, `/checklist/owed?topic_id=…`, per-topic-per-user acceptance with clamp, version bump, topic_view serializer, statement-mode payload, frequency=`every_reply` always returns, `max_tl` cap filters higher-TL non-staff, legacy reply-prompt pre-fill + migration) and `spec/system/topic_prompt_checklist_spec.rb` (staff opens the wrench-menu "Prompt Checklist", adds items, saves; another user replies and is prompted; accepts; second reply is NOT prompted; version-bump re-prompts; statement-mode modal renders without checkboxes; `frequency: every_reply` re-prompts on the second reply; `max_tl` cap skips higher-TL users; Moderator Actions modal no longer carries the Before-reply prompt section) — screenshots 171–186 |
| Moderator-notes header pip & title prefix | `spec/requests/mod_note_header_indicators_spec.rb` (`mod_note_unread_count` across states + MessageBus publishes on note set/reply and on `notes-feed/seen`), `test/javascripts/unit/mod-note-unread-title-test.js` (pure `applyUnreadPrefix` / `stripUnreadPrefix` matrix), and `spec/system/mod_note_header_indicators_spec.rb` (header pip + `(N)` title prefix render for staff with unread notes, clear after the shield tab is opened, never render for a regular user) — screenshots 190-192 |

---

## Per-topic footer message

### Topic page, moderator view

The starting point — a regular topic as a moderator sees it, before any moderator message is set.

![Topic page, moderator view](../screenshots/01_topic_page_moderator.png)

### The topic admin (wrench) menu

Opening the topic admin menu reveals the **Moderator Actions** button that staff use to manage this plugin's per-topic content.

![Topic admin menu open](../screenshots/02_topic_admin_menu_open.png)

### The Moderator Actions modal — empty

The modal opened from that menu, before anything is entered.

![Moderator Actions modal — empty](../screenshots/03_mod_messages_modal_empty.png)

### The footer message field filled in

A moderator types the pinned footer message into the modal.

![Footer message filled in](../screenshots/04_mod_messages_footer_filled.png)

### Footer message and reply prompt both filled in

The modal with both the footer message and the before-reply prompt entered.

![Footer + reply prompt filled in](../screenshots/05_mod_messages_both_filled.png)

### The footer message rendered after saving

After saving, the footer message appears in a banner at the bottom of the topic.

![Footer rendered after save](../screenshots/06_footer_rendered_after_save.png)

### A topic that already has a footer message

A topic loaded with a footer message already set — the state before an edit.

![Topic with an existing footer](../screenshots/07_topic_with_existing_footer.png)

### The modal re-opened for editing

Re-opening the modal pre-fills it with the topic's current values, ready to edit.

![Modal re-opened for editing](../screenshots/08_mod_messages_modal_editing.png)

### The modal after editing the values

The modal with the footer message changed to a new value.

![Modal after editing](../screenshots/09_mod_messages_modal_edited.png)

### The footer updated after the edit

The footer banner now shows the edited message — updated live, without a reload.

![Footer updated after edit](../screenshots/10_footer_updated_after_edit.png)

### The footer present, before it is cleared

A topic with a footer message, about to be cleared.

![Footer before clearing](../screenshots/11_footer_before_clearing.png)

### The modal with the footer field cleared

The moderator empties the footer message field in the modal.

![Modal with the field cleared](../screenshots/12_mod_messages_modal_cleared.png)

### The footer removed after clearing

After saving the empty field, the footer banner is gone.

![Footer removed after clearing](../screenshots/13_footer_removed_after_clearing.png)

### The footer message as a regular user sees it

A non-staff member viewing the topic sees the footer banner just the same.

![Footer visible to a regular user](../screenshots/20_footer_visible_to_user.png)

### The footer message rendered as HTML

HTML in the footer message (here, bold text) is rendered — it is admin/moderator-trusted content.

![Footer message rendered as HTML](../screenshots/36_footer_html_rendered.png)

### The footer still shown on a closed topic

The footer message keeps showing even after the topic is closed.

![Footer still shown on a closed topic](../screenshots/37_footer_on_closed_topic.png)

---

## Per-category new-topic prompt

### The category Settings tab — prompt field

The **Before-new-topic prompt** field added to a category's Settings tab.

![Category settings — prompt field](../screenshots/21_category_settings_prompt_field.png)

### The category prompt filled in

A moderator types the prompt for that category.

![Category prompt filled in](../screenshots/22_category_prompt_filled.png)

### The category prompt saved

The prompt saved, with the green "Saved" confirmation.

![Category prompt saved](../screenshots/23_category_prompt_saved.png)

### The new-topic composer in that category

A user starts a new topic in the category that has a prompt set.

![New-topic composer in the category](../screenshots/27_new_topic_composer_in_category.png)

### The new-topic confirmation dialog

On submit, the moderator's message appears as a confirmation before the topic posts.

![New-topic confirmation dialog](../screenshots/28_new_topic_prompt_dialog.png)

### Going back from the new-topic prompt

Choosing "Go back" returns to the composer with the content intact.

![Go back from the new-topic prompt](../screenshots/29_new_topic_prompt_go_back.png)

### The new topic posted after confirming

Choosing "Post anyway" submits the topic as normal.

![New topic posted after confirming](../screenshots/30_new_topic_posted_after_confirm.png)

### No prompt in a category without one

In a category that has no prompt set, a new topic posts directly with no dialog.

![No prompt in a plain category](../screenshots/31_no_prompt_plain_category.png)

---

## Per-topic reply prompt

### A user viewing the topic

A regular user opens a topic that has a before-reply prompt set.

![User views the topic](../screenshots/14_user_views_topic.png)

### The user's reply composer

The user opens the reply composer and writes a reply.

![User reply composer](../screenshots/15_user_reply_composer.png)

### The before-reply confirmation dialog

On submit, the moderator's reply prompt appears as a confirmation.

![Reply prompt dialog](../screenshots/16_reply_prompt_dialog.png)

### Going back from the reply prompt

"Go back" keeps the composer open with the reply intact.

![Go back from the reply prompt](../screenshots/17_reply_prompt_go_back.png)

### Posting anyway from the reply prompt

"Post anyway" submits the reply.

![Post anyway from the reply prompt](../screenshots/18_reply_prompt_post_anyway.png)

### No prompt when none is set

A topic with no reply prompt configured — replies post directly.

![No prompt when none is set](../screenshots/33_reply_no_prompt.png)

### The reply prompt dialog (end-to-end flow)

The before-reply dialog shown in the full reply flow.

![Reply prompt dialog](../screenshots/34_reply_prompt_dialog.png)

### The reply posted after confirming

The reply is posted once the user confirms.

![Reply posted after confirming](../screenshots/35_reply_posted_after_confirm.png)

---

## Pin a post to the bottom

### The "Pin to Bottom" option in the post admin menu

A post's admin (moderator actions) menu, showing the **Pin to Bottom** button.

![Pin option in the post admin menu](../screenshots/25_post_admin_menu_pin_option.png)

### A post pinned to the bottom

After pinning, the post is shown at the bottom of the topic.

![Post pinned to the bottom](../screenshots/26_post_pinned_to_bottom.png)

### A footer message and a pinned post together

A topic showing both a moderator footer message and a pinned post.

![Footer message and pinned post together](../screenshots/27_footer_message_and_pinned_post_together.png)

### A pinned post, before unpinning

A pinned post in place, about to be unpinned.

![Pinned post before unpinning](../screenshots/28_pinned_post_before_unpin.png)

### The topic after unpinning

After "Unpin from Bottom", the pinned copy is gone.

![Pinned post after unpinning](../screenshots/29_pinned_post_after_unpin.png)

### The pinned post rendered as the bottom post

The pinned post shown at the end of the post stream as a regular-looking post with a pin badge and a jump-to-original button.

![Pinned post as the bottom post](../screenshots/39_pinned_post_as_bottom_post.png)

### Pinning the last post

When the pinned post is already the last post, only the in-stream pin badge shows — no duplicate copy.

![Pinned post — last post](../screenshots/42_pinned_last_post.png)

### Pinning the second-to-last post

A non-last post gets the in-stream badge plus the copy at the bottom.

![Pinned post — second-to-last](../screenshots/43_pinned_second_to_last.png)

### Pinning the third-to-last post

Same behaviour for the third-to-last post — badge plus bottom copy.

![Pinned post — third-to-last](../screenshots/44_pinned_third_to_last.png)

### Pinning the tenth-to-last post

And for a post well up the thread (tenth-to-last) — badge plus bottom copy.

![Pinned post — tenth-to-last](../screenshots/45_pinned_tenth_to_last.png)

---

## Per-topic reply approval

### "Require approval for replies" set in the modal

The **Require approval for replies** checkbox ticked in the topic modal. While on, replies route to the review queue.

![Require approval for replies](../screenshots/38_mod_messages_require_approval_checked.png)

---

## Private moderator note

### The private note as staff see it

A staff-only note shown like a post — the moderator's avatar and name — never visible to regular users.

![Private note — staff view](../screenshots/40_private_note_staff_view.png)

### The private note hidden from a regular user

The same topic as a non-staff user: the private note is absent (it is not even sent to non-staff).

![Private note hidden from a regular user](../screenshots/41_private_note_hidden_from_user.png)

### The note with a timestamp and a Reply button

The note shows a relative timestamp ("how long ago") and a small **Reply** button.

![Private note with timestamp and reply button](../screenshots/46_private_note_with_timestamp_and_reply_button.png)

### The reply box on the note

Clicking Reply opens a box for a moderator to add to the note thread.

![Private note reply box](../screenshots/47_private_note_reply_box.png)

### A reply added to the note thread

The reply, posted — the note is now a staff-only thread, each entry with its author and time.

![Private note reply added](../screenshots/48_private_note_reply_added.png)

---

## Moderator-notes user-menu tab

### The shield tab in the user menu

Staff get a shield tab in the user menu, next to the bell, with an unread-count badge.

![The shield tab in the user menu](../screenshots/49_user_menu_shield_tab.png)

### The moderator-notes panel

Opening the tab lists the moderator notes across topics — each entry shows the topic and the note, and links to the topic.

![The moderator-notes panel](../screenshots/50_moderator_notes_tab_panel.png)

### Header shield pip — unread count visible without opening the menu

A staff-only shield pip rendered in the page header, carrying the same unread count as the shield tab. Visible whenever the user menu is closed and `mod_note_unread_count > 0`. Clicking it opens the menu on the shield tab.

![Header shield pip with an unread count](../screenshots/190_mod_note_header_pip_visible.png)

### Browser tab title prefixed with `(N)`

`document.title` is prefixed with the unread count, mirroring the bell. The prefix is added by wrapping the global `title` setter so route transitions never drop it.

![Browser tab title prefixed with the unread count](../screenshots/191_mod_note_browser_title_prefix.png)

### Header pip and title prefix cleared after the shield tab is opened

Opening the shield tab marks the feed as seen (`POST /notes-feed/seen` updates `mod_notes_seen_at` and publishes a `reset` on the dedicated MessageBus channel). The pip and the `(N)` prefix both disappear without a hard refresh.

![Header pip and title prefix cleared](../screenshots/192_mod_note_header_indicators_cleared_after_seen.png)

---

## First-post checklist

### The checklist editor — empty

The config modal, opened from the **First-post checklist** link in the sidebar's Community section. With no items yet, it shows the "inactive" notice — nothing is shown to users until at least one item is added.

![The checklist editor, empty](../screenshots/51_checklist_editor_empty.png)

### The checklist editor — filled in

A moderator has added two checklist items (each with optional link), chosen the trust-level audience, and set custom accept-button text.

![The checklist editor, filled in](../screenshots/52_checklist_editor_filled.png)

### The checklist editor — saved

After **Save checklist**, the green "Saved" confirmation appears and the items round-trip back into the editor.

![The checklist editor, saved](../screenshots/53_checklist_editor_saved.png)

### The checklist modal — a new user's first post

A trust-level-0 user who tries to post for the first time is shown the checklist modal before the post goes through. The accept button is disabled until every box is ticked.

![The checklist modal for a new user](../screenshots/54_tl0_checklist_modal.png)

### The checklist modal — all boxes ticked

Once the user ticks every item, the accept button (with its staff-set label) becomes enabled.

![The checklist modal with all boxes ticked](../screenshots/55_tl0_modal_all_checked.png)

### The reply posts after accepting

After the user accepts the checklist, their reply is posted to the topic as normal.

![The reply posted after accepting the checklist](../screenshots/56_tl0_reply_posted_after_accept.png)

### The second post is not gated

The same user's next post goes straight through — the checklist is shown only until it is accepted once.

![The user's second post is not prompted](../screenshots/57_tl0_second_post_no_prompt.png)

### The checklist applies across the trust-level cap

With the audience set to "Up to members (TL0 to TL2)", a trust-level-1 user is also shown the checklist.

![A TL1 user sees the checklist](../screenshots/58_tl1_checklist_modal.png)

### The checklist version is bumped on edit

Each save bumps the checklist version, shown in the editor.

![The checklist version bumped](../screenshots/59_checklist_version_bumped.png)

### A user is re-prompted after a version bump

A user who already accepted an older version is shown the checklist again after staff publish a new version.

![A user re-prompted after a version bump](../screenshots/60_reprompt_after_version_bump.png)

### The acceptance audit log

The editor lists every acceptance — the user, the version they accepted, and when — with a count and a current-version filter.

![The acceptance audit log](../screenshots/61_checklist_acceptance_log.png)

## Moderator whisper

### The whisper button in the composer

A staff member's reply composer shows the whisper (eye) toolbar button.

![The whisper button in the composer](../screenshots/62_composer_whisper_button.png)

### The whisper target modal — empty

Clicking the whisper button opens a modal to pick which user(s) the whisper goes to.

![The whisper target modal, empty](../screenshots/63_whisper_target_modal_empty.png)

### The whisper target modal — users selected

The moderator has chosen the recipients of the whisper.

![The whisper target modal with users selected](../screenshots/64_whisper_target_modal_users_selected.png)

### The armed-whisper pill

With a whisper armed, the composer shows a pill naming the recipients and tints to signal the reply will be a whisper.

![The armed-whisper pill](../screenshots/65_whisper_armed_pill.png)

### A staff whisper posted, with its banner

The posted whisper renders with a full-width banner listing who it was whispered to.

![A staff whisper posted with its banner](../screenshots/66_staff_whisper_posted_banner.png)

### A recipient sees the whisper

A targeted user sees the whisper post and its banner in the topic.

![A recipient sees the whisper](../screenshots/67_recipient_sees_whisper.png)

### A non-recipient does not see the whisper

A user who is not in the whisper's audience never sees the post.

![A non-recipient does not see the whisper](../screenshots/68_stranger_does_not_see_whisper.png)

### Staff oversight

Any staff member — not just the author or targets — can see every whisper in the topic.

![Staff oversight of whispers](../screenshots/69_staff_oversight.png)

### A whispered-to user can whisper back

Once staff have whispered to a user, that user's reply composer auto-arms a staff-only whisper-back.

![A participant's whisper-back armed](../screenshots/70_participant_whisper_back_armed.png)

### The whisper-back banner

A user's whisper-back posts with a banner showing it is addressed to staff.

![The whisper-back banner](../screenshots/71_whisper_back_banner.png)

### A non-participant cannot whisper

A non-staff user who has never been whispered to cannot start a whisper.

![A non-participant cannot whisper](../screenshots/72_non_participant_no_op.png)

### The site setting

The `mod_whisper_enabled` site setting, on by default.

![The whisper site setting](../screenshots/73_site_setting_page.png)

### With the plugin disabled

When the feature is off, a former whisper is visible to everyone like a normal post.

![A whisper with the plugin disabled](../screenshots/74_plugin_disabled_visible_to_all.png)

## Permissions

### A regular user sees no moderator controls

A non-staff member has no topic admin menu and no Moderator Actions button — the moderator features are staff-only.

![A regular user sees no moderator controls](../screenshots/19_regular_user_no_mod_button.png)

---

## Moderator category management

### The categories list as a moderator

The main `/categories` page as a moderator — the plugin's master switch lets staff see and curate every category.

![Moderator-view categories list](../screenshots/104_moderator_categories_list.png)

### The categories page chrome

The categories page header as a moderator sees it, with the standard navigation.

![Categories page chrome for a moderator](../screenshots/105_moderator_categories_page_chrome.png)

### The category Settings tab

The category Settings tab — the home of the per-category new-topic prompt field.

![Category Settings tab](../screenshots/106_category_edit_settings_tab.png)

### The category General tab

The category General tab as a moderator.

![Category General tab](../screenshots/107_category_edit_general_tab.png)

### The category Security tab

The category Security tab as a moderator.

![Category Security tab](../screenshots/108_category_edit_security_tab.png)

### A category's topic list

The topic list inside a category with several topics.

![Category topic list](../screenshots/109_category_topic_list_view.png)

### Category badge in a topic header

A topic header showing the category badge it belongs to.

![Category badge in topic header](../screenshots/110_category_badge_in_topic_header.png)

---

## Per-topic footer message — extra states

### A multi-paragraph markdown footer message

A footer message with multiple paragraphs and a markdown link, cooked as Markdown.

![Multi-paragraph markdown footer](../screenshots/111_footer_multiparagraph_markdown.png)

### A footer with a markdown link

A footer message that includes an inline markdown link to external guidelines.

![Footer with a markdown link](../screenshots/112_footer_with_markdown_link.png)

### The official-notice box with the shield icon

The footer rendered as Discourse's official-notice box, with the shield icon and "Moderator message" label.

![Footer official-notice box](../screenshots/113_footer_shield_icon_box.png)

### Footer on a thread with multiple posts

The footer message still pinned to the bottom of a topic with many replies.

![Footer on multi-post thread](../screenshots/114_footer_on_multi_post_thread.png)

### The modal with only the footer field set

The Moderator Actions modal with only the footer message field filled in.

![Modal with only the footer field set](../screenshots/115_modal_only_footer_field_set.png)

### The modal with only the reply prompt field set

The Moderator Actions modal with only the reply-prompt field filled in.

![Modal with only the reply prompt set](../screenshots/116_modal_only_reply_prompt_set.png)

### Footer on a closed topic with a banner

The footer message still rendered on a closed topic, alongside Discourse's "closed" banner.

![Footer on closed topic with banner](../screenshots/117_footer_on_closed_topic_with_banner.png)

---

## Per-topic reply prompt — extra states

### Reply-prompt audience capped at TL0

The Moderator Actions modal with the reply-prompt audience combo-box set to "Up to new (TL0)".

![Reply prompt audience capped at TL0](../screenshots/118_reply_prompt_audience_capped_tl0.png)

### Reply-prompt audience capped at TL2

The Moderator Actions modal with the reply-prompt audience combo-box set to "Up to members (TL0-TL2)".

![Reply prompt audience capped at TL2](../screenshots/119_reply_prompt_audience_capped_tl2.png)

### A multi-line reply prompt entered

The modal with a multi-line reply prompt — bullet-style guidance plus a URL.

![Modal multi-line reply prompt](../screenshots/120_modal_multiline_reply_prompt.png)

### The reply prompt persisted on reopen

Re-opening the modal shows the previously-saved reply prompt prefilled.

![Modal reopened with reply prompt persisted](../screenshots/121_modal_reopened_reply_prompt_persisted.png)

### Clickable link inside the reply prompt dialog

The user-facing reply confirmation dialog with a clickable URL inside its body.

![Reply prompt clickable link](../screenshots/122_reply_prompt_clickable_link_dialog.png)

### A TL4 user skips a TL1-capped reply prompt

A TL4 leader replying to a topic whose reply prompt is capped at TL1 — no dialog appears, the reply posts directly.

![Reply prompt skipped above cap](../screenshots/123_reply_prompt_skipped_above_cap.png)

---

## Per-category new-topic prompt — extra states

### Live preview with bold and a link

The category Settings live preview rendering a markdown bold plus a linkified URL.

![Category prompt preview — bold + link](../screenshots/124_category_prompt_preview_bold_link.png)

### Live preview with multi-line input

The live preview honouring line breaks in the input.

![Category prompt preview — multi-line](../screenshots/125_category_prompt_preview_multiline.png)

### Audience dropdown set to TL1

The new-topic prompt audience combo-box set to "Up to basic (TL0-TL1)".

![Category prompt audience TL1](../screenshots/126_category_prompt_audience_tl1.png)

### Audience dropdown set to TL0

The new-topic prompt audience combo-box set to "Up to new (TL0)".

![Category prompt audience TL0](../screenshots/127_category_prompt_audience_tl0.png)

### Persisted prompt on revisit

Re-opening the category Settings tab shows the previously-saved prompt and its cap.

![Category prompt persisted state](../screenshots/128_category_prompt_persisted_state.png)

### Empty preview

The live preview area when the prompt field is cleared.

![Category prompt empty preview](../screenshots/129_category_prompt_preview_empty.png)

---

## Pin a post to the bottom — extra states

### Bottom-pinned post as a regular user sees it

A topic with both a footer message and a bottom-pinned post, viewed by a regular user.

![Pinned post — regular user](../screenshots/130_pinned_post_regular_user_view.png)

### In-stream pin badge close-up

The pin badge added to the original post in the post stream.

![Pinned post in-stream badge](../screenshots/131_pinned_post_in_stream_badge.png)

### Jump-to-original on the bottom copy

The bottom-pinned copy includes a jump-to-original anchor link.

![Pinned post — jump to original](../screenshots/132_pinned_post_jump_to_original.png)

### Pinned post alongside a private note

A topic showing both a bottom-pinned post and a staff-only private note.

![Pinned post with private note](../screenshots/133_pinned_post_with_private_note.png)

### Post admin menu while a post is already pinned

The post admin menu showing the **Pin to Bottom** option for a post that is already pinned.

![Post admin menu while pinned](../screenshots/134_post_admin_menu_while_pinned.png)

### Pinned post and footer together, regular user

A regular user's view of a topic that has both a bottom-pinned post and a footer message.

![Pinned and footer — user view](../screenshots/135_pinned_plus_footer_user_view.png)

---

## Per-topic reply approval — extra states

### Approval checkbox unchecked by default

The Moderator Actions modal opened on a fresh topic — the approval checkbox is unchecked.

![Approval checkbox unchecked](../screenshots/136_approval_checkbox_unchecked.png)

### Approval checkbox ticked

The Moderator Actions modal with the approval checkbox just ticked.

![Approval checkbox ticked](../screenshots/137_approval_checkbox_ticked.png)

### Approval checkbox toggled back off

The same modal after toggling the checkbox off again.

![Approval checkbox toggled back off](../screenshots/138_approval_checkbox_untoggled.png)

### Approval state persisted across reopen

Re-opening the modal on a topic that already requires approval — the checkbox is pre-ticked.

![Approval checkbox persisted](../screenshots/139_approval_checkbox_persisted.png)

### Approval with messages filled in

The modal with the approval checkbox ticked plus the footer/reply-prompt fields filled in.

![Approval with messages filled](../screenshots/140_approval_with_messages_filled.png)

### Topic view as a regular user — no approval UI

A regular user viewing a topic that requires reply approval — no extra UI is surfaced to them.

![Approval — user view](../screenshots/141_approval_topic_view_regular_user.png)

---

## Private moderator note — extra states

### Note positioned at the top

A private moderator note configured to render at the top of the topic.

![Private note — position top](../screenshots/142_private_note_position_top.png)

### Note positioned at the bottom

A private moderator note configured to render at the bottom of the topic.

![Private note — position bottom](../screenshots/143_private_note_position_bottom.png)

### Note thread with three staff replies

A private note plus a three-message staff-only reply thread.

![Private note — three replies](../screenshots/144_private_note_three_replies_thread.png)

### Edit and delete affordances on a reply

A note reply showing its inline edit and delete buttons.

![Private note — edit/delete affordances](../screenshots/145_private_note_reply_edit_delete_affordances.png)

### Drafting a reply in the reply composer

The note's reply composer open with text being drafted.

![Private note reply composer drafting](../screenshots/146_private_note_reply_composer_drafting.png)

### Regular user — no private-note DOM node

A regular user viewing a topic that has a private note — no DOM node for the note exists.

![Private note hidden from user — no node](../screenshots/147_private_note_user_no_node.png)

### Anonymous visitor — no private note

An anonymous visitor viewing the same topic — the private note is absent.

![Private note — anonymous view](../screenshots/148_private_note_anonymous_view.png)

---

## Moderator-notes user-menu tab — extra states

### Shield tab with an unread badge

The user menu shield tab showing an unread badge for newly-arrived moderator notes.

![Shield tab with unread badge](../screenshots/149_user_menu_shield_tab_with_unread.png)

### Notes panel listing multiple entries

The moderator-notes panel listing several notes from across the forum.

![Notes panel — multiple entries](../screenshots/150_notes_panel_multiple_entries.png)

### Notes panel with a single entry

The notes panel scrolled to a single-entry state.

![Notes panel — single entry](../screenshots/151_notes_panel_single_entry.png)

### Notes panel after the seen marker is recorded

The notes panel as it looks after `mod_notes_seen_at` has been recorded.

![Notes panel — after seen](../screenshots/152_notes_panel_after_seen.png)

### Empty-state notes panel

The notes panel when there are no moderator notes anywhere on the forum.

![Notes panel — empty state](../screenshots/153_notes_panel_empty_state.png)

### Notes panel — clicking a note navigates

Clicking a note entry lands the staff member on its topic.

![Notes panel link navigated](../screenshots/154_notes_panel_link_navigated.png)

---

## First-post checklist — extra states

### Inactive notice in the editor

The checklist editor's inactive notice when no items have been configured yet.

![Checklist editor inactive notice](../screenshots/155_checklist_editor_inactive_notice.png)

### Checklist editor with a custom button label

The editor populated with a checklist whose accept-button label has been overridden.

![Checklist editor — custom button label](../screenshots/156_checklist_editor_custom_button_label.png)

### Checklist editor audience set to TL1

The editor with the audience combo-box set to "Up to basic (TL0-TL1)".

![Checklist editor — audience TL1](../screenshots/157_checklist_editor_audience_tl1.png)

### "Last updated" line on the user-facing modal

The user-facing checklist modal showing its "Last updated" line.

![Checklist user modal — last updated](../screenshots/158_checklist_user_modal_last_updated.png)

### Custom button label on the user-facing modal

The user-facing checklist modal with the staff-set custom accept-button label.

![Checklist user modal — custom button](../screenshots/159_checklist_user_modal_custom_button.png)

### Audit log with many entries

The acceptance audit log populated with five entries across multiple versions and users.

![Checklist audit log — many entries](../screenshots/160_checklist_audit_log_many_entries.png)

### Targeted checklist listed in the editor

The editor showing a targeted checklist alongside the global one.

![Targeted checklist listed](../screenshots/161_targeted_checklist_listed.png)

### TL2 user prompted under a TL0-TL2 cap

A TL2 user prompted with the checklist because the audience cap is TL2.

![Checklist — TL2 user prompted](../screenshots/162_checklist_tl2_user_prompted.png)

---

## Moderator whisper — extra states

### Whisper banner with one target

A staff whisper post with a single targeted user in its banner.

![Whisper banner — one target](../screenshots/163_whisper_banner_one_target.png)

### Whisper banner with three targets

A staff whisper post with three targeted users listed in its banner.

![Whisper banner — three targets](../screenshots/164_whisper_banner_three_targets.png)

### Staff-only whisper banner

A staff-only whisper post (no user targets) — banner indicates the whisper is to staff.

![Whisper banner — staff only](../screenshots/165_whisper_banner_staff_only.png)

### Group-targeted whisper banner

A whisper targeted at a group, with the group name shown in the banner.

![Whisper banner — group target](../screenshots/166_whisper_banner_group_target.png)

### Armed-whisper pill with a single user

The composer's armed-whisper pill showing a single chosen recipient.

![Armed whisper pill — single user](../screenshots/167_armed_whisper_pill_single_user.png)

### Add-participant modal with a chosen user

The whisper add-participant modal with a user picked, ready to confirm.

![Add-participant modal — user chosen](../screenshots/168_whisper_add_participant_modal_user_chosen.png)

### Non-participant topic view

A non-participant user viewing the topic — the whisper post is absent.

![Whisper — non-participant view](../screenshots/169_whisper_non_participant_view.png)

### Recipient topic view

A whisper recipient's view of the topic — the banner is visible.

![Whisper — recipient view](../screenshots/170_whisper_recipient_full_view.png)
