# frozen_string_literal: true

require "rails_helper"

# Request-level coverage for Dumbcourse's push-notification endpoints under
# `/dumb/push/*`. The flow:
#   - GET /push/info       — anonymous OK, exposes server URL + enabled flag
#   - POST /push/register  — login-only, stores a device in PluginStore
#   - GET /push/status     — reports per-device registration state
#   - DELETE /push/unregister — removes a device
#   - GET/PUT /push/preferences — per-user notification toggles
#   - GET /push/sse/:topic — permanently 410 Gone (see sse_controller.rb)
RSpec.describe "Dumbcourse push endpoints" do
  fab!(:user)

  before { SiteSetting.dumbcourse_enabled = true }

  describe "GET /dumb/push/info" do
    it "exposes the push server URL and enabled flag (anonymous)" do
      SiteSetting.dumbcourse_push_enabled = true

      get "/dumb/push/info"

      expect(response.status).to eq(200)
      body = response.parsed_body
      expect(body["server"]).to end_with("/dumb/push/sse")
      expect(body["enabled"]).to eq(true)
    end
  end

  describe "POST /dumb/push/register" do
    it "requires login" do
      post "/dumb/push/register",
           params: { topic: "abc", device_id: "dev-1" }
      expect(response.status).to be_in([403, 302, 404])
    end

    it "stores the device under the user's PluginStore key" do
      sign_in(user)

      post "/dumb/push/register",
           params: { topic: "abc", device_id: "dev-1" }

      expect(response.status).to eq(200)
      expect(response.parsed_body["success"]).to eq(true)

      devices = PluginStore.get("dumbcourse", "push_devices_#{user.id}")
      expect(devices.keys).to include("dev-1")
      expect(devices["dev-1"]["topic"]).to eq("abc")
    end

    it "rejects a register call with a missing device_id" do
      sign_in(user)
      post "/dumb/push/register", params: { topic: "abc" }
      expect(response.status).to eq(400)
    end
  end

  describe "GET /dumb/push/status" do
    before do
      sign_in(user)
      PluginStore.set(
        "dumbcourse",
        "push_devices_#{user.id}",
        { "dev-1" => { "topic" => "abc", "registered_at" => "now" } },
      )
    end

    it "reports a registered device" do
      get "/dumb/push/status", params: { device_id: "dev-1" }
      expect(response.status).to eq(200)
      body = response.parsed_body
      expect(body["registered"]).to eq(true)
      expect(body["topic"]).to eq("abc")
    end

    it "reports the device count when no device_id is given" do
      get "/dumb/push/status"
      expect(response.parsed_body["device_count"]).to eq(1)
    end
  end

  describe "DELETE /dumb/push/unregister" do
    it "removes the device from the user's store" do
      sign_in(user)
      PluginStore.set(
        "dumbcourse",
        "push_devices_#{user.id}",
        { "dev-1" => { "topic" => "abc" } },
      )

      delete "/dumb/push/unregister", params: { device_id: "dev-1" }
      expect(response.status).to eq(200)

      devices = PluginStore.get("dumbcourse", "push_devices_#{user.id}")
      expect(devices).not_to have_key("dev-1")
    end
  end

  describe "GET/PUT /dumb/push/preferences" do
    before { sign_in(user) }

    it "returns the default preferences on a fresh user" do
      get "/dumb/push/preferences"
      expect(response.status).to eq(200)
      # The default_prefs hash includes one entry per notification type.
      expect(response.parsed_body).to be_a(Hash)
    end

    it "persists updated preferences" do
      put "/dumb/push/preferences",
          params: { mentions: false, likes: true }
      expect(response.status).to eq(200)

      saved = PluginStore.get("dumbcourse", "push_prefs_#{user.id}")
      expect(saved["mentions"]).to eq(false)
      expect(saved["likes"]).to eq(true)
    end
  end

  describe "GET /dumb/push/sse/:topic (permanently disabled)" do
    it "returns 410 Gone so EventSource stops retrying" do
      get "/dumb/push/sse/anything"

      expect(response.status).to eq(410)
      expect(response.body).to include("SSE permanently disabled")
    end
  end

  describe "GET /dumb/ntfy/* (permanently disabled)" do
    it "also returns 410 Gone" do
      get "/dumb/ntfy/some-topic/sse"
      expect(response.status).to eq(410)
    end
  end
end
