# frozen_string_literal: true

# name: discourse-dumbcourse
# about: Dumbcourse SPA under /dumb with push notifications, plus forum-moderator workflow features (categories, footer messages, prompts, checklists, whisper, private notes)
# version: 0.3.0
# authors: Shalom Karr, Usher Weiss, Avrumi Sternheim
# url: https://github.com/TripleU613/dumbcourse
# required_version: 2.7.0

# =============================================================================
# DUMBCOURSE — unchanged from upstream
# =============================================================================
module ::DiscourseDumbcourse
  PLUGIN_NAME = "discourse-dumbcourse"

  def self.base_path
    path = SiteSetting.dumbcourse_base_path.to_s.strip
    path = "dumb" if path.blank?
    path = path.sub(%r{\A/+}, "").sub(%r{/+\z}, "")
    path = "dumb" if path.blank?
    path
  end

  def self.base_path_with_slash
    "/#{base_path}"
  end

  module RequiresPluginFallback
    def requires_plugin(*)
      # no-op for older Discourse versions
    end
  end
end

unless ::ActionController::Base.respond_to?(:requires_plugin)
  ::ActionController::Base.extend(::DiscourseDumbcourse::RequiresPluginFallback)
end

require_relative "lib/discourse_dumbcourse/engine"
require_relative "lib/discourse_dumbcourse/push_sender"

# =============================================================================
# DISCOURSE-MOD — forum-moderator workflow features
#
# All Ruby code for these features lives under the `discourse-mod/` subfolder
# (specs, docs, screenshots too). JS connectors / initializers must live at
# the standard `assets/javascripts/discourse/...` path because Discourse's
# Ember plugin loader scans that path only — our JS files are filename-prefixed
# (`mod-*`, `precheck-*`) to stay visually distinct from the dumbcourse files.
# =============================================================================
require_relative "discourse-mod/lib/discourse_mod_categories/guardian_extensions"
require_relative "discourse-mod/lib/discourse_mod_categories/whisper_query_filter"

register_asset "discourse-mod/assets/stylesheets/topic-footer-message.scss"
register_asset "discourse-mod/assets/stylesheets/whisper.scss"
register_asset "discourse-mod/assets/stylesheets/mod-note-header-pip.scss"

register_svg_icon "list-check"
register_svg_icon "shield-halved"
register_svg_icon "user-plus"
register_svg_icon "pencil"
register_svg_icon "trash-can"

