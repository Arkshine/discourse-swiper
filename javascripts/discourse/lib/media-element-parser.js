// [
//   {
//     type: <type>,
//     node: <element>,
//     caption: <html>"
//   },
//   {
//     type: "nested-swiper",
//     items: [
//       {
//         type: <type>,
//         node: <element>,
//         caption: <html>
//       },
//       ...
//     ]
//   }
// ]
//

export default class MediaElementParser {
  /**
   * Parses a DOM root element and extract media elements with captions
   * Captions are any element following the media element until another media element or non-paragraph element
   *
   * TODO: Not complete. Experimenting with optional captions, nested swipers, and others elements such as videos.
   *
   * @param {HTMLElement} root
   * @returns {Array} items
   */
  static run(root) {
    const items = [];
    const nodes = Array.from(root.childNodes);

    for (let i = 0; i < nodes.length; i++) {
      const node = nodes[i];

      if (this.isWrap(node)) {
        items.push({ type: "nested", items: this.run(node) });
        continue;
      }

      if (this.isVideo(node) || this.isImage(node)) {
        const captionHtml = this.extractFollowingCaption(nodes, i + 1);

        this.pushMediaItem(
          items,
          this.isVideo(node) ? "video" : "image",
          node,
          captionHtml
        );
        continue;
      }

      if (this.isParagraph(node)) {
        const images = Array.from(node.querySelectorAll("span.image-wrapper"));
        if (images.length) {
          for (const img of images) {
            const inlineHtml = this.extractInlineCaptionAfterImage(node, img);
            const followingHtml = this.extractFollowingCaption(nodes, i + 1);
            const captionHtml = (inlineHtml + followingHtml).trim();
            this.pushMediaItem(items, "image", img, captionHtml);
          }
        }
        continue;
      }
    }

    return items;
  }

  static pushMediaItem(items, type, node, captionHtml) {
    items.push({
      type,
      node: node.cloneNode(true),
      thumbnailNode:
        type === "image"
          ? node.tagName === "IMG"
            ? node.cloneNode(true)
            : node.querySelector("img:not(.emoji)")?.cloneNode(true)
          : null,
      caption: this.wrapCaption(captionHtml),
    });
  }

  static isParagraph(node) {
    return node.nodeType === Node.ELEMENT_NODE && node.tagName === "P";
  }

  static isImage(node) {
    return (
      node.nodeType === Node.ELEMENT_NODE &&
      (node.matches?.(".image-wrapper") ||
        node.matches?.(".lightbox-wrapper") ||
        node.matches?.("img:not(.emoji)"))
    );
  }

  static isVideo(node) {
    return (
      node.nodeType === Node.ELEMENT_NODE &&
      node.matches?.("div.onebox-placeholder-container")
    );
  }

  static isWrap(node) {
    return node.nodeType === Node.ELEMENT_NODE && node.matches?.("div.d-wrap");
  }

  // Collect subsequent <p> elements (until a wrap/video/element that's not <p>)
  static extractFollowingCaption(nodes, startIndex) {
    let html = "";

    for (let i = startIndex; i < nodes.length; i++) {
      const n = nodes[i];

      if (this.isWrap(n) || this.isVideo(n)) {
        break;
      }

      if (this.isParagraph(n)) {
        if (n.querySelector("span.image-wrapper")) {
          break;
        }
        html += n.innerHTML + "<br>";
        continue;
      }

      // stop at other element nodes
      if (n.nodeType === Node.ELEMENT_NODE) {
        break;
      }
    }

    return this.trimBr(html);
  }

  // Extract html that appears after an image inside the same paragraph
  static extractInlineCaptionAfterImage(paragraph, imageNode) {
    let html = "";
    let seenImage = false;

    for (const child of paragraph.childNodes) {
      if (!seenImage) {
        if (child === imageNode) {
          seenImage = true;
        }
        continue;
      }
      // if another image element appears after, stop
      if (this.isImage(child)) {
        break;
      }
      html += child.outerHTML ?? child.textContent;
    }

    return this.trimBr(html);
  }

  static trimBr(html) {
    return html.replace(/^(<br\s*\/?>)+/i, "").replace(/(<br\s*\/?>)+$/i, "");
  }

  static wrapCaption(html) {
    if (!html || !html.trim()) {
      return null;
    }
    return `<div class="caption">${html.trim()}</div>`;
  }
}
