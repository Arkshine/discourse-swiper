import Component from "@ember/component";
import loadScript, { loadCSS } from "discourse/lib/load-script";
import didInsert from "@ember/render-modifiers/modifiers/did-insert";
import { action } from "@ember/object";
import { htmlSafe } from "@ember/template";
import lightbox from "discourse/lib/lightbox";
import { service } from "@ember/service";
import { tagName } from "@ember-decorators/component";

@tagName("")
export default class SwiperInline extends Component {
  @service siteSettings;

  async loadSwiper() {
    await loadScript(settings.theme_uploads_local.swiper_js);
  }

  @action
  async initializeSwiper(element) {
    await this.loadSwiper();

    const thumb = new Swiper(element.querySelector(".slider-thumb"), {
      spaceBetween: 10,
      direction: "horizontal",
      enabled: true,
      slidesPerView: 5,
      freeMode: true,
      watchSlidesProgress: true,
    });

    const main = new Swiper(element.querySelector(".main-slider"), {
      spaceBetween: 10,
      direction: "horizontal",
      enabled: true,
      keyboard: {
        enabled: true,
      },
      mousewheel: {
        invert: false,
        enabled: false,
      },
      navigation: {
        nextEl: ".swiper-button-next",
        prevEl: ".swiper-button-prev",
      },
      thumbs: {
        swiper: thumb,
      },
    });

    if (!this.data.preview) {
      lightbox(element, this.siteSettings);
    }
  }

  get config() {
    return {
      ...this.data.config,
      height: this.data.config.height || "auto",
    };
  }

  <template>
    <div class="swiper-wrap" {{didInsert this.initializeSwiper}}>
      <div class="swiper main-slider" style="height: {{this.config.height}};">
        <div class="swiper-wrapper">
          {{#each @data.lightbox as |lightbox|}}
            <div class="swiper-slide">
              {{log lightbox}}
              {{lightbox}}
            </div>
          {{/each}}
        </div>
        <div class="swiper-button-next"></div>
        <div class="swiper-button-prev"></div>
      </div>
      <div thumbsSlider="" class="swiper slider-thumb">
        <div class="swiper-wrapper">
          {{#each @data.thumbnails as |thumbnail|}}
            <div class="swiper-slide">
              {{thumbnail}}
            </div>
          {{/each}}
        </div>
      </div>
    </div>
  </template>
}
