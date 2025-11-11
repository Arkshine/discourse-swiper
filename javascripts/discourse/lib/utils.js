import { next } from "@ember/runloop";
import { TrackedObject } from "@ember-compat/tracked-built-ins";

export function normalizeSettings(settings) {
  const normalized = { ...settings };

  for (const key in normalized) {
    if (normalized.hasOwnProperty(key)) {
      const value = normalized[key];

      if (typeof value === "string") {
        if (value.toLowerCase() === "true") {
          normalized[key] = true;
        } else if (value.toLowerCase() === "false") {
          normalized[key] = false;
        } else if (/^\d+$/.test(value)) {
          normalized[key] = Number(value);
        }
      } else if (typeof value === "object" && value !== null) {
        normalized[key] = normalizeSettings(value);
      }
    }
  }

  return normalized;
}

export function normalizeControlSettings(settings) {
  const normalized = { ...settings };

  for (const key in normalized) {
    if (normalized.hasOwnProperty(key)) {
      const value = normalized[key];
      if (typeof value === "string") {
        if (value.toLowerCase() === "true") {
          normalized[key] = true;
        } else if (value.toLowerCase() === "false") {
          normalized[key] = false;
        }
      } else if (typeof value === "number") {
        normalized[key] = value.toString();
      } else if (typeof value === "object" && value !== null) {
        normalized[key] = normalizeControlSettings(value);
      }
    }
  }

  return normalized;
}

export function pointerPosition(event) {
  if (event.touches?.length) {
    return {
      x: event.touches[0].clientX,
      y: event.touches[0].clientY,
    };
  }

  if (event.changedTouches?.length) {
    return {
      x: event.changedTouches[0].clientX,
      y: event.changedTouches[0].clientY,
    };
  }

  return {
    x: event.clientX,
    y: event.clientY,
  };
}

// is there a better way?
export function createDragImage(event, { width, height, scale }) {
  const clone = event.target.cloneNode(true);

  clone.style.width = `${width * scale}px`;
  clone.style.height = `${height * scale}px`;
  clone.style.position = "absolute";
  clone.style.top = "-9999px";

  document.body.appendChild(clone);
  next(() => clone.remove());

  event.dataTransfer.setDragImage(
    clone,
    clone.offsetWidth / 2,

    clone.offsetHeight / 2
  );
}

// param="key: value, key2: value2" => { key: value, key2: value2 }
export function parseWrapParam(param) {
  for (const key in param) {
    if (param.hasOwnProperty(key) && param[key].includes(":")) {
      const object = {};
      param[key].split(",").forEach((pair) => {
        const [k, v] = pair.split(":").map((s) => s.trim());
        object[k] = v;
      });
      param[key] = object;
    }
  }

  return param;
}

export function deepTrack(object) {
  if (object && typeof object === "object" && !Array.isArray(object)) {
    const tracked = {};
    for (const [key, value] of Object.entries(object)) {
      tracked[key] = deepTrack(value);
    }
    return new TrackedObject(tracked);
  }
  return object;
}

export function setNested(object, path, value) {
  const parts = path.split(".");
  const key = parts.shift();

  return {
    ...object,
    [key]: parts.length
      ? setNested(object[key] || {}, parts.join("."), value)
      : value,
  };
}

export function flattenObject(obj, { withDefault = false } = {}) {
  const result = {};

  for (const [key, value] of Object.entries(obj)) {
    const path = key;

    if (value && typeof value === "object" && !Array.isArray(value)) {
      Object.assign(
        result,
        withDefault
          ? { [path]: { default: value } }
          : flattenObject(value, { withDefault })
      );
    } else {
      result[path] = withDefault ? { default: value } : value;
    }
  }

  return result;
}
