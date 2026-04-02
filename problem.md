# Problems solved

Summary of issues that were identified and fixed in this project (aligned with `prompt.md` prompts).

---

### 1. Camera preview crash on mirroring

**Problem:** App crashed with  
`NSInvalidArgumentException` — `setVideoMirrored:` cannot be used when `automaticallyAdjustsVideoMirroring` is `YES`.

**Solution:** Before setting `isVideoMirrored` on `AVCaptureConnection` (preview layer and metadata output), set `automaticallyAdjustsVideoMirroring = false`, via a small helper used in both places.

**Area:** `CameraFaceView.swift`

---

### 2. Face-tracking gameplay vs desired design

**Problem:** Game relied on the camera and face rect; you wanted a bottom character, drag control, and exactly **five lanes** for dodging vertical emoji drops.

**Solution:** Removed camera from gameplay. `GameEngine` gained lane-based spawning and a lane index for the player; `GameView` uses drag + gradient background + lane dividers + player emoji at the bottom.

**Area:** `GameEngine.swift`, `GameView.swift`, `StartView.swift` (copy)

---

### 3. Menu music not playing

**Problem:** Only system sounds were implemented; the bundled MP3 was never played; no session setup for long-form audio.

**Solution:** `SoundManager` now uses `AVAudioSession` (`.playback`, `.mixWithOthers`) and `AVAudioPlayer` with looping for the theme file. `ContentView` calls `syncBackgroundMusic` on appear, when the sound toggle changes, and on foreground.

**Area:** `SoundManager.swift`, `ContentView.swift`

---

### 4. Wrong audio filename

**Problem:** Code referenced an old track name; the project actually uses `theme_song.mp3`.

**Solution:** Pointed the loader at resource name `theme_song`, extension `mp3`.

**Area:** `SoundManager.swift`

---

### 5. Home screen layout and polish

**Problem:** Start screen needed a clearer visual hierarchy and better composition.

**Solution:** Refined gradient, ambient glow, decor, typography, “How to play” card, primary Play CTA, press feedback, and header styling (later revised in item 7).

**Area:** `StartView.swift`

---

### 6. Score / emoji drop mismatch vs what players see

**Problem:** Player sprite size in the view didn’t match the engine hit size; culling used raw `size` while collision used a tightened `frame`; scoring moment could feel inconsistent with dodging.

**Solution:** Single `playerGlyphPointSize` shared by engine and view; `FallingEmoji.hitSizeFactor` for hit/score boxes; culling uses `emoji.frame.minY > bounds.height` so the same geometry drives collisions and points.

**Area:** `GameEngine.swift`, `GameView.swift`

---

### 7. Home “Menu” / volume control placement and look

**Problem:** Full-screen `ignoresSafeArea()` put the header under the notch/status area; material + opacity on the sound button looked weak or inconsistent.

**Solution:** Only backgrounds ignore safe area; main content respects safe area. Home row uses a “Home” capsule; sound control is a 48×48 circle with solid fill + stroke and full hit testing.

**Area:** `StartView.swift`

---

### 8. Lanes skipped when dragging

**Problem:** Finger X was mapped directly to lane index (`Int((x / width) * 5)`), so small moves could jump multiple lanes.

**Solution:** Stepped movement: after an anchor X is set, move **at most one lane** left or right when horizontal delta crosses a threshold (~32% of lane width, min 22pt); reset anchor after each step; clear anchor on drag end and on `reset()`.

**Area:** `GameEngine.swift` (`updatePlayerDragLocation`, `endPlayerDrag`), `GameView.swift` (`onEnded` on drag)

---

*Companion file to `prompt.md` — problems and resolutions only, not a full spec.*
