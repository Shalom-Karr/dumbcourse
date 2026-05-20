# frozen_string_literal: true

require "rails_helper"

# Request-level coverage for the Dumbcourse SPA mount under `/<base_path>`
# (default `/dumb`). The controller serves a static `index.html` with
# settings injected into a `<script>` tag, redirects anonymous users to
# the in-SPA login, and returns 404 when the plugin is disabled.
RSpec.describe "Dumbcourse SPA" do
  fab!(:user)

  describe "GET /dumb (anonymous)" do
    it "redirects to the in-SPA login route" do
      SiteSetting.dumbcourse_enabled = true

      get "/dumb"

      expect(response.status).to eq(302)
      expect(response.location).to end_with("/dumb/login")
    end
  end

  describe "GET /dumb (authenticated)" do
    before do
      SiteSetting.dumbcourse_enabled = true
      sign_in(user)
    end

    it "serves the SPA index with the settings <script> injected" do
      get "/dumb"

      expect(response.status).to eq(200)
      expect(response.content_type).to start_with("text/html")
      # The controller injects `window.DUMBCOURSE_SETTINGS = {...}` into the
      # head; if the script is missing the in-browser SPA can't bootstrap.
      expect(response.body).to include("window.DUMBCOURSE_SETTINGS=")
      expect(response.body).to include('"basePath":"/dumb"')
    end
  end

  describe "GET /dumb when the plugin is disabled" do
    it "returns 404" do
      SiteSetting.dumbcourse_enabled = false
      sign_in(user)

      get "/dumb"

      expect(response.status).to eq(404)
    end
  end

  describe "base_path configurability" do
    it "honours a custom dumbcourse_base_path" do
      SiteSetting.dumbcourse_enabled = true
      SiteSetting.dumbcourse_base_path = "forum"
      sign_in(user)

      get "/forum"

      expect(response.status).to eq(200)
      expect(response.body).to include('"basePath":"/forum"')
    end
  end
end
