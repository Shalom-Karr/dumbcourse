# frozen_string_literal: true

# Routes for the DiscourseModCategories engine.
#
# This file is wired in as the engine's `config/routes.rb` via
# `config.paths["config/routes.rb"]` on the engine class in the merged
# plugin.rb. Doing so gives our engine its OWN routes file so Rails does
# not load the plugin-root config/routes.rb (dumbcourse's) twice — once
# per engine.
DiscourseModCategories::Engine.routes.draw do
  put "/topic/:topic_id" => "messages#update_topic"
  put "/category/:category_id" => "messages#update_category"
  post "/topic/:topic_id/note-reply" => "messages#add_note_reply"
  put "/topic/:topic_id/note-reply" => "messages#update_note_reply"
  delete "/topic/:topic_id/note-reply" => "messages#delete_note_reply"
  delete "/topic/:topic_id/note" => "messages#delete_note"
  post "/topic/:topic_id/whisper-participant" =>
         "messages#add_whisper_participant"
  get "/notes-feed" => "messages#notes_feed"
  post "/notes-feed/seen" => "messages#notes_feed_seen"
  get "/checklist" => "checklist#show"
  get "/checklist/owed" => "checklist#owed"
  put "/checklist" => "checklist#update"
  post "/checklist/accept" => "checklist#accept"
  post "/checklist/require-reaccept" => "checklist#require_reaccept"
  post "/checklist/targeted" => "checklist#create_targeted"
  put "/checklist/targeted/:id" => "checklist#update_targeted"
  delete "/checklist/targeted/:id" => "checklist#delete_targeted"
  get "/topic/:topic_id/prompt-checklist" => "checklist#show_topic"
  put "/topic/:topic_id/prompt-checklist" => "checklist#update_topic"
  delete "/topic/:topic_id/prompt-checklist" => "checklist#delete_topic"
end

Discourse::Application.routes.draw do
  mount ::DiscourseModCategories::Engine, at: "discourse-mod-categories"
end
