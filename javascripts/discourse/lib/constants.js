import { deepFreeze, deepMerge } from "discourse/lib/object";

export const SWIPER_CONTAINER_CLASS = "composer-swiper-node";
export const SWIPER_NODEVIEW_CLASS = "composer-swiper-nodeview";

const ORIGINAL_DEFAULT_SETTINGS = {
  enabled: true,
  direction: "horizontal",
  slidesPerView: 1,
  slidesPerGroup: 1,
  centeredSlides: false,
  spaceBetween: 10,
  grid: {
    rows: 1,
  },
  autoplay: {
    delay: 3000,
    pauseOnMouseEnter: true,
    disableOnInteraction: true,
    reverseDirection: false,
    stopOnLastSlide: false,
  },
  autoHeight: false,
  //grabCursor: false,

  loop: false,
  rewind: false,
  speed: 300,

  effect: "slide",

  navigation: {
    hideOnClick: false,
    nextEl: ".swiper-button-next",
    prevEl: ".swiper-button-prev",
  },
};

const CUSTOM_DEFAULT_SETTINGS = {
  width: "100%",
  height: "auto",

  autoplay: {
    enabled: false,
  },

  navigation: {
    enabled: true,
    color: "var(--primary)",
    position: "center",
    placement: "inside",
  },

  thumbs: {
    enabled: false,
    slidesPerView: 5,
    spaceBetween: 10,
    direction: "horizontal",
  },
};

export const DEFAULT_SETTINGS = deepFreeze(
  deepMerge(ORIGINAL_DEFAULT_SETTINGS, CUSTOM_DEFAULT_SETTINGS)
);

export const SETTINGS_EFFECT_DISABLES = deepFreeze({
  carousel: new Set([
    "direction",
    "slidesPerGroup",
    "slidesRows",
    "spaceBetween",
  ]),
  fade: new Set([
    "slidesPerView",
    "slidesPerGroup",
    "slidesRows",
    "centeredSlides",
    "spaceBetween",
  ]),
  cube: new Set([
    "slidesPerView",
    "slidesPerGroup",
    "slidesRows",
    "centeredSlides",
    "spaceBetween",
  ]),
  flip: new Set([
    "slidesPerView",
    "slidesPerGroup",
    "slidesRows",
    "centeredSlides",
    "spaceBetween",
  ]),
  cards: new Set([
    "slidesPerView",
    "slidesPerGroup",
    "slidesRows",
    "centeredSlides",
    "spaceBetween",
  ]),
  shutters: new Set([
    "slidesPerView",
    "slidesPerGroup",
    "slidesRows",
    "centeredSlides",
    "spaceBetween",
  ]),
  slicers: new Set([
    "slidesPerView",
    "slidesPerGroup",
    "slidesRows",
    "centeredSlides",
    "spaceBetween",
  ]),
  gl: new Set([
    "slidesPerView",
    "slidesPerGroup",
    "slidesRows",
    "centeredSlides",
  ]),
  tinder: new Set([
    "slidesPerView",
    "slidesPerGroup",
    "slidesRows",
    "centeredSlides",
    "spaceBetween",
  ]),
  material: new Set(["slidesPerGroup", "slidesRows"]),
  "cards-stack": new Set([
    "slidesPerView",
    "slidesPerGroup",
    "slidesRows",
    "centeredSlides",
    "spaceBetween",
  ]),
  expo: new Set(["slidesPerGroup", "slidesRows", "centeredSlides"]),
  "super-flow": new Set([
    "slidesPerView",
    "slidesPerGroup",
    "slidesRows",
    "centeredSlides",
    "spaceBetween",
  ]),
});
