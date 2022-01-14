//
//  ButtonupApp.swift
//  Buttonup
//
//  Created by Russell Blickhan on 1/12/22.
//

import SwiftUI

@main
struct ButtonupApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                EmailsView()
                    .tabItem {
                        Image(systemName: "envelope")
                        Text("Emails")
                    }
                SettingsView()
                    .tabItem {
                        Image(systemName: "gear")
                        Text("Settings")
                    }
            }
        }
    }
}
