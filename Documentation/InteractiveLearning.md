# Interactive learning guide

Use this guide when a component needs a learn-by-building companion in addition to its concise API reference. The goal is to explain how the component works, why its implementation choices exist, and how a reader can verify the result in the gallery.

## When to create one

Create an HTML learning guide when a study has one or more of these traits:

- Multiple rendering or implementation approaches worth comparing.
- Geometry, animation, resource loading, or state flow that benefits from diagrams.
- A reusable public API whose behavior is clearer when built in small steps.
- A gallery interaction readers should reproduce, inspect, or customize.

Keep `Documentation/Studies/<StudyName>.md` as the concise reference for setup, public API, limits, and credits. Use `Documentation/Studies/<StudyName>Tutorial.html` for the guided learning path. Link both documents from the README.

## Required learning path

Build the tutorial around the component’s actual source and gallery. Do not invent a parallel sample implementation.

1. **Outcome and prerequisites** — state the component, platform minimum, dependencies, and what the reader will learn.
2. **Shared state and native contract** — begin with the screen-owned binding or value, public API, and native control semantics.
3. **Build each implementation in order** — use one section per renderer or framework. Explain the smallest meaningful code excerpts, the data flow, and the visual result.
4. **Explain important internals** — include geometry, animation, asynchronous resource loading, pivot or hierarchy behavior, fallback behavior, or other decisions that change user-visible results.
5. **Compare options** — show the runtime cost, fidelity, customization, asset size, and appropriate use case for each implementation.
6. **Accessibility and verification** — finish with Dynamic Type, VoiceOver, enabled state, Reduce Motion, appearance, and interaction checks.

Each section must answer: what changes, why it works, and how the reader can observe it in ComponentGallery.

## File and asset convention

```text
Documentation/
├── InteractiveLearning.md
├── Images/
│   └── <study>-<variation>.png
└── Studies/
    ├── <StudyName>.md
    └── <StudyName>Tutorial.html
```

- Use lowercase, hyphenated screenshot names: `<study>-swiftui.png`, `<study>-uikit.png`, or `<study>-<renderer>.png`.
- Capture images from ComponentGallery on an iPhone simulator. Use iPad images only when layout behavior differs materially.
- Add a focused UI test that attaches screenshots when a study needs repeatable documentation captures. Give attachments the final documentation filename and keep them with `XCTAttachment.Lifetime.keepAlways`.
- Store only the exported PNGs in `Documentation/Images`; do not commit `.xcresult` bundles or DerivedData.

## HTML template

Start each tutorial as a self-contained document. It must have no external fonts, scripts, analytics, or runtime dependencies.

```html
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="description" content="A step-by-step SwiftUI and UIKit study of <Component>.">
  <title><Component>: implementation study</title>
  <style>
    /* Inline responsive CSS. Respect light/dark color schemes. */
  </style>
</head>
<body>
  <header>
    <p>Swift View Lab · Component study</p>
    <h1><Component></h1>
    <p>What the reader will build and compare.</p>
  </header>
  <main>
    <nav aria-label="Tutorial sections">
      <!-- Anchored table of contents. -->
    </nav>
    <article>
      <section id="state"><h2>Step 1: Share state</h2></section>
      <section id="implementation"><h2>Step 2: Build the implementation</h2></section>
      <section id="comparison"><h2>Step 3: Choose an approach</h2></section>
      <section id="accessibility"><h2>Step 4: Validate the native contract</h2></section>
    </article>
  </main>
</body>
</html>
```

Use semantic headings in order, a labelled navigation landmark, real `pre > code` blocks, and `figure`/`figcaption` for screenshots. Keep inline diagrams semantic: use visible text and do not rely on arrows or color alone. Add meaningful `alt` text that identifies the selected implementation and the user-visible state.

Use relative links to the public source and reference document. From `Documentation/Studies/<StudyName>Tutorial.html`, source files live at `../../Sources/...`, gallery files at `../../Examples/...`, and images at `../Images/...`.

## Content rules

- Copy focused excerpts from the current implementation. Link to the full source instead of duplicating whole files.
- Keep snippets compilable when read together, and escape Swift generics as `&lt;` and `&gt;` in HTML.
- Explain state ownership before visual details. The gallery, rather than an implementation, owns shared demo settings and counters.
- Describe fallbacks truthfully. If a model or image resource can fail to load, show the working fallback and name its limitation.
- Mention only public APIs as adoption points. Mark gallery-only controls, experimental settings, and implementation types clearly.
- Attribute external inspiration and assets in the Markdown reference. Do not reproduce third-party art or tutorial code without compatible permission.

## Review checklist

- [ ] Every table-of-contents link targets an existing heading.
- [ ] Every image path and source link resolves from the HTML file.
- [ ] The tutorial reads correctly at desktop and narrow mobile widths, in light and dark appearance.
- [ ] Keyboard focus is visible, headings are ordered, and screenshots have useful alt text.
- [ ] Screenshots match the current gallery and use the same renderer names as the UI.
- [ ] The focused capture test passes, along with the affected package and gallery builds.
- [ ] The Markdown reference and README link to the tutorial.

## Refreshing a tutorial

When the component changes, update the source excerpts first, run the screenshot capture test, export the new attachments to `Documentation/Images`, then review the HTML at desktop and narrow widths. Treat a renderer, resource-loading, accessibility, or public API change as a documentation refresh trigger.
