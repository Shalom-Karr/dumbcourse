# frozen_string_literal: true

DiscourseDumbcourse::Engine.routes.draw do
  post "/hcaptcha" => "app#hcaptcha"

  # Push notification endpoints (must be before catch-all)
  scope "/push", defaults: { format: :json } do
    get "/info" => "push#server_info"
    post "/register" => "push#register"
    delete "/unregister" => "push#unregister"
    get "/status" => "push#status"
    get "/preferences" => "push#preferences"
    put "/preferences" => "push#update_preferences"
    post "/test" => "push#test_push"
  end

  # SSE / ntfy endpoints — permanently gone (see sse_controller.rb)
  # Must be before the catch-all so stale clients don't get redirected to /login.
  get "/push/sse/:topic" => "sse#stream"
  get "/ntfy/:topic/sse" => "sse#stream"
  get "/ntfy/*path" => "sse#stream"

  # LanguageTool proxy endpoint
  post "/languagetool/check" => "languagetool#check"

  # Main app routes (catch-all) - exclude push and ntfy paths
  get "/" => "app#show"
  get "/*path" => "app#show",
      :constraints => ->(req) do
        base = DiscourseDumbcourse.base_path_with_slash
        !req.path.start_with?("#{base}/push") && !req.path.start_with?("#{base}/ntfy")
      end
end

class DiscourseDumbcourseBasePathConstraint
  def matches?(req)
    req.params[:dumbcourse_base_path].to_s == DiscourseDumbcourse.base_path
  end
end

Discourse::Application.routes.draw do
  constraints DiscourseDumbcourseBasePathConstraint.new do
    scope "/:dumbcourse_base_path",
          defaults: { dumbcourse_base_path: DiscourseDumbcourse.base_path } do
      mount ::DiscourseDumbcourse::Engine, at: "/"
    end
  end
end

# --- discourse-mod ---
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
