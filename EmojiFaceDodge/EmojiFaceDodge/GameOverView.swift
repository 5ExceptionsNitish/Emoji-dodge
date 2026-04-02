//
//  GameOverView.swift
//  EmojiFaceDodge
//
//  Created by Five Exceptions on 02/04/26.
//

import SwiftUI

struct GameOverView: View {
    @EnvironmentObject private var appModel: AppModel
    let score: Int

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.black, .red.opacity(0.9)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 16) {
                Text("Game Over")
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("Score: \(score)")
                    .font(.title.bold())
                    .foregroundStyle(.white.opacity(0.95))

                Button {
                    SoundManager.playButtonTap(isEnabled: appModel.isSoundEnabled)
                    appModel.restartGame()
                } label: {
                    Text("Restart")
                        .font(.title3.bold())
                        .frame(maxWidth: 260)
                        .padding(.vertical, 14)
                        .foregroundStyle(.white)
                        .background(.white.opacity(0.18))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .padding(.top, 8)

                Button {
                    appModel.goToStart()
                } label: {
                    Text("Back to Start")
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.9))
                        .padding(.top, 8)
                }
            }
            .padding(.horizontal, 24)
        }
        .onAppear {
            SoundManager.playGameOver(isEnabled: appModel.isSoundEnabled)
        }
    }
}

#Preview {
    GameOverView(score: 12)
        .environmentObject(AppModel())
}
