import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { getOwner } from "@ember/owner";
import { service } from "@ember/service";
import icon from "discourse/helpers/d-icon";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { i18n } from "discourse-i18n";

// Panel rendered inside the staff "Moderator notes" user-menu tab. Lists
// recent moderator notes across topics and marks the feed as seen.
export default class ModNotesPanel extends Component {
  @service currentUser;

  @tracked notes = [];
  @tracked loading = true;

  constructor() {
    super(...arguments);
    this.load();
  }

  // Close the user menu when the staff member clicks a note. The bare
  // `<a href>` navigates outside Ember's router, so the panel doesn't
  // get torn down by a route transition — the menu otherwise stays
  // pinned open and has to be slid away manually.
  @action
  closeUserMenu() {
    const owner = getOwner(this);
    const userMenu =
      owner?.lookup?.("service:user-menu") ||
      owner?.lookup?.("service:userMenu");
    if (typeof userMenu?.close === "function") {
      userMenu.close();
      return;
    }
    // Older Discourse versions exposed the toggler on the header service.
    const header =
      owner?.lookup?.("service:header") ||
      owner?.lookup?.("service:header-state");
    if (typeof header?.hideUserMenu === "function") {
      header.hideUserMenu();
    } else if (typeof header?.toggleUserMenu === "function") {
      header.toggleUserMenu();
    }
  }

  async load() {
    try {
      const result = await ajax("/discourse-mod-categories/notes-feed.json");
      this.notes = result.notes || [];
    } catch (error) {
      popupAjaxError(error);
    } finally {
      this.loading = false;
    }

    try {
      await ajax("/discourse-mod-categories/notes-feed/seen.json", {
        type: "POST",
      });
      this.currentUser?.set("mod_note_unread_count", 0);
    } catch {
      // Marking the feed as seen is best-effort.
    }
  }

  <template>
    <div class="mod-notes-panel">
      {{#if this.loading}}
        <div class="mod-notes-empty">
          {{i18n "discourse_mod_categories.notes_tab.loading"}}
        </div>
      {{else if this.notes.length}}
        <ul class="mod-notes-list">
          {{#each this.notes as |note|}}
            <li
              class="mod-notes-item
                {{if note.unread 'mod-notes-item--unread'}}"
            >
              <a
                href={{note.url}}
                class="mod-notes-item-link"
                {{on "click" this.closeUserMenu}}
              >
                {{icon "shield-halved"}}
                <span class="mod-notes-item-body">
                  <span class="mod-notes-item-title">
                    {{note.topic_title}}
                  </span>
                  <span class="mod-notes-item-note">{{note.note}}</span>
                </span>
              </a>
            </li>
          {{/each}}
        </ul>
      {{else}}
        <div class="mod-notes-empty">
          {{i18n "discourse_mod_categories.notes_tab.empty"}}
        </div>
      {{/if}}
    </div>
  </template>
}
