//
//  GameEngine.swift
//  EmojiFaceDodge
//
//  Created by Five Exceptions on 02/04/26.
//

import CoreGraphics
import Foundation
import Combine

struct FallingEmoji: Identifiable, Equatable {
    /// SwiftUI emoji glyphs draw a bit inside the point-size box; hit/score use this so dodge feels like what you see.
    static let hitSizeFactor: CGFloat = 0.88

    let id: UUID
    let symbol: String
    var position: CGPoint
    var size: CGFloat
    var speed: CGFloat

    init(symbol: String, position: CGPoint, size: CGFloat, speed: CGFloat) {
        self.id = UUID()
        self.symbol = symbol
        self.position = position
        self.size = size
        self.speed = speed
    }

    /// Hit box and scoring plane (aligned with gameplay, slightly tighter than `.size` font for fair dodging).
    private var hitExtent: CGFloat { size * Self.hitSizeFactor }

    var frame: CGRect {
        let h = hitExtent
        return CGRect(x: position.x - h / 2, y: position.y - h / 2, width: h, height: h)
    }
}

@MainActor
final class GameEngine: ObservableObject {
    static let laneCount = 5

    @Published private(set) var emojis: [FallingEmoji] = []
    @Published private(set) var score: Int = 0
    @Published private(set) var playerLane: Int = 0

    var onGameOver: ((Int) -> Void)?

    private var bounds: CGSize = .zero

    /// Must match `GameView` player `Text` font size so collisions match the sprite.
    static let playerGlyphPointSize: CGFloat = 56

    private let playerBottomInset: CGFloat = 76

    private var lastTick: Date?
    private var spawnCooldown: TimeInterval = 0
    private var timer: Timer?

    /// Finger X anchor for discrete ±1 lane steps (avoids skipping lanes when mapping position → index).
    private var dragStrideAnchorX: CGFloat?

    func start(bounds: CGSize) {
        self.bounds = bounds
        reset()
        startTimer()
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        lastTick = nil
    }

    func reset() {
        emojis = []
        score = 0
        playerLane = Self.laneCount / 2
        spawnCooldown = 0
        lastTick = nil
        dragStrideAnchorX = nil
    }

    func updateBounds(_ bounds: CGSize) {
        self.bounds = bounds
    }

    func laneCenterX(lane: Int) -> CGFloat {
        let w = bounds.width
        guard w > 0 else { return 0 }
        let clamped = min(Self.laneCount - 1, max(0, lane))
        let c = CGFloat(Self.laneCount)
        return (CGFloat(clamped) + 0.5) / c * w
    }

    func playerDrawPosition() -> CGPoint {
        CGPoint(x: laneCenterX(lane: playerLane), y: bounds.height - playerBottomInset)
    }

    func updatePlayerDragLocation(x: CGFloat, width: CGFloat) {
        guard width > 0 else { return }

        let laneWidth = width / CGFloat(Self.laneCount)
        let threshold = max(22, laneWidth * 0.32)

        if dragStrideAnchorX == nil {
            dragStrideAnchorX = x
            return
        }
        guard let anchor = dragStrideAnchorX else { return }
        let dx = x - anchor

        if dx >= threshold {
            if playerLane < Self.laneCount - 1 {
                playerLane += 1
            }
            dragStrideAnchorX = x
        } else if dx <= -threshold {
            if playerLane > 0 {
                playerLane -= 1
            }
            dragStrideAnchorX = x
        }
    }

    func endPlayerDrag() {
        dragStrideAnchorX = nil
    }

    private func playerCollisionRect() -> CGRect? {
        guard bounds.width > 0, bounds.height > 0 else { return nil }
        let p = playerDrawPosition()
        let extent = Self.playerGlyphPointSize * FallingEmoji.hitSizeFactor
        let half = extent / 2
        return CGRect(x: p.x - half, y: p.y - half, width: extent, height: extent)
            .insetBy(dx: 3, dy: 3)
    }

    private func startTimer() {
        stop()
        lastTick = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.tick()
        }
    }

    private func tick() {
        let now = Date()
        let dt: TimeInterval
        if let lastTick {
            dt = now.timeIntervalSince(lastTick)
        } else {
            dt = 0
        }
        lastTick = now

        guard bounds.width > 0, bounds.height > 0 else { return }

        spawnCooldown -= dt
        if spawnCooldown <= 0 {
            spawnEmoji()
            spawnCooldown = Double.random(in: 0.35...0.7)
        }

        let delta = CGFloat(dt)
        for index in emojis.indices {
            emojis[index].position.y += emojis[index].speed * delta
        }

        checkCollisions()
        cullAndScore()
    }

    private func spawnEmoji() {
        let emojiOptions = ["😀", "😅", "😂", "🥶", "😈", "👻", "🤖", "💣", "🔥", "⚡️", "🍕", "💩"]
        let symbol = emojiOptions.randomElement() ?? "😀"

        let baseSize = CGFloat.random(in: 36...56)
        let lane = Int.random(in: 0..<Self.laneCount)
        let x = laneCenterX(lane: lane)
        let y = -baseSize

        let difficultyBoost = min(CGFloat(score) * 3, 180)
        let speed = CGFloat.random(in: 170...240) + difficultyBoost

        emojis.append(
            FallingEmoji(
                symbol: symbol,
                position: CGPoint(x: x, y: y),
                size: baseSize,
                speed: speed
            )
        )
    }

    private func checkCollisions() {
        guard let playerRect = playerCollisionRect() else { return }

        for emoji in emojis {
            if emoji.frame.intersects(playerRect) {
                endGame()
                return
            }
        }
    }

    private func cullAndScore() {
        var survivors: [FallingEmoji] = []
        survivors.reserveCapacity(emojis.count)

        var scored = 0
        for emoji in emojis {
            if emoji.frame.minY > bounds.height {
                scored += 1
                continue
            }
            survivors.append(emoji)
        }

        emojis = survivors
        if scored > 0 {
            score += scored
        }
    }

    private func endGame() {
        stop()
        onGameOver?(score)
    }
}
