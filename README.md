# Emoji Face Dodge

A small iOS game built with SwiftUI. Emojis fall in five vertical lanes; you move a character along the bottom and dodge them. One hit ends the run; every emoji that clears the bottom of the screen adds to your score. Difficulty ramps slightly as your score grows.

## What you do

- **Play** from the home screen to start a run.
- **Drag sideways** on the playfield. Movement is **one lane at a time** (left or right), so you step between lanes instead of jumping across the screen.
- **Avoid** any falling emoji that shares your lane as it reaches you.
- **Score** increases each time a falling emoji leaves the screen below you without a collision.

## Screens

| Screen | Purpose |
|--------|---------|
| **Home** | How to play, theme music, sound on/off, **Play** |
| **Game** | Five lanes, falling emojis, score, drag to move |
| **Game over** | Final score, **Restart** or **Back to Start** |

## Audio

- **Theme loop:** `EmojiFaceDodge/theme_song.mp3` (must stay in the app target; referenced in code as `theme_song`).
- **Sound toggle** on the home screen controls background music and short UI/game-over sounds together.

## Tech stack

- SwiftUI, `ObservableObject` game loop (`Timer` at 60 Hz)
- AVFoundation for menu music; AudioToolbox for light system sounds
- Optional **camera / face** code remains in the project (`EmojiFaceDodge/CameraFaceView.swift`) but is **not** used in the current game flow.

## Requirements

- Xcode aligned with the project (see **iOS Deployment Target** in the Xcode project; this repo is set for a recent iOS SDK).
- A physical device or simulator capable of running that target.

## Build and run

1. Open `EmojiFaceDodge.xcodeproj` in Xcode.
2. Select the **EmojiFaceDodge** scheme and a simulator or device.
3. Run (**⌘R**).

Ensure `theme_song.mp3` is included in the **EmojiFaceDodge** synchronized folder so it is copied into the app bundle.

## Repository notes

- `prompt.md` — log of user prompts used during development.
- `problem.md` — corresponding problems and how they were addressed.

## License

All rights reserved unless the project owner adds an explicit license.
