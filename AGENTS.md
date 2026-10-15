# Agent guidelines

This repository explores custom iOS components through paired SwiftUI and UIKit studies.

## Structure

- `Sources/StudySwiftUI/` and `Sources/StudyUIKit/`: independent reusable library modules
- `Examples/ComponentGallery/`: SwiftUI gallery, UIKit bridges, demo state, and experiments
- `Documentation/Studies/`: study notes and attribution
- `Documentation/AddingAStudy.md`: authoritative workflow for adding a study

## Implementation

- Use Swift 6 and maintain iOS 18, iPhone, and iPad support.
- Gate newer APIs with availability declarations and an explanatory gallery fallback.
- Keep the package modules independent of each other and the example app.
- Keep shared demo state above the SwiftUI/UIKit switcher.
- Register UIKit actions once and refresh coordinator callbacks during updates.
- Preserve native accessibility, enabled states, Dynamic Type, and Reduce Motion.
- Prefer small concrete views and minimal public APIs. Add documentation to public symbols.
- Keep third-party dependencies out unless explicitly authorized.
- Register each study in `Catalog/Study.swift` and document paired behavior.
- Credit inspiration and preserve required source licenses.

## Validation

Follow the README build commands. Run the shared UI test on an iPhone and iPad simulator when interaction changes. Check long labels, accessibility text, VoiceOver, Reduce Motion, and light/dark appearance for visual changes. Report unavailable checks honestly. Add tests for meaningful behavioral risks, not implementation duplication.

## Git

Use `feature/<study>`, `fix/<study>-<description>`, or `docs/<description>` branches. Use `feat(<study>): ...`, `fix(<study>): ...`, or `docs: ...` commits. Before committing, summarize staged changes and use that summary in the message. Keep personal Xcode settings, build output, credentials, and signing files out of Git.