module ::DiscourseModCategories
  # Custom-field keys for the moderator-set messages.
  TOPIC_FOOTER_FIELD = "mod_topic_footer_message"
  TOPIC_REPLY_PROMPT_FIELD = "mod_topic_reply_prompt"
  TOPIC_PINNED_POST_FIELD = "mod_topic_pinned_post_id"
  TOPIC_REQUIRE_REPLY_APPROVAL_FIELD = "mod_topic_require_reply_approval"
  TOPIC_PRIVATE_NOTE_FIELD = "mod_topic_private_note"
  TOPIC_PRIVATE_NOTE_POSITION_FIELD = "mod_topic_private_note_position"
  TOPIC_PRIVATE_NOTE_USER_FIELD = "mod_topic_private_note_user_id"
  TOPIC_PRIVATE_NOTE_CREATED_AT_FIELD = "mod_topic_private_note_created_at"
  TOPIC_PRIVATE_NOTE_REPLIES_FIELD = "mod_topic_private_note_replies"
  TOPIC_PRIVATE_NOTE_ACTIVITY_FIELD = "mod_topic_private_note_activity_at"
  USER_NOTES_SEEN_FIELD = "mod_notes_seen_at"
  CATEGORY_NEW_TOPIC_PROMPT_FIELD = "mod_category_new_topic_prompt"
  # Highest trust level still shown a prompt (0-3); 4/blank means everyone.
  TOPIC_REPLY_PROMPT_TL_FIELD = "mod_topic_reply_prompt_max_tl"
  CATEGORY_NEW_TOPIC_PROMPT_TL_FIELD = "mod_category_new_topic_prompt_max_tl"
  # Forum-wide first-post checklist: the config lives in the plugin store,
  # and each user records the highest checklist version they have accepted.
  USER_CHECKLIST_VERSION_FIELD = "mod_checklist_accepted_version"
  CHECKLIST_STORE_NAMESPACE = "discourse_mod_categories"
  CHECKLIST_STORE_KEY = "first_post_checklist"
  # Append-only audit log of checklist acceptances.
  CHECKLIST_LOG_KEY = "first_post_checklist_log"
  # Targeted checklists: separate checklists aimed at specific users,
  # stored as a JSON array under this key. A per-user json map records the
  # version each targeted checklist was last accepted at.
  TARGETED_CHECKLISTS_KEY = "targeted_checklists"
  USER_TARGETED_CHECKLIST_FIELD = "mod_checklist_targeted_accepted"
  # Per-topic prompt checklist: an opt-in checklist attached to a single
  # topic. The checklist itself lives on the topic custom field; each user
  # records which version (per topic id) they have accepted in their own
  # json map custom field.
  TOPIC_PROMPT_CHECKLIST_FIELD = "mod_topic_prompt_checklist"
  USER_TOPIC_CHECKLIST_FIELD = "mod_topic_checklist_accepted"

  # The current checklist config, or nil when none is set. Shape:
  #   { "version" => Integer, "items" => [{ "label" =>, "url" => }],
  #     "updated_at" => ISO8601 String }
  def self.checklist_config
    PluginStore.get(CHECKLIST_STORE_NAMESPACE, CHECKLIST_STORE_KEY)
  end

  # The single checklist the given user most needs to accept before they
  # can post, or nil so the caller can skip the modal.
  def self.owed_checklist_for(user, topic_id: nil)
    return nil unless user
    return nil unless SiteSetting.mod_categories_enabled

    targeted_accepted = user.custom_fields[USER_TARGETED_CHECKLIST_FIELD]
    targeted_accepted = {} unless targeted_accepted.is_a?(Hash)

    owed_targeted =
      targeted_checklists.find do |checklist|
        items = checklist["items"]
        next false unless items.is_a?(Array) && items.any?
        next false unless Array(checklist["user_ids"]).map(&:to_i).include?(
          user.id,
        )
        checklist["version"].to_i > targeted_accepted[checklist["id"]].to_i
      end

    if owed_targeted
      return(
        {
          kind: "targeted",
          id: owed_targeted["id"],
          version: owed_targeted["version"].to_i,
          items: owed_targeted["items"],
          button_label: owed_targeted["button_label"].to_s,
          updated_at: owed_targeted["updated_at"],
        }
      )
    end

    if topic_id.present?
      topic_checklist = topic_prompt_checklist(topic_id)
      if topic_checklist
        mode = topic_checklist["mode"].to_s
        mode = "checklist" unless %w[statement checklist].include?(mode)
        frequency = topic_checklist["frequency"].to_s
        frequency = "once" unless %w[once every_reply].include?(frequency)

        max_tl =
          if topic_checklist.key?("max_tl")
            topic_checklist["max_tl"].to_i
          else
            4
          end

        below_cap = !user.staff? && user.trust_level > max_tl

        unless below_cap
          version = topic_checklist["version"].to_i
          accepted_version = 0
          if frequency == "once"
            accepted_map = user.custom_fields[USER_TOPIC_CHECKLIST_FIELD]
            accepted_map = JSON.parse(accepted_map) rescue {} if accepted_map.is_a?(String)
            accepted_map = {} unless accepted_map.is_a?(Hash)
            accepted_version = accepted_map[topic_id.to_s].to_i
          end

          if frequency == "every_reply" || version > accepted_version
            return(
              {
                kind: "topic",
                id: topic_id.to_i,
                version: version,
                mode: mode,
                statement: topic_checklist["statement"].to_s,
                items: topic_checklist["items"],
                frequency: frequency,
                max_tl: max_tl,
                button_label: topic_checklist["button_label"].to_s,
                updated_at: topic_checklist["updated_at"],
              }
            )
          end
        end
      end
    end

    return nil if user.staff?

    config = checklist_config
    return nil unless config

    items = config["items"]
    return nil unless items.is_a?(Array) && items.any?

    max_tl = config.key?("max_tl") ? config["max_tl"].to_i : 2
    return nil if user.trust_level > max_tl

    version = config["version"].to_i
    accepted = user.custom_fields[USER_CHECKLIST_VERSION_FIELD].to_i
    return nil if accepted >= version

    {
      kind: "global",
      version: version,
      items: items,
      button_label: config["button_label"].to_s,
      updated_at: config["updated_at"],
    }
  end

  def self.topic_prompt_checklist(topic_id)
    return nil if topic_id.blank?
    topic = Topic.find_by(id: topic_id)
    return nil unless topic

    raw = topic.custom_fields[TOPIC_PROMPT_CHECKLIST_FIELD]
    raw = JSON.parse(raw) rescue nil if raw.is_a?(String)
    return nil unless raw.is_a?(Hash)

    mode = raw["mode"].to_s
    mode = "checklist" unless %w[statement checklist].include?(mode)

    if mode == "statement"
      return nil if raw["statement"].to_s.strip.empty?
    else
      items = raw["items"]
      return nil unless items.is_a?(Array) && items.any?
    end

    raw
  end

  def self.targeted_checklists
    raw = PluginStore.get(CHECKLIST_STORE_NAMESPACE, TARGETED_CHECKLISTS_KEY)
    raw.is_a?(Array) ? raw : []
  end

  # Moderator whisper custom fields.
  POST_WHISPER_TARGETS_FIELD = "mod_whisper_target_user_ids"
  POST_WHISPER_TARGET_GROUPS_FIELD = "mod_whisper_target_group_ids"
  TOPIC_WHISPER_PARTICIPANTS_FIELD = "mod_whisper_participant_ids"
  MAX_WHISPER_TARGETS = 10
  POST_WHISPER_ARMED_PARAM = "mod_whisper"

  class Engine < ::Rails::Engine
    engine_name "discourse_mod_categories"
    isolate_namespace DiscourseModCategories

    # Override the engine's routes file location so it does not collide
    # with dumbcourse's config/routes.rb at the plugin root. Without this,
    # both engines would load the SAME plugin-root config/routes.rb (their
    # Engine.root is identical), redrawing every route and re-mounting
    # both engines twice on each routes-reloader pass — Rails then raises
    # 'Invalid route name, already in use: discourse_dumbcourse'.
    config.paths["config/routes.rb"] =
      File.expand_path("discourse-mod/config/routes.rb", __dir__)
  end
