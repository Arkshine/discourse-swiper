import { tracked } from "@glimmer/tracking";
import Service from "@ember/service";

export default class ActiveSwiperInEditor extends Service {
  @tracked instance = null;

  setTo(instance) {
    this.instance = instance;
  }
}
