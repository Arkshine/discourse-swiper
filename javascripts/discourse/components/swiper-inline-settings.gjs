import { tracked } from "@glimmer/tracking";
import Component, { Input } from "@ember/component";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { action, get } from "@ember/object";
import { service } from "@ember/service";
import { tagName } from "@ember-decorators/component";
import { eq, not } from "truth-helpers";
import DButton from "discourse/components/d-button";
import DSelect, { DSelectOption } from "discourse/components/d-select";
import DToggleSwitch from "discourse/components/d-toggle-switch";
import HorizontalOverflowNav from "discourse/components/horizontal-overflow-nav";
import concatClass from "discourse/helpers/concat-class";
import icon from "discourse/helpers/d-icon";
import withEventValue from "discourse/helpers/with-event-value";
import { i18n } from "discourse-i18n";
import {
  EFFECT_LOCKED_SETTINGS,
  EFFECT_SETTING_PRESETS,
} from "../lib/constants";
import { setNested } from "../lib/utils";

const i18nSetting = (key) =>
  i18n(themePrefix(`composer.swiper.settings.${key}`));

const generateValueOptions = (max) =>
  Array.from({ length: max }, (_, i) => ({
    value: String(i + 1),
  }));

@tagName("")
export default class SwiperInlineSettings extends Component {
  @service activeSwiperInEditor;

  @tracked activeCategory = "general";

  get config() {
    return this.getConfig();
  }

  get categories() {
    return [
      {
        name: "general",
        icon: "swiper-slides",
        label: i18nSetting("category.general"),
      },
      {
        name: "thumbnail",
        icon: "swiper-thumbnail",
        label: i18nSetting("category.thumbnail"),
      },
      {
        name: "effect",
        icon: "swiper-effects",
        label: i18nSetting("category.effect"),
      },
      {
        name: "autoplay",
        icon: "swiper-autoplay",
        label: i18nSetting("category.autoplay"),
      },
      {
        name: "navigation",
        icon: "swiper-navigation",
        label: i18nSetting("category.navigation"),
      },
      {
        name: "pagination",
        icon: "swiper-enable-pagination",
        label: i18nSetting("category.pagination"),
      },
    ];
  }

  get controlsData() {
    return {
      general: {
        direction: [
          {
            value: "horizontal",
            label: i18nSetting("general.direction_horizontal"),
          },
          {
            value: "vertical",
            label: i18nSetting("general.direction_vertical"),
          },
        ],
        slidesPerView: [
          ...generateValueOptions(10),
          { value: "auto", label: i18nSetting("general.slides_per_view_auto") },
        ],
        slidesPerGroup: [
          ...generateValueOptions(10),
          {
            value: "auto",
            label: i18nSetting("general.slides_per_group_auto"),
          },
        ],
        slidesRows: generateValueOptions(10),
        loopMode: [
          {
            value: "disabled",
            label: i18nSetting("general.loop_mode_disabled"),
          },
          {
            value: "loop",
            label: i18nSetting("general.loop_mode_loop"),
          },
          {
            value: "rewind",
            label: i18nSetting("general.loop_mode_rewind"),
          },
        ],
      },
      effect: {
        types: [
          { value: "slide", label: i18nSetting("effect.fx_slide") },
          { value: "fade", label: i18nSetting("effect.fx_fade") },
          { value: "cube", label: i18nSetting("effect.fx_cube") },
          { value: "coverflow", label: i18nSetting("effect.fx_coverflow") },
          { value: "flip", label: i18nSetting("effect.fx_flip") },
        ],
      },
      navigation: {
        placement: [
          {
            value: "inside",
            label: i18nSetting("navigation.placement_inside"),
          },
          {
            value: "outside",
            label: i18nSetting("navigation.placement_outside"),
          },
        ],
        position: [
          {
            value: "top",
            label: i18nSetting("navigation.position_top"),
          },
          {
            value: "center",
            label: i18nSetting("navigation.position_center"),
          },
          {
            value: "bottom",
            label: i18nSetting("navigation.position_bottom"),
          },
        ],
      },
      pagination: {
        placement: [
          {
            value: "inside",
            label: i18nSetting("navigation.placement_inside"),
          },
          {
            value: "outside",
            label: i18nSetting("navigation.placement_outside"),
          },
        ],
        position: [
          {
            value: "top",
            label: i18nSetting("navigation.position_top"),
          },
          {
            value: "bottom",
            label: i18nSetting("navigation.position_bottom"),
          },
        ],
      },
    };
  }

