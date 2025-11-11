# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Discourse theme component that integrates Swiper.js to create image gallery sliders in Discourse posts. It provides both a cooked view (for rendered posts) and an interactive rich text editor extension that allows users to create and edit image sliders directly in the composer.

## Development Commands

### Package Management
- **Install dependencies**: `pnpm install` (required - uses pnpm@9.x)
- Node.js version requirement: >= 22

### Linting & Formatting
- **ESLint**: `npx eslint javascripts/`
- **Stylelint**: `npx stylelint "**/*.scss"`
- **Template Lint**: `npx ember-template-lint javascripts/`
- **Prettier**: `npx prettier --check .` or `npx prettier --write .`

## Architecture

### Component Structure

This theme uses a dual-view architecture:

1. **Cooked View** (`SwiperInline`): Renders the swiper gallery in posts and previews
2. **Editor View** (`SwiperNodeView`): Interactive ProseMirror node view for the composer

### Key Files

- **`javascripts/discourse/api-initializers/discourse-swiper.gjs`**: Main entry point that registers the swiper extension with Discourse's API. Contains:
  - `registerSwiperExtension()`: Registers both the cooked decorator and the ProseMirror rich editor extension
  - `changedDescendants()`: Utility for detecting changed nodes in ProseMirror document
  - ProseMirror node specification for the `swiper` node type
  - Plugin for normalization (ensures all images are in a single paragraph, no consecutive images)
  - Markdown parsing/serialization for `[wrap=swiper]...[/wrap]` syntax
  - Toolbar integration for inserting swiper blocks

- **`javascripts/discourse/components/swiper-inline.gjs`**: Glimmer component that renders the actual Swiper.js sliders. Handles:
  - Loading Swiper.js library dynamically
  - Initializing main slider and thumbnail slider with thumbs synchronization
  - Applying custom config (height, width, slidesPerView)
  - Integrating with Discourse's lightbox functionality
  - Cleanup on destroy

- **`javascripts/discourse/components/swiper-node-view.gjs`**: Editor-specific component that provides:
  - Edit mode toggling (view mode shows slider, edit mode shows raw images)
  - Image reordering via drag-and-drop (desktop) or toolbar buttons (mobile)
  - Floating toolbar for edit controls
  - Mobile-specific reorder toolbar with left/right arrows
  - ProseMirror transaction handling for image manipulation

- **`javascripts/discourse/lib/glimmer-node-view.js`**: Base class that bridges ProseMirror's NodeView API with Glimmer components. Handles:
  - DOM structure creation for editor nodes
  - Lifecycle management (update, selectNode, deselectNode, destroy)
  - Event propagation (stopEvent, ignoreMutation)
  - Component instance registration

### ProseMirror Integration

The swiper node is defined with these characteristics:
- **Content**: `block*` (contains block nodes, specifically paragraphs with images)
- **Attributes**: `height`, `width`, `mode` (view/edit)
- **Behavior**: `selectable`, `draggable`, `isolating`, `atom` (acts as a single unit)
- **Normalization**: Plugin automatically flattens all images into a single paragraph to simplify structure

### Markdown Format

Users can manually write:
```markdown
[wrap=swiper height="500px" width="800px"]
![alt](upload://hash.jpg)
![alt2](upload://hash2.jpg)
[/wrap]
```

Attributes are optional and converted to camelCase in the DOM.

### Event Handling

The ProseMirror plugin handles several complex scenarios:
- **Click handling**: Selects the swiper node when clicking on slides
- **Drag-and-drop**: Distinguishes between reordering existing images vs. adding new images
- **Mobile touch**: Shows mobile toolbar when images are selected on touch devices
- **Normalization**: Automatically fixes structure when images are added/removed

### Asset Loading

The Swiper.js library is defined as a theme asset in `about.json`:
```json
"assets": {
  "swiper_js": "assets/swiper-bundle.min.js"
}
```

It's loaded dynamically via `loadScript(settings.theme_uploads_local.swiper_js)`.

## Discourse Theme Conventions

- This is a theme **component** (not a full theme), meant to be added to existing themes
- Uses `.gjs` files (Glimmer template + JavaScript in single file)
- Follows Discourse's API initializer pattern for extensions
- Integrates with Discourse's rich text editor extension system
- Uses `themePrefix()` for i18n keys (automatically prefixes with theme name)
- Toolbar buttons use `api.addComposerToolbarPopupMenuOption()`

## Key Development Patterns

### Adding New Swiper Configuration Options

1. Add the attribute to the `swiper` node spec in `discourse-swiper.gjs`:
   ```javascript
   attrs: {
     height: { default: null },
     width: { default: null },
     yourNewOption: { default: null }
   }
   ```

2. Handle it in markdown parsing (already dynamic via `Object.fromEntries`)

3. Apply it in `SwiperInline.initializeSwiper()` to pass to Swiper constructor

### Modifying Image Handling

Images are stored in a single paragraph inside the swiper node. The normalization plugin automatically flattens the structure. When working with images:
- Access via `swiperNode.firstChild.content` (the paragraph's content)
- Filter for `node.type.name === "image"`
- Position calculations: `swiperPos + 2 + offset` (2 = swiper open + paragraph open)

### Debugging Tips

The code contains several `console.log` statements that can be enabled for debugging:
- Normalization behavior
- Click handling
- Event propagation (stopEvent)
- Cursor positioning

## Testing

Testing structure is present in `spec/` and `test/` directories. The theme uses the standard Discourse theme testing workflow (via GitHub Actions).
