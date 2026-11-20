import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { ajax } from "discourse/lib/ajax";
import TierKarma from "../../components/tier-karma";

// The current user's payload lacks the card fields, so the avatar menu reads
// its own card once per page load; a failure lets the next open retry.
let cardRequest;

function ownCard(username) {
  cardRequest ||= ajax(`/u/${username}/card.json`)
    .then((json) => json?.user ?? null)
    .catch(() => {
      cardRequest = null;
      return null;
    });
  return cardRequest;
}

export default class MenuTierKarma extends Component {
  @tracked user = null;

  constructor() {
    super(...arguments);
    ownCard(this.args.outletArgs.user.username).then((user) => {
      if (!this.isDestroying) {
        this.user = user;
      }
    });
  }

  <template><TierKarma @user={{this.user}} /></template>
}
