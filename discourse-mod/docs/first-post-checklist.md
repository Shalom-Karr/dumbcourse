# First-post checklist

A forum-wide checklist a not-yet-trusted user must tick before they are
allowed to post for the first time.

## What it is

When the plugin is enabled (`mod_categories_enabled`), staff can define a
list of checklist items — each a line of text plus an optional link to a
post or page. A user whose trust level is at or below the configured cap
who tries to create a topic or post a reply is shown a modal listing those
items; every box must be ticked before the post goes through. Staff
(moderators and admins) never see it.

Once a user accepts the checklist it is not shown again — unless staff
edit it, which re-prompts everyone (see *Versioning* below).

## How a moderator configures it

Any staff member (moderator or admin) clicks **First-post checklist** in
the sidebar's **Community** section — it opens the checklist editor in a
modal. The editor lets you:

- **Add item** — appends a blank row.
- Edit each row's **Checkbox text** (required) and **Link URL** (optional).
  One row makes a single agreement; several rows make a multi-checkbox
  list.
- **Remove item** — deletes a row.
- **Move up / move down** — the up/down arrows on each row reorder the
  items; the saved order is the order users see in the checklist modal.
- **Who must accept before their next post** — the trust-level cap:
  - *New users only (TL0)*
  - *New and basic users (TL0 and TL1)*
  - *Up to members (TL0 to TL2)* — the default.
- **Accept button text** — what the modal's confirm button says; leave
  blank for the default ("I agree, post").
- **Save checklist** — persists the list.

A row with a blank checkbox text is dropped on save. Saving an empty list
disables the feature (nothing to confirm, so the modal never appears).

## What the user sees

On their first topic or reply, the user gets a *Before you post* modal
listing each item as a checkbox. Items with a link show an **Open link**
button beside them (opens in a new tab). The **I agree, post** button
stays disabled until every box is ticked; **Cancel** aborts the post and
returns to the composer with content intact.

A **Last updated** line under the intro shows when staff last saved the
checklist — a relative time (e.g. *2 days ago*) with the exact timestamp
on hover, the same format the acceptance log uses.

## Acceptance audit log

The checklist editor shows an **Acceptance log** below the items — a
table of every acceptance, newest first, with the **user**, the checklist
**version** they accepted, and **when**. Because the checklist is
versioned, the log shows a fresh row each time a user re-accepts after a
bump, so staff can see who has acknowledged the current version. The log
keeps the most recent 500 entries.

Each log row also has a **Require re-accept** button. Clicking it resets
that user's recorded forum-wide checklist version to 0, so the modal
appears again on their next post. A toast confirms the reset.

## Targeted checklists

Below the audit log the editor has a **Targeted checklists** section. A
*targeted checklist* is a whole separate checklist aimed at specific
users — its own name, target users, item rows, accept-button text, and
version. Staff can create several.

A targeted checklist applies to its listed users **regardless of trust
level or staff status** — a targeted moderator or admin still has to
accept it, and a high-trust user above the forum-wide cap still sees it.

Each targeted checklist offers:

- **Name** — a label for staff.
- **Target users** — a user picker (users only, no groups).
- Item rows — the same **Checkbox text** / **Link URL** rows as the
  forum-wide editor.
- **Accept button text**.
- **Save targeted checklist** — creates it (version 1) or updates it
  (bumping its version, which re-prompts its users).
- **Delete** — removes it.

When a user owes more than one checklist, they are shown one per post.
Targeted checklists take priority over the forum-wide checklist; the
highest-priority owed one is shown each time.

## Versioning / re-prompting

The checklist carries a version number. Every **Save** bumps it. A user
records the highest version they have accepted; when the published
version is newer than what they accepted, the modal appears again on
their next post. This lets staff revise the checklist and be sure every
new member re-confirms.

