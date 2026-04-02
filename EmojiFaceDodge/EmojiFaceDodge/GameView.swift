//
//  GameView.swift
//  EmojiFaceDodge
//
//  Created by Five Exceptions on 02/04/26.
//

import SwiftUI

struct GameView: View {
    @EnvironmentObject private var appModel: AppModel
    @StateObject private var engine = GameEngine()

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            ZStack {
                LinearGradient(
                    colors: [.indigo.opacity(0.95), .purple, .blue.opacity(0.9)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                laneDividers(width: size.width, height: size.height)

                ForEach(engine.emojis) { emoji in
                    Text(emoji.symbol)
                        .font(.system(size: emoji.size))
                        .position(emoji.position)
                        .shadow(radius: 2)
                }

                Text("🧍")
                    .font(.system(size: GameEngine.playerGlyphPointSize))
                    .position(engine.playerDrawPosition())
                    .shadow(color: .black.opacity(0.35), radius: 4, y: 2)
                    .allowsHitTesting(false)

                VStack {
                    HStack {
                        Text("Score: \(engine.score)")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(.black.opacity(0.4))
                            .clipShape(Capsule())

                        Spacer()
                    }
                    .padding(.horizontal, 14)
                    .padding(.top, 8)

                    Spacer()

                    Text("Drag sideways — move one lane at a time.")
                        .font(.subheadline.weight(.semibold))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white.opacity(0.95))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(.black.opacity(0.4))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .padding(.bottom, 22)
                        .allowsHitTesting(false)
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        engine.updatePlayerDragLocation(x: value.location.x, width: size.width)
                    }
                    .onEnded { _ in
                        engine.endPlayerDrag()
                    }
            )
            .onAppear {
                engine.onGameOver = { score in
                    appModel.endGame(score: score)
                }
                engine.start(bounds: size)
            }
            .onDisappear {
                engine.stop()
            }
            .onChange(of: proxy.size) { newSize in
                engine.updateBounds(newSize)
            }
        }
    }

    private func laneDividers(width: CGFloat, height: CGFloat) -> some View {
        Canvas { ctx, _ in
            let laneCount = GameEngine.laneCount
            guard laneCount > 1 else { return }
            for i in 1..<laneCount {
                let x = CGFloat(i) / CGFloat(laneCount) * width
                var line = Path()
                line.move(to: CGPoint(x: x, y: 0))
                line.addLine(to: CGPoint(x: x, y: height))
                ctx.stroke(line, with: .color(.white.opacity(0.14)), lineWidth: 1)
            }
        }
        .allowsHitTesting(false)
    }
}

#Preview {
    GameView()
        .environmentObject(AppModel())
}
