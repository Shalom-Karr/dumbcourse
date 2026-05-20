# frozen_string_literal: true

# Routes for the DiscourseDumbcourse engine.
#
# The DiscourseModCategories engine has its own routes file at
# discourse-mod/config/routes.rb (wired in via config.paths on its
# Engine class in plugin.rb). Keeping the two engines' routes in
# separate files prevents Rails' routes_reloader from loading the
# same file twice and re-mounting either engine.
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
