import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import DButton from "discourse/components/d-button";
import { i18n } from "discourse-i18n";
import draggablePanel from "../modifiers/drag-panel";
import SwiperInlineSettings from "./swiper-inline-settings";

export default class SwiperSettingsPanel extends Component {
  @tracked isMinimized = false;

  panelElement = null;

  @action
  toggleMinimize() {
    this.isMinimized = !this.isMinimized;
  }

  @action
  closePanel() {
    this.args.data.closeSettingsMenu?.();
  }

  <template>
    <div class="swiper-settings-panel">
      <div
        class="swiper-settings-panel__actions"
        {{draggablePanel ".fk-d-menu"}}
      >
        <DButton
          class="drag-handle-grip btn-flat btn-transparent"
          @icon="grip-lines"
        />

        <span class="swiper-settings-panel__title">
          {{i18n (themePrefix "composer.swiper.settings.title")}}
        </span>

        <div class="drag-handle-actions">
          <DButton
            class="btn-flat btn-transparent handle-button"
            @action={{this.toggleMinimize}}
            @icon={{if this.isMinimized "window-maximize" "minus"}}
            @title={{if this.isMinimized "Expand" "Minimize"}}
          />
          <DButton
            class="btn-flat btn-transparent close-button"
            @action={{this.closePanel}}
            @icon="xmark"
            @title={{themePrefix "composer.swiper.settings.close"}}
          />
        </div>
      </div>
      {{#unless this.isMinimized}}
        <SwiperInlineSettings
          @view={{@data.view}}
          @getPos={{@data.getPos}}
          @getConfig={{@data.getConfig}}
          @closeMenu={{@data.closeSettingsMenu}}
        />
      {{/unless}}
    </div>

    {{!--MenuPanel class="swiper-settings-panel__menu-panel">
      <div class="swiper-settings-panel">
        <div class="swiper-settings-panel__header">
          <button
            type="button"
            class="swiper-settings-panel__toggle"
            {{on "click" this.toggleExpanded}}
          >
            <span class="swiper-settings-panel__icon">
              {{#if this.isExpanded}}▼{{else}}▶{{/if}}
            </span>
            <span class="swiper-settings-panel__title">
              {{i18n (themePrefix "composer.swiper.settings.title")}}
            </span>
          </button>
        </div>
      </div>
    </!--MenuPanel--}}
  </template>
}
