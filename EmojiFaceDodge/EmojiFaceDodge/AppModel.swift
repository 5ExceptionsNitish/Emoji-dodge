//
//  AppModel.swift
//  EmojiFaceDodge
//
//  Created by Five Exceptions on 02/04/26.
//

import Foundation
import Combine

@MainActor
final class AppModel: ObservableObject {
    enum Screen: Equatable {
        case start
        case game
        case gameOver(score: Int)
    }

    @Published var screen: Screen = .start
    @Published var isSoundEnabled: Bool = true

    func startGame() {
        screen = .game
    }

    func endGame(score: Int) {
        screen = .gameOver(score: score)
    }

    func restartGame() {
        screen = .game
    }

    func goToStart() {
        screen = .start
    }
}
