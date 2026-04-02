//
//  ContentView.swift
//  EmojiFaceDodge
//
//  Created by Five Exceptions on 02/04/26.
//

import SwiftUI
import UIKit

struct ContentView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        Group {
            switch appModel.screen {
            case .start:
                StartView()
            case .game:
                GameView()
            case .gameOver(let score):
                GameOverView(score: score)
            }
        }
        .onAppear {
            SoundManager.syncBackgroundMusic(isSoundEnabled: appModel.isSoundEnabled)
        }
        .onChange(of: appModel.isSoundEnabled) { _, enabled in
            SoundManager.syncBackgroundMusic(isSoundEnabled: enabled)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            SoundManager.syncBackgroundMusic(isSoundEnabled: appModel.isSoundEnabled)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppModel())
}
