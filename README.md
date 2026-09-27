# ActionDesk AI

“Scan it. Understand it. Get it done.”

ActionDesk AI is an iOS/iPadOS SwiftUI application that turns paperwork into a calm, trackable action workflow. The repository contains a complete local-first product foundation: onboarding, Action Inbox, document intelligence presentation, capture and paste flows, contextual assistant, natural-language search, smart reminders, timelines, privacy controls, and a StoreKit 2 subscription surface.

## Run

1. Install [XcodeGen](https://github.com/yonaskolb/XcodeGen) on macOS.
2. Run `xcodegen generate` in this directory.
3. Open `ActionDeskAI.xcodeproj` in Xcode 16 or later.
4. Select an iOS 17+ simulator and run.

The app starts with realistic local sample data. No document content is transmitted. `DocumentIntelligenceService` is deliberately an interface backed by a local deterministic preview implementation; connect an approved provider only after adding explicit consent and a production privacy disclosure.

## Architecture

- `Domain`: stable models and local fixtures.
- `Services`: protected local persistence, reminders, biometrics, speech, and StoreKit 2.
- `Features`: small SwiftUI screens composed around the Capture → Understand → Act → Track → Resolve loop.
- `Resources/Localizable.xcstrings`: String Catalog source of truth.
- `Scripts/localization_qa.py`: validates locale coverage, placeholders, product-name integrity, and suspicious expansion.

## Privacy notes

Local records are written with iOS complete-until-first-authentication file protection. Biometric lock is optional. The preview analyzer is local and deterministic. A real AI provider must implement `DocumentIntelligenceService`, clearly identify transmission before upload, minimize payloads, and document retention/deletion behavior.

## Production checklist

- Replace preview intelligence with a reviewed OCR/AI pipeline and explicit data-processing consent.
- Configure StoreKit products and App Store Connect legal URLs.
- Add camera/document-scanner adapters and share extension targets.
- Add an encrypted-at-rest database if the threat model requires protection beyond iOS Data Protection.
- Complete native review of every machine-assisted translation.
- Run accessibility, localization, privacy-manifest, and device test matrices on macOS/Xcode.

