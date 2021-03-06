//
//  SettingsView.swift
//  Stampy
//
//  Created by Russell Blickhan on 1/13/22.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("api_key", store: UserDefaults.standard) private var persistedAPIKey: String?
    @State private var apiKey: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Label("Credentials", systemImage: "key")) {
                    if let persistedAPIKey = persistedAPIKey {
                        HStack {
                            Text("API Key: \(String(repeating: "*", count: persistedAPIKey.count))")
                                .lineLimit(1)
                            Spacer()
                            Button("Clear", action: {
                                apiKey = ""
                                self.persistedAPIKey = nil
                            })
                        }
                    } else {
                        HStack {
                            TextField("API Key", text: $apiKey)
                                .onSubmit { persistedAPIKey = apiKey }
                            Spacer()
                            Button("Save", action: {
                                persistedAPIKey = apiKey
                            })
                        }
                        Link(
                            "Open Buttondown API Key Settings",
                            destination: URL(string: "https://buttondown.email/settings/programming")!)
                    }
                }
            }.navigationTitle("Settings")
        }
    }
}
