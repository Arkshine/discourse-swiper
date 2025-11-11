import { pointerPosition } from "./utils";

const DRAGGING_CLASS = "is-dragging";

export class DragPanel {
  constructor(element, panelElement) {
    this.element = element;
    this.panel = panelElement;
    this.animationFrameId = null;
    this.currentX = 0;
    this.currentY = 0;
  }

  start(event) {
    const { x, y } = pointerPosition(event);
    const panelRect = this.panel.getBoundingClientRect();

    this.currentX = panelRect.left;
    this.currentY = panelRect.top;

    this.offsetX = x - this.currentX;
    this.offsetY = y - this.currentY;

    this.targetX = this.currentX;
    this.targetY = this.currentY;

    this.updateCSS();

    this.panel.classList.add(DRAGGING_CLASS);
  }

  move(event) {
    const { x, y } = pointerPosition(event);

    if (this.animationFrameId) {
      this.lastX = x;
      this.lastY = y;
      return;
    }

    this.animationFrameId = requestAnimationFrame(() => {
      const pointerX = this.lastX ?? x;
      const pointerY = this.lastY ?? y;

      this.lastX = this.lastY = null;
      this.updatePosition(pointerX, pointerY);
      this.animationFrameId = null;
    });
  }

  updatePosition(pointerX, pointerY) {
    const maxX = window.innerWidth - this.element.offsetWidth;
    const maxY = window.innerHeight - this.element.offsetHeight;

    let targetX = pointerX - this.offsetX;
    let targetY = pointerY - this.offsetY;

    targetX = Math.max(0, Math.min(targetX, maxX));
    targetY = Math.max(0, Math.min(targetY, maxY));

    const lerp = 0.3;
    this.currentX += (targetX - this.currentX) * lerp;
    this.currentY += (targetY - this.currentY) * lerp;

    this.updateCSS();

    this.targetX = targetX;
    this.targetY = targetY;
  }

  updateCSS() {
    this.panel.style.left = "0px";
    this.panel.style.top = "0px";
    this.panel.style.setProperty(
      "transform",
      `translate3d(${Math.round(this.currentX)}px, ${Math.round(this.currentY)}px, 0)`,
      "important"
    );
  }

  end() {
    this.panel.classList.remove(DRAGGING_CLASS);
    this.animationFrameId && cancelAnimationFrame(this.animationFrameId);
    this.animationFrameId = null;
  }
}
