# Contributing

## Start here

1. Read the [README](README.md) and [study workflow](Documentation/AddingAStudy.md).
2. Create a focused branch such as `feature/progress-indicator` or `fix/button-layout`.
3. Keep each pull request centered on one study or behavior.

## Component expectations

- Provide paired SwiftUI and UIKit demonstrations with shared settings.
- Keep experiments in the gallery and reusable APIs in the package.
- Support iPhone, iPad, and iOS 18; gate newer APIs explicitly.
- Preserve native interaction and accessibility behavior wherever possible.
- Keep dependencies at zero unless a contribution explains a concrete need.
- Document behavior differences, API defaults, and limitations.

## Validate your change

Build the affected library products and the gallery using the README commands. Run the shared UI test on iPhone and iPad. For visual changes, include screenshots or a short recording in the pull request and check dark mode, Dynamic Type, VoiceOver, Reduce Motion, and long labels.

Add behavioral tests when they protect meaningful interaction or logic. Explain what you checked and any unavailable validation in your pull request.

## Attribution

Link the source of external inspiration in the study page. Only include code and assets you have permission to distribute under their applicable terms. Preserve required notices and source licenses. Do not copy tutorial assets or example projects into this repository without checking their licenses.

## Commits

Use concise messages such as `feat(animated-button): add paired press feedback`, `fix(animated-button): preserve disabled appearance`, or `docs: explain local package installation`.

## License

Contributions are provided under this repository's MIT license, with any third-party notices retained. Be respectful and constructive in issues and reviews.
