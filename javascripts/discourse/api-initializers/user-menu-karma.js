import { themePrefix } from "virtual:theme";
import { ajax } from "discourse/lib/ajax";
import { apiInitializer } from "discourse/lib/api";
import { i18n } from "discourse-i18n";

const CLASS = "fk-d-menu__monthly-karma";
const GROUP_CLASS = "fk-d-menu__primary-group";
const USER_INFO = ".custom-user-menu-content .fk-d-menu__user-info";

export default apiInitializer((api) => {
  const currentUser = api.getCurrentUser();
  if (!currentUser) {
    return;
  }

  // Monthly cheer points from the leaderboard. A valid response with an empty
  // `personal` means no points yet this month, so that reads as 0; anything else
  // that lacks `users` is not a leaderboard and the line is dropped.
  // One successful request per page load: the menu gets opened over and over.
  let scoreRequest;
  function monthlyScore() {
    scoreRequest ||= ajax("/leaderboard", { data: { period: "monthly" } })
      .then((json) =>
        json?.users ? (json.personal?.user?.total_score ?? 0) : null
      )
      .catch(() => {
        scoreRequest = null; // let the next open retry
        return null;
      });
    return scoreRequest;
  }

  // Primary group from the user card; null when the user has none.
  let groupRequest;
  function primaryGroup() {
    groupRequest ||= ajax(`/u/${currentUser.username}/card.json`)
      .then((json) => json?.user?.primary_group_name || null)
      .catch(() => {
        groupRequest = null; // let the next open retry
        return null;
      });
    return groupRequest;
  }

  async function addGroup(userInfo) {
    if (userInfo.querySelector(`.${GROUP_CLASS}`)) {
      return;
    }

    const line = document.createElement("span");
    line.className = GROUP_CLASS;
    userInfo.append(line);

    const name = await primaryGroup();

    if (!line.isConnected) {
      return;
    }

    if (!name) {
      line.remove();
      return;
    }

    line.textContent = name;
  }

  async function decorate(userInfo) {
    addGroup(userInfo);

    if (userInfo.querySelector(`.${CLASS}`)) {
      return;
    }

    const line = document.createElement("span");
    line.className = CLASS;
    userInfo.append(line);

    const score = await monthlyScore();

    if (!line.isConnected) {
      return; // menu was closed while the request was in flight
    }

    if (score === null) {
      line.remove();
      return;
    }

    const label = document.createElement("strong");
    label.textContent = i18n(themePrefix("monthly_karma"));
    const value = document.createElement("span");
    value.textContent = score.toLocaleString();
    line.replaceChildren(label, value);
  }

  // The custom-user-menu component exposes no plugin outlet and float-kit
  // teleports its content into a portal on open, so watch for it to appear
  // rather than hooking the trigger's click, which float-kit may swallow.
  new MutationObserver(() => {
    const userInfo = document.querySelector(USER_INFO);
    if (userInfo) {
      decorate(userInfo);
    }
  }).observe(document.body, { childList: true, subtree: true });
});