  get loopMode() {
    if (this.config.loop) {
      return "loop";
    } else if (this.config.rewind) {
      return "rewind";
    } else {
      return "disabled";
    }
  }

  get disableMap() {
    if (!Object.keys(EFFECT_LOCKED_SETTINGS).includes(this.config.effect)) {
      return {
        slidesPerGroup: parseInt(this.config.slidesPerView, 10) === 1,
        slidesRows: this.config.direction === "vertical",
        centeredSlides: this.config.direction === "vertical",
      };
    }

    return EFFECT_LOCKED_SETTINGS[this.config.effect]?.reduce((acc, name) => {
      acc[name] = true;
      return acc;
    }, {});
  }

  @action
  setActiveCategory(category) {
    this.activeCategory = category;
  }

  @action
  updateSettingFromEvent(key, event) {
    const value = parseInt(event.target.value, 10);
    this.updateSetting(key, value);
  }

  @action
  updateLoopMode(value) {
    this.updateSetting("loop", value === "loop");
    this.updateSetting("rewind", value === "rewind");
  }

  @action
  updateSetting(key, value) {
    this.applySetting(key, value);

    if (this.config.direction === "vertical") {
      this.applySetting("grid.rows", "1");
    }

    if (parseInt(this.config.slidesPerView, 10) === 1) {
      this.applySetting("slidesPerGroup", "1");
    }

    if (key === "effect") {
      const presetSettings = EFFECT_SETTING_PRESETS[value] || {};
      Object.entries(presetSettings).forEach(([presetKey, presetValue]) => {
        this.applySetting(presetKey, presetValue);
      });
    }
  }

  @action
  previewNavColor(value) {
    if (this.activeSwiperInEditor.instance.destroyed) {
      return;
    }

    this.activeSwiperInEditor.instance?.el?.parentElement.style.setProperty(
      "--swiper-navigation-color",
      value
    );
  }

  @action
  toggleSetting(key) {
    const newValue = !get(this.config, key);
    this.updateSetting(key, newValue);
  }

  @action
  applySetting(key, value) {
    const { view, getPos } = this;
    if (!view || !getPos) {
      return;
    }

    // fetch again to avoid stale data
    const currentNode = view.state.doc.nodeAt(getPos());
    if (!currentNode) {
      return;
    }

    const newAttrs = setNested({ ...currentNode.attrs }, key, value);
    const tr = view.state.tr.setNodeMarkup(getPos(), null, newAttrs);
    view.dispatch(tr);
  }

