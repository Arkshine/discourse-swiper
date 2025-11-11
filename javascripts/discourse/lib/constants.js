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

  pagination: {
    enabled: true,
    clickabkle: true,
    type: "bullets", // 'progressbar' | 'bullets' | 'fraction'
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
    slideOnHover: true,
  },
};

export const DEFAULT_SETTINGS = deepFreeze(
  deepMerge(ORIGINAL_DEFAULT_SETTINGS, CUSTOM_DEFAULT_SETTINGS)
);

const DEFAULT_EFFECT_DEFINITIONS = {
  preset: {
    slidesPerView: 1,
    slidesPerGroup: 1,
    slidesRows: 1,
    centeredSlides: false,
  },
  presetNoValue: ["spaceBetween"],
};

const EFFECT_DEFINITIONS = {
  fade: DEFAULT_EFFECT_DEFINITIONS,
  cube: DEFAULT_EFFECT_DEFINITIONS,
  flip: DEFAULT_EFFECT_DEFINITIONS,
  shutters: DEFAULT_EFFECT_DEFINITIONS,
  slicers: DEFAULT_EFFECT_DEFINITIONS,
  tinder: DEFAULT_EFFECT_DEFINITIONS,
  "cards-stack": DEFAULT_EFFECT_DEFINITIONS,
  "super-flow": DEFAULT_EFFECT_DEFINITIONS,
  cards: {
    preset: {
      slidesPerView: 1,
      slidesPerGroup: 1,
      slidesRows: 1,
    },
    presetNoValue: ["spaceBetween"],
  },
  carousel: {
    preset: {
      direction: "horizontal",
      slidesPerGroup: 1,
      slidesRows: 1,
    },
    presetNoValue: ["spaceBetween"],
  },
  gl: {
    preset: {
      slidesPerView: 1,
      slidesPerGroup: 1,
      slidesRows: 1,
      centeredSlides: false,
    },
  },
  material: {
    preset: {
      slidesPerGroup: 1,
      slidesRows: 1,
    },
  },
  expo: {
    preset: {
      slidesPerView: 1.5,
      slidesPerGroup: 1,
      slidesRows: 1,
      centeredSlides: false,
    },
    noLocking: ["slidesPerView"],
  },
};

export const EFFECT_LOCKED_SETTINGS = Object.fromEntries(
  Object.entries(EFFECT_DEFINITIONS).map(([effect, def]) => [
    effect,
    Object.keys(def.preset)
      .filter(({ key }) => !def.noLocking?.includes(key))
      .concat(def.presetNoValue || []),
  ])
);

export const EFFECT_SETTING_PRESETS = Object.fromEntries(
  Object.entries(EFFECT_DEFINITIONS).map(([effect, def]) => [
    effect,
    def.preset,
  ])
);