Re-prompting works **mid-session, without a hard page refresh**. Discourse
is a single-page app, so the `currentUser.mod_first_post_checklist` value
bootstrapped on page load goes stale once the user accepts (it is cleared
to `null`) or once staff bump the version. To avoid trusting that stale
value, the composer gate re-fetches `GET /checklist/owed` every time the
user clicks post; the modal then reflects the current server state. A
version bumped while the user is browsing is therefore caught on their
next post, with no reload needed.

## Storage & API

- **Config:** plugin store, namespace `discourse_mod_categories`, key
  `first_post_checklist` —
  `{ version, items: [{ label, url }], max_tl, button_label, updated_at }`.
  `updated_at` is an ISO8601 timestamp set on every save.
- **Targeted checklists:** plugin store, same namespace, key
  `targeted_checklists` — a JSON array of
  `{ id, name, user_ids: [Integer], items: [{ label, url }], version,
  button_label, updated_at }`. `id` is a stable `SecureRandom.hex(8)`;
  `updated_at` is set on create and on every update.
- **Audit log:** plugin store, same namespace, key
  `first_post_checklist_log` — an append-only array of
  `{ user_id, version, at, kind, checklist_id }`, capped at the latest
  500 entries.
- **Per-user:** `mod_checklist_accepted_version` user custom field (the
  highest forum-wide version that user has accepted), and
  `mod_checklist_targeted_accepted` (a json map
  `{ checklist_id => accepted_version }`).
- **Endpoints** (engine-mounted at `/discourse-mod-categories`):
  - `GET /checklist` — current forum-wide checklist, audit log, and
    targeted checklists (staff only).
  - `GET /checklist/owed` — the single checklist the current user still
    owes, as `{ checklist: { kind, id, version, items, button_label,
    updated_at } }` or `{ checklist: null }`. Any logged-in user; runs the
    same `DiscourseModCategories.owed_checklist_for` logic as the
    `mod_first_post_checklist` serializer. The composer gate polls this so
    a mid-session version bump is caught without a hard page refresh.
  - `PUT /checklist` — replace the forum-wide checklist, bump the version
    (staff only, `Guardian#can_manage_mod_messages?`).
  - `POST /checklist/accept` — record the current user's acknowledgement;
    takes `kind` (`"global"` or `"targeted"`), `version`, and `id` for a
    targeted checklist. The accepted version is clamped to the published
    version.
  - `POST /checklist/require-reaccept` — reset a user's forum-wide
    accepted version to 0 (staff only); takes `username` or `user_id`.
  - `POST /checklist/targeted` — create a targeted checklist (staff only).
  - `PUT /checklist/targeted/:id` — update a targeted checklist, bumping
    its version (staff only).
  - `DELETE /checklist/targeted/:id` — delete a targeted checklist (staff
    only).
- The current-user serializer exposes `mod_first_post_checklist` as the
  single checklist the user most needs. It carries a `kind` discriminator:
  a `"targeted"` checklist (shown to its listed users regardless of trust
  level or staff status) takes priority over the `"global"` forum-wide
  checklist (non-staff TL0-TL2 only). It is `null` when nothing is owed.

## Implementation

- The composer initializer
  (`assets/javascripts/discourse/initializers/precheck-prompt.js`) hooks
  `composerBeforeSave`; the checklist gate runs before the moderator
  prompt gate. The gate first calls `refreshOwedChecklist`
  (`assets/javascripts/discourse/lib/first-post-checklist.js`), which
  fetches `GET /checklist/owed` and writes the result onto
  `currentUser.mod_first_post_checklist`, so the gate always reads current
  server state rather than the stale bootstrapped value.
- The owed-checklist computation is shared:
  `DiscourseModCategories.owed_checklist_for(user)` in `plugin.rb` backs
  both the `mod_first_post_checklist` serializer and the `/checklist/owed`
  endpoint, so the two cannot diverge.
- The modal is the `ModFirstPostChecklist` component; the editor page is
  the `ModChecklistModal` component (opened from the sidebar) rendering
  `ModChecklistEditor`.
