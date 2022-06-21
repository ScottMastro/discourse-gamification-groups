import Component from "@ember/component";
import discourseComputed from "discourse-common/utils/decorators";
import { action } from "@ember/object";
import showModal from "discourse/lib/show-modal";
import LoadMore from "discourse/mixins/load-more";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";

export default Component.extend(LoadMore, {
  tagName: "",
  eyelineSelector: ".user",
  page: 1,
  loading: false,
  canLoadMore: true,

  @discourseComputed("model.users")
  currentUserRanking() {
    const user = this.model.personal;
    return user || null;
  },

  @discourseComputed("model.users")
  winners(users) {
    return users.slice(0, 3);
  },

  @discourseComputed("model.groups")
  group_ranking(groups) {
    return groups.slice(3);
  },

  @discourseComputed("model.groups")
  group_winners(groups) {
    return groups.slice(0, 3);
  },

  @discourseComputed("model.users.[]")
  ranking(users) {

    var group_url = {}
    for (let i = 0; i < this.model.groups.length; i++){
      group_url[this.model.groups[i].id] = this.model.groups[i].flair_url
    }

    users.forEach((user) => {
      for (let i = user.groups.length-1; i >= 0; i--){
        if (!( user.groups[i].id in group_url)){
          user.groups.splice(i, 1);
        }
        else{
        user.groups[i].flair_url = group_url[user.groups[i].id];
        }
      }
      if (user.id === this.currentUser?.id) {
        user.isCurrentUser = "true";
      }
    });

    if (this.model.leaderboard.is_group_leaderboard){
      return users;
    }

    return users.slice(3);
  },

  @action
  showLeaderboardInfo() {
    showModal("leaderboard-info");
  },

  @action
  loadMore() {
    if (this.loading || !this.canLoadMore) {
      return;
    }

    this.set("loading", true);

    return ajax(`/leaderboard/${this.model.leaderboard.id}?page=${this.page}`)
      .then((result) => {
        if (result.users.length === 0) {
          this.set("canLoadMore", false);
        }
        this.set("page", (this.page += 1));
        this.set("model.users", this.model.users.concat(result.users));
      })
      .finally(() => this.set("loading", false))
      .catch(popupAjaxError);
  },
});
