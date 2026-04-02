//
//  SoundManager.swift
//  EmojiFaceDodge
//
//  Created by Five Exceptions on 02/04/26.
//

import AudioToolbox
import AVFoundation

enum SoundManager {
    private static let musicFileName = "theme_song"
    private static let musicFileExtension = "mp3"

    nonisolated(unsafe) private static var musicPlayer: AVAudioPlayer?
    private static var audioSessionActivated = false

    /// Call whenever `isSoundEnabled` changes or when the app UI becomes active so menu music matches the toggle.
    static func syncBackgroundMusic(isSoundEnabled: Bool) {
        if isSoundEnabled {
            activateSessionIfNeeded()
            playLoopingMusic()
        } else {
            musicPlayer?.pause()
        }
    }

    private static func activateSessionIfNeeded() {
        guard !audioSessionActivated else { return }
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
            audioSessionActivated = true
        } catch {
            audioSessionActivated = false
        }
    }

    private static func playLoopingMusic() {
        if musicPlayer == nil {
            guard let url = Bundle.main.url(forResource: musicFileName, withExtension: musicFileExtension) else {
                return
            }
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.numberOfLoops = -1
                player.volume = 1
                player.prepareToPlay()
                musicPlayer = player
            } catch {
                musicPlayer = nil
                return
            }
        }
        musicPlayer?.volume = 1
        musicPlayer?.play()
    }

    static func playButtonTap(isEnabled: Bool) {
        guard isEnabled else { return }
        AudioServicesPlaySystemSound(1104)
    }

    static func playGameOver(isEnabled: Bool) {
        guard isEnabled else { return }
        AudioServicesPlaySystemSound(1053)
    }
}
