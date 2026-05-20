# frozen_string_literal: true

require "rails_helper"

# End-to-end coverage for the "pre-post confirmation prompt for new topics"
# feature. Proves the OFF state does nothing (a new topic posts straight
# through) and the ON state works (a confirmation dialog gates the submit,
# "Go back" keeps the composer, "Confirm" posts the topic).
#
# Screenshots are written to tmp/capybara/ for both states so the rendered
# UI can be reviewed from the CI artifact.
RSpec.describe "Pre-post confirmation prompt for new topics", type: :system do
  fab!(:admin)

  let(:title) { "A brand new topic from the system spec" }
  let(:body) { "This is the body of a brand new topic created by the system spec." }
  let(:custom_message) { "Are you absolutely sure you want to start this new topic?" }

  before do
    # The plugin's assets only load while the plugin is enabled; the feature
    # then has its own independent toggle (precheck_new_topic_enabled).
    SiteSetting.mod_categories_enabled = true
    SiteSetting.allow_uncategorized_topics = true
    SiteSetting.min_topic_title_length = 5
    SiteSetting.min_first_post_length = 5
    SiteSetting.min_post_length = 5
    SiteSetting.title_min_entropy = 1
    SiteSetting.body_min_entropy = 1
    sign_in(admin)
  end

  def start_new_topic
    visit("/")
    find("#create-topic").click
    find("#reply-title").fill_in(with: title)
    find(".d-editor-input").fill_in(with: body)
    find(".save-or-cancel .create").click
  end

  context "when precheck_new_topic_enabled is false (OFF)" do
    before { SiteSetting.precheck_new_topic_enabled = false }

    it "does nothing: the new topic is posted without any confirmation dialog" do
      start_new_topic

      # No confirmation dialog should ever appear.
      expect(page).to have_no_css(".dialog-body")
      # The topic is created and we land on it.
      expect(page).to have_css(".fancy-title", text: title, wait: 10)
      page.save_screenshot("precheck_off.png")
    end
  end

  context "when precheck_new_topic_enabled is true (ON)" do
    before do
      SiteSetting.precheck_new_topic_enabled = true
      SiteSetting.precheck_new_topic_message = custom_message
    end

    it "shows the confirmation dialog with the custom message before posting" do
      start_new_topic

      expect(page).to have_css(".dialog-body", text: custom_message, wait: 10)
      page.save_screenshot("precheck_on_dialog.png")
    end

    it "'Go back' cancels the post and keeps the composer open with content intact" do
      start_new_topic

      expect(page).to have_css(".dialog-body", text: custom_message, wait: 10)
      find(".dialog-footer button", text: "Go back").click

      # Composer is still open with the original content; nothing was posted.
      expect(page).to have_css(".d-editor-input")
      expect(find(".d-editor-input").value).to include(body)
      expect(page).to have_no_css(".fancy-title", text: title)
      page.save_screenshot("precheck_on_go_back.png")
    end

    it "'Post topic' confirms and the new topic is created" do
      start_new_topic

      expect(page).to have_css(".dialog-body", text: custom_message, wait: 10)
      find(".dialog-footer button", text: "Post topic").click

      expect(page).to have_css(".fancy-title", text: title, wait: 10)
      page.save_screenshot("precheck_on_confirmed.png")
    end

    it "uses the localized default message when the setting is blank" do
      SiteSetting.precheck_new_topic_message = ""
      start_new_topic

      expect(page).to have_css(
        ".dialog-body",
        text: "Are you sure you want to post this new topic?",
        wait: 10,
      )
      page.save_screenshot("precheck_on_default_message.png")
    end

    it "uses the localized default when the message is only whitespace" do
      SiteSetting.precheck_new_topic_message = "   \n\t  "
      start_new_topic

      expect(page).to have_css(
        ".dialog-body",
        text: "Are you sure you want to post this new topic?",
        wait: 10,
      )
    end

    it "trims surrounding whitespace from the configured message" do
      SiteSetting.precheck_new_topic_message = "   Please double-check first   "
      start_new_topic

      expect(page).to have_css(
        ".dialog-body",
        text: "Please double-check first",
        wait: 10,
      )
    end

    it "renders an HTML-looking message as literal text (no injection)" do
      SiteSetting.precheck_new_topic_message = "<b>bold?</b>"
      start_new_topic

      expect(page).to have_css(".dialog-body", text: "<b>bold?</b>", wait: 10)
      expect(page).to have_no_css(".dialog-body b")
    end

    it "prompts again on a second submit after going back" do
      start_new_topic
      expect(page).to have_css(".dialog-body", text: custom_message, wait: 10)
      find(".dialog-footer button", text: "Go back").click

      expect(page).to have_css(".d-editor-input")
      find(".save-or-cancel .create").click
      expect(page).to have_css(".dialog-body", text: custom_message, wait: 10)
    end
  end
end
