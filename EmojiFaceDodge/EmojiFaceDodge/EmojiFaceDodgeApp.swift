//
//  EmojiFaceDodgeApp.swift
//  EmojiFaceDodge
//
//  Created by Five Exceptions on 02/04/26.
//

import SwiftUI

@main
struct EmojiFaceDodgeApp: App {
    @StateObject private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appModel)
        }
    }
}