  <template>
    <div class="settings-categories-header">
      <HorizontalOverflowNav>
        {{#each this.categories as |category|}}
          <DButton
            class={{concatClass
              "category-button btn-flat btn-small"
              category.name
              (if (eq this.activeCategory category.name) "active")
            }}
            @action={{fn this.setActiveCategory category.name}}
            @icon={{category.icon}}
            @translatedLabel={{category.label}}
          />
        {{/each}}
      </HorizontalOverflowNav>
    </div>

    <div class="settings-section-content">
      {{#if (eq this.activeCategory "general")}}
        <div class="setting-row">
          <div class="setting-label">
            {{icon "swiper-slide-direction" class="setting-icon"}}
            <span>{{i18nSetting "general.direction"}}</span>
          </div>

          <div class="setting-control">
            <DSelect
              @value={{this.config.direction}}
              @includeNone={{false}}
              @onChange={{fn this.updateSetting "direction"}}
              name="direction"
            >
              {{#each this.controlsData.general.direction as |option|}}
                <DSelectOption
                  @value={{option.value}}
                  @selected={{this.config.direction}}
                >
                  {{option.label}}
                </DSelectOption>
              {{/each}}
            </DSelect>
          </div>
        </div>

        <div class="setting-row">
          <div class="setting-label">
            {{icon "swiper-slide-per-view" class="setting-icon"}}
            <span>{{i18nSetting "general.slides_per_view"}}</span>
          </div>
          <div class="setting-control">
            <DSelect
              @value={{this.config.slidesPerView}}
              @includeNone={{false}}
              @onChange={{fn this.updateSetting "slidesPerView"}}
              disabled={{get this.disableMap "slidesPerView"}}
              name="slidesPerView"
            >
              {{#each this.controlsData.general.slidesPerView as |option|}}
                <DSelectOption
                  @value={{option.value}}
                  @selected={{this.config.slidesPerView}}
                >
                  {{#if option.label}}
                    {{option.label}}
                  {{else}}
                    {{option.value}}
                  {{/if}}
                </DSelectOption>
              {{/each}}
            </DSelect>
          </div>
        </div>

        <div class="setting-row">
          <div class="setting-label">
            {{icon "swiper-slides-per-group" class="setting-icon"}}
            <span>{{i18nSetting "general.slides_per_group"}}</span>
          </div>

          <div class="setting-control">
            <DSelect
              @value={{this.config.slidesPerGroup}}
              @includeNone={{false}}
              @onChange={{fn this.updateSetting "slidesPerGroup"}}
              disabled={{get this.disableMap "slidesPerGroup"}}
              name="slidesPerGroup"
            >
              {{#each this.controlsData.general.slidesPerGroup as |option|}}
                <DSelectOption
                  @value={{option.value}}
                  @selected={{this.config.slidesPerGroup}}
                >
                  {{#if option.label}}
                    {{option.label}}
                  {{else}}
                    {{option.value}}
                  {{/if}}
                </DSelectOption>
              {{/each}}
            </DSelect>
          </div>
        </div>

        <div class="setting-row">
          <div class="setting-label">
            {{icon "swiper-slides-grid" class="setting-icon"}}
            <span>{{i18nSetting "general.slides_rows"}}</span>
          </div>

          <div class="setting-control">
            <DSelect
              @value={{this.config.grid.rows}}
              @includeNone={{false}}
              @onChange={{fn this.updateSetting "grid.rows"}}
              disabled={{get this.disableMap "slidesRows"}}
              name="slidesRows"
            >
              {{#each this.controlsData.general.slidesRows as |option|}}
                <DSelectOption
                  @value={{option.value}}
                  @selected={{this.config.grid.rows}}
                >
                  {{option.value}}
                </DSelectOption>
              {{/each}}
            </DSelect>
          </div>
        </div>

        <div class="setting-row">
          <div class="setting-label">
            {{icon "swiper-slides-centered" class="setting-icon"}}
            <span>{{i18nSetting "general.centered_slides"}}</span>
          </div>
          <div class="setting-control">
            <DToggleSwitch
              @state={{this.config.centeredSlides}}
              disabled={{get this.disableMap "centeredSlides"}}
              {{on "click" (fn this.toggleSetting "centeredSlides")}}
            />
          </div>
        </div>

        <div class="setting-row has-range-input">
          <div class="setting-label">
            {{icon "swiper-space-between-slides" class="setting-icon"}}
            <span>{{i18nSetting "general.space_between"}}s</span>
          </div>
          <div class="setting-control">
            <Input
              @type="range"
              @value={{this.config.spaceBetween}}
              disabled={{get this.disableMap "spaceBetween"}}
              class="setting-slider"
              min="0"
              max="100"
              step="1"
              {{on "input" (fn this.updateSettingFromEvent "spaceBetween")}}
            />
            <Input
              @type="number"
              @value={{this.config.spaceBetween}}
              disabled={{get this.disableMap "spaceBetween"}}
              class="setting-input"
              min="0"
              max="100"
              step="1"
              {{on "input" (fn this.updateSettingFromEvent "spaceBetween")}}
            />
          </div>
        </div>

        <div class="setting-row">
          <div class="setting-label">
            {{icon "swiper-auto-height" class="setting-icon"}}
            <span>{{i18nSetting "general.auto_height"}}</span>
          </div>
          <div class="setting-control">
            <DToggleSwitch
              @state={{this.config.autoHeight}}
              {{on "click" (fn this.toggleSetting "autoHeight")}}
            />
          </div>
        </div>

        {{!--
        <div class="setting-row">
          <div class="setting-label">
            {{icon "swiper-grab-cursor" class="setting-icon"}}
            <span>{{i18nSetting "general.grab_cursor"}}</span>
          </div>
          <div class="setting-control">
            <DToggleSwitch
              @state={{this.config.grabCursor}}
              {{on "click" (fn this.toggleSetting "grabCursor")}}
            />
          </div>
        </div>
        --}}

        <div class="setting-row">
          <div class="setting-label">
            {{icon "swiper-loop" class="setting-icon"}}
            <span>{{i18nSetting "general.loop_mode"}}</span>
          </div>
          <div class="setting-control">
            <DSelect
              @value={{this.loopMode}}
              @includeNone={{false}}
              @onChange={{this.updateLoopMode}}
              name="loopMode"
            >
              {{#each this.controlsData.general.loopMode as |option|}}
                <DSelectOption
                  @value={{option.value}}
                  @selected={{this.loopMode}}
                >
                  {{option.label}}
                </DSelectOption>
              {{/each}}
            </DSelect>
          </div>
        </div>
      {{/if}}

      {{#if (eq this.activeCategory "thumbnail")}}
        <div class="setting-row">
          <div class="setting-label">
            {{icon "swiper-thumbnail" class="setting-icon"}}
            <span>{{i18nSetting "thumbnail.enable"}}</span>
          </div>
          <div class="setting-control">
            <DToggleSwitch
              @state={{this.config.thumbs.enabled}}
              {{on "click" (fn this.toggleSetting "thumbs.enabled")}}
            />
          </div>
        </div>

        <div class="setting-row">
          <div class="setting-label">
            {{icon "swiper-slide-per-view" class="setting-icon"}}
            <span>{{i18nSetting "thumbnail.slides_per_view"}}</span>
          </div>
          <div class="setting-control">
            <DSelect
              @value={{this.config.thumbs.slidesPerView}}
              @includeNone={{false}}
              @onChange={{fn this.updateSetting "thumbs.slidesPerView"}}
              disabled={{not this.config.thumbs.enabled}}
              name="thumbs.slidesPerView"
            >
              {{#each this.controlsData.general.slidesPerView as |option|}}
                <DSelectOption
                  @value={{option.value}}
                  @selected={{this.config.thumbs.slidesPerView}}
                >
                  {{#if option.label}}
                    {{option.label}}
                  {{else}}
                    {{option.value}}
                  {{/if}}
                </DSelectOption>
              {{/each}}
            </DSelect>
          </div>
        </div>

        <div class="setting-row has-range-input">
          <div class="setting-label">
            {{icon "swiper-space-between-slides" class="setting-icon"}}
            <span>{{i18nSetting "thumbnail.space_between"}}</span>
          </div>
          <div class="setting-control">
            <Input
              @type="range"
              @value={{this.config.thumbs.spaceBetween}}
              disabled={{not this.config.thumbs.enabled}}
              class="setting-slider"
              min="0"
              max="50"
              step="1"
              {{on
                "input"
                (withEventValue (fn this.updateSetting "thumbs.spaceBetween"))
              }}
            />
            <Input
              @type="number"
              @value={{this.config.thumbs.spaceBetween}}
              disabled={{not this.config.thumbs.enabled}}
              class="setting-input"
              min="0"
              max="50"
              step="1"
              {{on
                "input"
                (withEventValue (fn this.updateSetting "thumbs.spaceBetween"))
              }}
            />
          </div>
        </div>

        <div class="setting-row">
          <div class="setting-label no-label-icon">
            {{icon "swiper-slide-direction" class="setting-icon"}}
            <span>{{i18nSetting "thumbnail.direction"}}</span>
          </div>

          <div class="setting-control">
            <DSelect
              @value={{this.config.thumbs.direction}}
              @includeNone={{false}}
              @onChange={{fn this.updateSetting "thumbs.direction"}}
              disabled={{not this.config.thumbs.enabled}}
              name="thumbs.direction"
            >
              {{#each this.controlsData.general.direction as |option|}}
                <DSelectOption
                  @value={{option.value}}
                  @selected={{this.config.thumbs.direction}}
                >
                  {{option.label}}
                </DSelectOption>
              {{/each}}
            </DSelect>
          </div>
        </div>
        <div class="setting-row">
          <div class="setting-label">
            {{icon "swiper-thumb-slide-on-hover" class="setting-icon"}}
            <span>{{i18nSetting "thumbnail.slide_on_hover"}}</span>
          </div>
          <div class="setting-control">
            <DToggleSwitch
              @state={{this.config.thumbs.slideOnHover}}
              {{on "click" (fn this.toggleSetting "thumbs.slideOnHover")}}
            />
          </div>
        </div>
      {{/if}}

      {{#if (eq this.activeCategory "effect")}}
        <div class="setting-row">
          <div class="setting-label">
            {{icon "swiper-effect-type" class="setting-icon"}}
            <span>{{i18nSetting "effect.type"}}</span>
          </div>
          <div class="setting-control">
            <DSelect
              @value={{this.config.effect}}
              @includeNone={{false}}
              @onChange={{fn this.updateSetting "effect"}}
              name="effect"
            >
              {{#each this.controlsData.effect.types as |option|}}
                <DSelectOption
                  @value={{option.value}}
                  @selected={{this.config.effect}}
                >
                  {{option.label}}
                </DSelectOption>
              {{/each}}
            </DSelect>
          </div>
        </div>

        {{#if (eq this.config.effect "fade")}}
          <div class="setting-row no-label-icon">
            <div class="setting-label">
              <span>{{i18nSetting "effect.crossfade"}}</span>
            </div>
            <div class="setting-control">
              <DToggleSwitch
                @state={{this.config.crossfade}}
                {{on "click" (fn this.toggleSetting "crossfade")}}
              />
            </div>
          </div>
        {{/if}}

        <div class="setting-row has-range-input">
          <div class="setting-label">
            {{icon "swiper-transition-duration" class="setting-icon"}}
            <span>{{i18nSetting "effect.duration"}}</span>
          </div>
          <div class="setting-control">
            <Input
              @type="range"
              @value={{this.config.speed}}
              class="setting-slider"
              min="100"
              max="2000"
              step="50"
              {{on "input" (withEventValue (fn this.updateSetting "speed"))}}
            />
            <Input
              @type="number"
              @value={{this.config.speed}}
              class="setting-input"
              min="100"
              max="2000"
              step="50"
              {{on "input" (withEventValue (fn this.updateSetting "speed"))}}
            />
          </div>
        </div>
      {{/if}}

      {{#if (eq this.activeCategory "autoplay")}}
        <div class="setting-row">
          <div class="setting-label">
            {{icon "swiper-enable-autoplay" class="setting-icon"}}
            <span>{{i18nSetting "autoplay.enable"}}</span>
          </div>
          <div class="setting-control">
            <DToggleSwitch
              @state={{this.config.autoplay.enabled}}
              {{on "click" (fn this.toggleSetting "autoplay.enabled")}}
            />
          </div>
        </div>

        <div class="setting-row no-label-icon has-range-input">
          <div class="setting-label">
            <span>{{i18nSetting "autoplay.delay"}}</span>
          </div>
          <div class="setting-control">
            <Input
              @type="range"
              @value={{this.config.autoplay.delay}}
              disabled={{not this.config.autoplay.enabled}}
              class="setting-slider"
              min="500"
              max="10000"
              step="100"
              {{on
                "input"
                (withEventValue (fn this.updateSetting "autoplay.delay"))
              }}
            />
            <Input
              @type="number"
              @value={{this.config.autoplay.delay}}
              disabled={{not this.config.autoplay.enabled}}
              class="setting-input"
              min="500"
              max="10000"
              step="100"
              {{on
                "input"
                (withEventValue (fn this.updateSetting "autoplay.delay"))
              }}
            />
          </div>
        </div>

        <div class="setting-row no-label-icon">
          <div class="setting-label">
            <span>{{i18nSetting "autoplay.pause_on_pointer"}}</span>
          </div>
          <div class="setting-control">
            <label class="toggle-switch">
              <DToggleSwitch
                @state={{this.config.autoplay.pauseOnMouseEnter}}
                disabled={{not this.config.autoplay.enabled}}
                {{on
                  "click"
                  (fn this.toggleSetting "autoplay.pauseOnMouseEnter")
                }}
              />
            </label>
          </div>
        </div>

        <div class="setting-row no-label-icon">
          <div class="setting-label">
            <span>{{i18nSetting "autoplay.disable_on_interaction"}}</span>
          </div>
          <div class="setting-control">
            <label class="toggle-switch">
              <DToggleSwitch
                @state={{this.config.autoplay.disableOnInteraction}}
                disabled={{not this.config.autoplay.enabled}}
                {{on
                  "click"
                  (fn this.toggleSetting "autoplay.disableOnInteraction")
                }}
              />
            </label>
          </div>
        </div>

        <div class="setting-row no-label-icon">
          <div class="setting-label">
            <span>{{i18nSetting "autoplay.reverse_direction"}}</span>
          </div>
          <div class="setting-control">
            <label class="toggle-switch">
              <DToggleSwitch
                @state={{this.config.autoplay.reverseDirection}}
                disabled={{not this.config.autoplay.enabled}}
                {{on
                  "click"
                  (fn this.toggleSetting "autoplay.reverseDirection")
                }}
              />
            </label>
          </div>
        </div>

        <div class="setting-row no-label-icon">
          <div class="setting-label">
            <span>{{i18nSetting "autoplay.stop_on_last"}}</span>
          </div>
          <div class="setting-control">
            <label class="toggle-switch">
              <DToggleSwitch
                @state={{this.config.autoplay.stopOnLast}}
                disabled={{not this.config.autoplay.enabled}}
                {{on "click" (fn this.toggleSetting "autoplay.stopOnLast")}}
              />
            </label>
          </div>
        </div>
      {{/if}}

      {{#if (eq this.activeCategory "navigation")}}
        <div class="setting-row">
          <div class="setting-label">
            {{icon "swiper-enable-navigation" class="setting-icon"}}
            <span>{{i18nSetting "navigation.enable"}}</span>
          </div>
          <div class="setting-control">
            <label class="toggle-switch">
              <DToggleSwitch
                @state={{this.config.navigation.enabled}}
                {{on "click" (fn this.toggleSetting "navigation.enabled")}}
              />
            </label>
          </div>
        </div>

        <div class="setting-row no-label-icon">
          <div class="setting-label">
            <span>{{i18nSetting "navigation.color"}}</span>
          </div>
          <div class="setting-control">
            <label class="toggle-switch">
              <Input
                @type="color"
                @value={{this.config.navigation.color}}
                disabled={{not this.config.navigation.enabled}}
                {{on
                  "change"
                  (withEventValue (fn this.updateSetting "navigation.color"))
                }}
                {{on "input" (withEventValue this.previewNavColor)}}
              />
            </label>
          </div>
        </div>

        <div class="setting-row no-label-icon">
          <div class="setting-label">
            <span>{{i18nSetting "navigation.placement"}}</span>
          </div>
          <div class="setting-control">
            <label class="toggle-switch">
              <DSelect
                @value={{this.config.navigation.placement}}
                @includeNone={{false}}
                @onChange={{fn this.updateSetting "navigation.placement"}}
                disabled={{not this.config.navigation.enabled}}
                name="navigation.placement"
              >
                {{#each this.controlsData.navigation.placement as |option|}}
                  <DSelectOption
                    @value={{option.value}}
                    @selected={{this.config.navigation.placement}}
                  >
                    {{option.label}}
                  </DSelectOption>
                {{/each}}
              </DSelect>
            </label>
          </div>
        </div>

        <div class="setting-row no-label-icon">
          <div class="setting-label">
            <span>{{i18nSetting "navigation.position"}}</span>
          </div>
          <div class="setting-control">
            <label class="toggle-switch">
              <DSelect
                @value={{this.config.navigation.position}}
                @includeNone={{false}}
                @onChange={{fn this.updateSetting "navigation.position"}}
                disabled={{not this.config.navigation.enabled}}
                name="navigation.position"
              >
                {{#each this.controlsData.navigation.position as |option|}}
                  <DSelectOption
                    @value={{option.value}}
                    @selected={{this.config.navigation.position}}
                  >
                    {{option.label}}
                  </DSelectOption>
                {{/each}}
              </DSelect>
            </label>
          </div>
        </div>
      {{/if}}

      {{#if (eq this.activeCategory "pagination")}}
        <div class="setting-row">
          <div class="setting-label">
            {{icon "swiper-enable-pagination" class="setting-icon"}}
            <span>{{i18nSetting "pagination.enable"}}</span>
          </div>
          <div class="setting-control">
            <label class="toggle-switch">
              <DToggleSwitch
                @state={{this.config.pagination.enabled}}
                {{on "click" (fn this.toggleSetting "pagination.enabled")}}
              />
            </label>
          </div>
        </div>

        <div class="setting-row no-label-icon">
          <div class="setting-label">
            <span>{{i18nSetting "pagination.color"}}</span>
          </div>
          <div class="setting-control">
            <label class="toggle-switch">
              <Input
                @type="color"
                @value={{this.config.pagination.color}}
                disabled={{not this.config.pagination.enabled}}
                {{on
                  "change"
                  (withEventValue (fn this.updateSetting "pagination.color"))
                }}
                {{on "input" (withEventValue this.previewNavColor)}}
              />
            </label>
          </div>
        </div>

        <div class="setting-row no-label-icon">
          <div class="setting-label">
            <span>{{i18nSetting "pagination.placement"}}</span>
          </div>
          <div class="setting-control">
            <label class="toggle-switch">
              <DSelect
                @value={{this.config.pagination.placement}}
                @includeNone={{false}}
                @onChange={{fn this.updateSetting "pagination.placement"}}
                disabled={{not this.config.pagination.enabled}}
                name="pagination.placement"
              >
                {{#each this.controlsData.pagination.placement as |option|}}
                  <DSelectOption
                    @value={{option.value}}
                    @selected={{this.config.pagination.placement}}
                  >
                    {{option.label}}
                  </DSelectOption>
                {{/each}}
              </DSelect>
            </label>
          </div>
        </div>

        <div class="setting-row no-label-icon">
          <div class="setting-label">
            <span>{{i18nSetting "pagination.position"}}</span>
          </div>
          <div class="setting-control">
            <label class="toggle-switch">
              <DSelect
                @value={{this.config.pagination.position}}
                @includeNone={{false}}
                @onChange={{fn this.updateSetting "pagination.position"}}
                disabled={{not this.config.pagination.enabled}}
                name="pagination.position"
              >
                {{#each this.controlsData.pagination.position as |option|}}
                  <DSelectOption
                    @value={{option.value}}
                    @selected={{this.config.pagination.position}}
                  >
                    {{option.label}}
                  </DSelectOption>
                {{/each}}
              </DSelect>
            </label>
          </div>
        </div>
      {{/if}}
    </div>
  </template>
}
