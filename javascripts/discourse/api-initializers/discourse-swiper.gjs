import { apiInitializer } from "discourse/lib/api";
import SwiperInline from "../components/swiper-inline";

export default apiInitializer((api) => {
  function applySwiper(element, helper) {
    const isPreview = !helper?.model;
    const container = document.createElement("div");
    container.classList.add("swiper-wrap-container");

    const thumbnailNodes = Array.from(element.querySelectorAll("img")).map(
      (img) => img.cloneNode(true)
    );

    const lightboxNodes = isPreview
      ? element.querySelectorAll("img")
      : Array.from(element.children)
          .filter(
            (child) =>
              child.classList?.contains("lightbox-wrapper") ||
              child.tagName === "IMG"
          )
          .map((child) => child.cloneNode(true));

    helper.renderGlimmer(container, SwiperInline, {
      lightbox: lightboxNodes,
      thumbnails: thumbnailNodes,
      preview: !helper.model,
      config: element.dataset,
    });

    element.replaceWith(container);
  }

  api.decorateCookedElement((element, helper) => {
    element
      .querySelectorAll("[data-wrap=swiper]")
      .forEach((element) => applySwiper(element, helper));
  });

  window.I18n.translations[window.I18n.locale].js.composer.swiper_sample = " ";

  api.addComposerToolbarPopupMenuOption({
    icon: "images",
    label: themePrefix("insert_swiper_sample"),
    action: (toolbarEvent) => {
      toolbarEvent.applySurround(
        "\n[wrap=swiper]\n",
        "\n[/wrap]\n",
        "swiper_sample",
        {
          multiline: false,
        }
      );
    },
  });
});
