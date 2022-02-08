//
//  StampyApp.swift
//  Stampy
//
//  Created by Russell Blickhan on 1/12/22.
//

import SwiftUI

@main
struct StampyApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                EmailsView()
                    .tabItem {
                        Image(systemName: "envelope")
                        Text("Emails")
                    }
                SubscribersView()
                    .tabItem {
                        Image(systemName: "person.2")
                        Text("Subscribers")
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