end

# =============================================================================
# Shared after_initialize: dumbcourse block first, then discourse-mod.
# =============================================================================
after_initialize do
  # ---------------------------------------------------------------------------
  # DUMBCOURSE — unchanged from upstream
  # ---------------------------------------------------------------------------
  enabled_site_setting :dumbcourse_enabled

  on(:notification_created) do |notification|
    next unless SiteSetting.dumbcourse_push_enabled

    Jobs.enqueue_in(2.seconds, :dumbcourse_push_notify, notification_id: notification.id)
  end

  module ::Jobs
    class DumbcoursePushNotify < ::Jobs::Base
      def execute(args)
        unless SiteSetting.dumbcourse_push_enabled
          Rails.logger.info(
            "[Dumbcourse Push Job] Push disabled, skipping notification #{args[:notification_id]}",
          )
          return
        end

        notification = Notification.find_by(id: args[:notification_id])
        unless notification
          Rails.logger.warn(
            "[Dumbcourse Push Job] Notification #{args[:notification_id]} not found (deleted?)",
          )
          return
        end

        Rails.logger.info(
          "[Dumbcourse Push Job] Processing notification #{notification.id} type=#{notification.notification_type} user=#{notification.user_id}",
        )
        DiscourseDumbcourse::PushSender.notify_notification(notification)
      end
    end
  end

  # ---------------------------------------------------------------------------
  # DISCOURSE-MOD — forum-moderator workflow features
  # ---------------------------------------------------------------------------
  require_relative "discourse-mod/app/controllers/discourse_mod_categories/messages_controller"
  require_relative "discourse-mod/app/controllers/discourse_mod_categories/checklist_controller"

  reloadable_patch { ::Guardian.prepend(DiscourseModCategories::GuardianExtensions) }

  register_topic_custom_field_type(DiscourseModCategories::TOPIC_FOOTER_FIELD, :string)
  register_topic_custom_field_type(DiscourseModCategories::TOPIC_REPLY_PROMPT_FIELD, :string)
  register_topic_custom_field_type(DiscourseModCategories::TOPIC_PINNED_POST_FIELD, :integer)
  register_topic_custom_field_type(DiscourseModCategories::TOPIC_REQUIRE_REPLY_APPROVAL_FIELD, :boolean)
  register_topic_custom_field_type(DiscourseModCategories::TOPIC_PRIVATE_NOTE_FIELD, :string)
  register_topic_custom_field_type(DiscourseModCategories::TOPIC_PRIVATE_NOTE_POSITION_FIELD, :string)
  register_topic_custom_field_type(DiscourseModCategories::TOPIC_PRIVATE_NOTE_USER_FIELD, :integer)
  register_topic_custom_field_type(DiscourseModCategories::TOPIC_PRIVATE_NOTE_CREATED_AT_FIELD, :string)
  register_topic_custom_field_type(DiscourseModCategories::TOPIC_PRIVATE_NOTE_REPLIES_FIELD, :json)
  register_topic_custom_field_type(DiscourseModCategories::TOPIC_PRIVATE_NOTE_ACTIVITY_FIELD, :string)
  register_user_custom_field_type(DiscourseModCategories::USER_NOTES_SEEN_FIELD, :string)
  register_user_custom_field_type(DiscourseModCategories::USER_CHECKLIST_VERSION_FIELD, :integer)
  register_user_custom_field_type(DiscourseModCategories::USER_TARGETED_CHECKLIST_FIELD, :json)
  register_topic_custom_field_type(DiscourseModCategories::TOPIC_PROMPT_CHECKLIST_FIELD, :json)
  register_user_custom_field_type(DiscourseModCategories::USER_TOPIC_CHECKLIST_FIELD, :json)
  register_category_custom_field_type(DiscourseModCategories::CATEGORY_NEW_TOPIC_PROMPT_FIELD, :string)
  register_topic_custom_field_type(DiscourseModCategories::TOPIC_REPLY_PROMPT_TL_FIELD, :integer)
  register_category_custom_field_type(DiscourseModCategories::CATEGORY_NEW_TOPIC_PROMPT_TL_FIELD, :integer)

  add_to_serializer(:topic_view, :mod_topic_footer_message) do
    object.topic.custom_fields[DiscourseModCategories::TOPIC_FOOTER_FIELD]
  end
  add_to_serializer(:topic_view, :mod_topic_reply_prompt) do
    object.topic.custom_fields[DiscourseModCategories::TOPIC_REPLY_PROMPT_FIELD]
  end
  add_to_serializer(:topic_view, :mod_topic_reply_prompt_max_tl) do
    object.topic.custom_fields[DiscourseModCategories::TOPIC_REPLY_PROMPT_TL_FIELD]
  end
  add_to_serializer(:topic_view, :mod_topic_pinned_post_id) do
    object.topic.custom_fields[DiscourseModCategories::TOPIC_PINNED_POST_FIELD]
  end
  add_to_serializer(:topic_view, :mod_topic_require_reply_approval) do
    !!object.topic.custom_fields[DiscourseModCategories::TOPIC_REQUIRE_REPLY_APPROVAL_FIELD]
  end

  add_to_serializer(:topic_view, :mod_topic_prompt_checklist) do
    raw = object.topic.custom_fields[DiscourseModCategories::TOPIC_PROMPT_CHECKLIST_FIELD]
    raw = JSON.parse(raw) rescue nil if raw.is_a?(String)
    next nil unless raw.is_a?(Hash)
    items = raw["items"].is_a?(Array) ? raw["items"] : []
    mode = raw["mode"].to_s
    mode = "checklist" unless %w[statement checklist].include?(mode)
    frequency = raw["frequency"].to_s
    frequency = "once" unless %w[once every_reply].include?(frequency)
    max_tl = raw.key?("max_tl") ? raw["max_tl"].to_i : 4
    if mode == "statement"
      next nil if raw["statement"].to_s.strip.empty?
    else
      next nil if items.empty?
    end
    {
      version: raw["version"].to_i,
      mode: mode,
      statement: raw["statement"].to_s,
      items: items,
      frequency: frequency,
      max_tl: max_tl,
      button_label: raw["button_label"].to_s,
      updated_at: raw["updated_at"],
    }
  end

  add_to_serializer(
    :topic_view,
    :mod_topic_private_note,
    include_condition: -> { scope.is_staff? },
  ) { object.topic.custom_fields[DiscourseModCategories::TOPIC_PRIVATE_NOTE_FIELD] }
  add_to_serializer(
    :topic_view,
    :mod_topic_private_note_position,
    include_condition: -> { scope.is_staff? },
  ) { object.topic.custom_fields[DiscourseModCategories::TOPIC_PRIVATE_NOTE_POSITION_FIELD] }
  add_to_serializer(
    :topic_view,
    :mod_topic_private_note_author,
    include_condition: -> { scope.is_staff? },
  ) do
    user_id = object.topic.custom_fields[DiscourseModCategories::TOPIC_PRIVATE_NOTE_USER_FIELD]
    user = user_id && User.find_by(id: user_id)
    if user
      { username: user.username, name: user.name, avatar_template: user.avatar_template }
    end
  end
  add_to_serializer(
    :topic_view,
    :mod_topic_private_note_created_at,
    include_condition: -> { scope.is_staff? },
  ) { object.topic.custom_fields[DiscourseModCategories::TOPIC_PRIVATE_NOTE_CREATED_AT_FIELD] }
  add_to_serializer(
    :topic_view,
    :mod_topic_private_note_replies,
    include_condition: -> { scope.is_staff? },
  ) do
    raw = object.topic.custom_fields[DiscourseModCategories::TOPIC_PRIVATE_NOTE_REPLIES_FIELD]
    entries = raw.is_a?(Array) ? raw : []
    entries.map do |entry|
      author = entry["user_id"] && User.find_by(id: entry["user_id"])
      {
        id: entry["id"].presence || SecureRandom.hex(8),
        raw: entry["raw"].to_s,
        created_at: entry["created_at"],
        author:
          author &&
            { username: author.username, name: author.name, avatar_template: author.avatar_template },
      }
    end
  end

  add_to_serializer(:current_user, :mod_note_unread_count) do
    next 0 unless object.staff?

    seen_at =
      object.custom_fields[DiscourseModCategories::USER_NOTES_SEEN_FIELD].presence ||
        "1970-01-01T00:00:00Z"

    TopicCustomField.where(
      name: DiscourseModCategories::TOPIC_PRIVATE_NOTE_ACTIVITY_FIELD,
    ).where("value > ?", seen_at).count
  end

  add_to_serializer(:current_user, :mod_first_post_checklist) do
    DiscourseModCategories.owed_checklist_for(object)
  end

  NewPostManager.add_handler do |manager|
    topic_id = manager.args[:topic_id]
    next nil if topic_id.blank?

    topic = Topic.find_by(id: topic_id)
    next nil unless topic
    next nil unless topic.custom_fields[DiscourseModCategories::TOPIC_REQUIRE_REPLY_APPROVAL_FIELD]
    next nil if manager.user&.guardian&.can_review_topic?(topic)

    manager.enqueue("mod_topic_requires_reply_approval")
  end

  Site.preloaded_category_custom_fields <<
    DiscourseModCategories::CATEGORY_NEW_TOPIC_PROMPT_FIELD
  Site.preloaded_category_custom_fields <<
    DiscourseModCategories::CATEGORY_NEW_TOPIC_PROMPT_TL_FIELD
  add_to_serializer(:basic_category, :mod_category_new_topic_prompt) do
    object.custom_fields[DiscourseModCategories::CATEGORY_NEW_TOPIC_PROMPT_FIELD]
  end

  # --- Moderator whisper -----------------------------------------------------

  merge_whisper_participants = lambda do |topic, new_ids|
    existing =
      Array(topic.custom_fields[DiscourseModCategories::TOPIC_WHISPER_PARTICIPANTS_FIELD]).map(&:to_i)
    merged = (existing + new_ids.map(&:to_i)).reject { |i| i <= 0 }.uniq
    next if merged.sort == existing.sort

    topic.custom_fields[DiscourseModCategories::TOPIC_WHISPER_PARTICIPANTS_FIELD] = merged
    topic.save_custom_fields(true)
  end

  register_post_custom_field_type(DiscourseModCategories::POST_WHISPER_TARGETS_FIELD, :json)
  register_post_custom_field_type(DiscourseModCategories::POST_WHISPER_TARGET_GROUPS_FIELD, :json)
  register_topic_custom_field_type(DiscourseModCategories::TOPIC_WHISPER_PARTICIPANTS_FIELD, :json)
  add_permitted_post_create_param(DiscourseModCategories::POST_WHISPER_TARGETS_FIELD, :array)
  add_permitted_post_create_param(DiscourseModCategories::POST_WHISPER_TARGET_GROUPS_FIELD, :array)
  add_permitted_post_create_param(DiscourseModCategories::POST_WHISPER_ARMED_PARAM, :string)

  add_to_serializer(:topic_view, :mod_whisper_participant_ids) do
    raw = object.topic.custom_fields[DiscourseModCategories::TOPIC_WHISPER_PARTICIPANTS_FIELD]
    Array(raw).map(&:to_i)
  end

  TopicView.apply_custom_default_scope do |scope, tv|
    DiscourseModCategories::WhisperQueryFilter.apply(scope, tv.guardian&.user)
  end

  on(:before_create_post) do |post, opts|
    next unless SiteSetting.mod_whisper_enabled

    armed =
      ::ActiveModel::Type::Boolean.new.cast(opts[DiscourseModCategories::POST_WHISPER_ARMED_PARAM])
    next unless armed

    normalize_ids =
      lambda do |raw|
        Array(raw)
          .map { |v| v.is_a?(Numeric) || v.is_a?(String) ? v.to_i : 0 }
          .reject { |i| i <= 0 }
          .uniq
          .first(DiscourseModCategories::MAX_WHISPER_TARGETS)
      end

    requested_ids = normalize_ids.call(opts[DiscourseModCategories::POST_WHISPER_TARGETS_FIELD])
    requested_group_ids =
      normalize_ids.call(opts[DiscourseModCategories::POST_WHISPER_TARGET_GROUPS_FIELD])

    author = post.user
    topic = post.topic
    next unless author && topic

    if author.staff?
      valid_ids = ::User.where(id: requested_ids).pluck(:id)
      valid_group_ids = ::Group.where(id: requested_group_ids).pluck(:id)

      post.custom_fields[DiscourseModCategories::POST_WHISPER_TARGETS_FIELD] = valid_ids
      post.custom_fields[DiscourseModCategories::POST_WHISPER_TARGET_GROUPS_FIELD] = valid_group_ids

      non_staff_ids =
        ::User.where(id: valid_ids).where(admin: false, moderator: false).pluck(:id)
      merge_whisper_participants.call(topic, non_staff_ids) if non_staff_ids.any?
    else
      participant_ids =
        Array(topic.custom_fields[DiscourseModCategories::TOPIC_WHISPER_PARTICIPANTS_FIELD]).map(&:to_i)
      next unless participant_ids.include?(author.id)

      post.custom_fields[DiscourseModCategories::POST_WHISPER_TARGETS_FIELD] = []
      post.custom_fields[DiscourseModCategories::POST_WHISPER_TARGET_GROUPS_FIELD] = []
    end
  end

  on(:post_created) do |post, opts, user|
    next unless SiteSetting.mod_whisper_enabled
    next unless post.custom_fields.key?(DiscourseModCategories::POST_WHISPER_TARGETS_FIELD)

    target_ids =
      Array(post.custom_fields[DiscourseModCategories::POST_WHISPER_TARGETS_FIELD]).map(&:to_i)

    recipient_ids =
      if user&.staff?
        target_ids
      else
        ::User.where(admin: true).or(::User.where(moderator: true)).pluck(:id)
      end
    recipient_ids = recipient_ids.uniq - [post.user_id]
    next if recipient_ids.empty?

    topic = post.topic
    data = {
      topic_title: topic&.title,
      display_username: user&.username,
      original_post_id: post.id,
      original_post_type: post.post_type,
    }.to_json

    recipient_ids.each do |recipient_id|
      Notification.create!(
        notification_type: Notification.types[:custom],
        user_id: recipient_id,
        topic_id: topic&.id,
        post_number: post.post_number,
        data: data,
      )
    end
  end

  add_to_serializer(:post, :mod_is_whisper) do
    object.custom_fields.key?(DiscourseModCategories::POST_WHISPER_TARGETS_FIELD)
  end
  add_to_serializer(:post, :include_mod_is_whisper?) { SiteSetting.mod_whisper_enabled }

  add_to_serializer(:post, :mod_whisper_target_user_ids) do
    Array(object.custom_fields[DiscourseModCategories::POST_WHISPER_TARGETS_FIELD]).map(&:to_i)
  end
  add_to_serializer(:post, :include_mod_whisper_target_user_ids?) do
    SiteSetting.mod_whisper_enabled &&
      object.custom_fields.key?(DiscourseModCategories::POST_WHISPER_TARGETS_FIELD)
  end

  add_to_serializer(:post, :mod_whisper_target_group_ids) do
    Array(object.custom_fields[DiscourseModCategories::POST_WHISPER_TARGET_GROUPS_FIELD]).map(&:to_i)
  end
  add_to_serializer(:post, :include_mod_whisper_target_group_ids?) do
    SiteSetting.mod_whisper_enabled &&
      object.custom_fields.key?(DiscourseModCategories::POST_WHISPER_TARGETS_FIELD)
  end

  add_to_serializer(:post, :mod_whisper_target_groups) do
    ids =
      Array(object.custom_fields[DiscourseModCategories::POST_WHISPER_TARGET_GROUPS_FIELD]).map(&:to_i)
    ::Group.where(id: ids).map { |g| { id: g.id, name: g.name } }
  end
  add_to_serializer(:post, :include_mod_whisper_target_groups?) do
    SiteSetting.mod_whisper_enabled &&
      object.custom_fields.key?(DiscourseModCategories::POST_WHISPER_TARGETS_FIELD)
  end

  add_to_serializer(:post, :mod_whisper_targets) do
    ids = Array(object.custom_fields[DiscourseModCategories::POST_WHISPER_TARGETS_FIELD]).map(&:to_i)
    ::User
      .where(id: ids)
      .map { |u| { id: u.id, username: u.username, avatar_template: u.avatar_template } }
  end
  add_to_serializer(:post, :include_mod_whisper_targets?) do
    SiteSetting.mod_whisper_enabled &&
      object.custom_fields.key?(DiscourseModCategories::POST_WHISPER_TARGETS_FIELD)
  end

  add_to_serializer(:post, :mod_whisper_is_staff_only) do
    Array(object.custom_fields[DiscourseModCategories::POST_WHISPER_TARGETS_FIELD]).empty? &&
      Array(object.custom_fields[DiscourseModCategories::POST_WHISPER_TARGET_GROUPS_FIELD]).empty?
  end
  add_to_serializer(:post, :include_mod_whisper_is_staff_only?) do
    SiteSetting.mod_whisper_enabled &&
      object.custom_fields.key?(DiscourseModCategories::POST_WHISPER_TARGETS_FIELD)
  end

  add_to_serializer(:post, :mod_whisper_author_is_staff) { !!object.user&.staff? }
  add_to_serializer(:post, :include_mod_whisper_author_is_staff?) do
    SiteSetting.mod_whisper_enabled &&
      object.custom_fields.key?(DiscourseModCategories::POST_WHISPER_TARGETS_FIELD)
  end

  add_to_serializer(:basic_category, :mod_category_new_topic_prompt_max_tl) do
    object.custom_fields[DiscourseModCategories::CATEGORY_NEW_TOPIC_PROMPT_TL_FIELD]
  end
end
