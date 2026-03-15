//
//  MetronomeApp.swift
//  Metronome
//
//  Created by Juri Gregg on 3/14/26.
//

import SwiftUI

@main
struct MetronomeApp: App {
    @State private var engine = MetronomeEngine()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(engine)
        }
    }
}
