import Component from "@glimmer/component";
import { service } from "@ember/service";
import { trustHTML } from "@ember/template";
import { shouldRenderTopicFooterMessage } from "../../lib/topic-footer-message";

// Renders an admin-configured message at the bottom of regular topics
// (below the last post / footer buttons, above suggested topics). The
// content is admin-only trusted HTML, rendered with `trustHTML` exactly
// like core's `global_notice`; it is intentionally not sanitized. The
// visibility decision lives in ../../lib/topic-footer-message so it can be
// exhaustively unit-tested.
export default class TopicFooterMessage extends Component {
  static shouldRender(args, context, owner) {
    const siteSettings =
      owner?.lookup("service:site-settings") || context?.siteSettings;
    return shouldRenderTopicFooterMessage(siteSettings, args?.model);
  }

  @service siteSettings;

  get messageHtml() {
    return trustHTML(this.siteSettings.topic_footer_message);
  }

  <template>
    <div class="topic-footer-message">
      {{this.messageHtml}}
    </div>
  </template>
}
