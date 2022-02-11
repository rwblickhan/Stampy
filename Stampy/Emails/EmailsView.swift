//
//  EmailsView.swift
//  Stampy
//
//  Created by Russell Blickhan on 1/12/22.
//

import RealmSwift
import SwiftUI

struct EmailsView: View {
    private let emailRepo = EmailRepository()

    @ObservedResults(Email.self) private var emails
    @State private var hasEmailFetchError = false
    @AppStorage("api_key", store: UserDefaults.standard) private var persistedAPIKey: String?

    var body: some View {
        NavigationView {
            List {
                draftsSection
                scheduledSection
                archivesSection
            }.refreshable {
                await fetchAll()
            }.onAppear {
                Task { await fetchAll() }
            }
            .listStyle(GroupedListStyle())
            .navigationTitle("Emails")
        }
    }

    private func fetchAll() async {
        do {
            hasEmailFetchError = false
            try await emailRepo.fetchAll()
        } catch {
            print("\(error)")
            hasEmailFetchError = true
        }
    }

    private var draftsSection: some View {
        Section(header: Label("Drafts", systemImage: "envelope")) {}
    }

    private var scheduledSection: some View {
        Section(header: Label("Scheduled Emails", systemImage: "tray.and.arrow.up")) {}
    }

    private var archivesSection: some View {
        Section(header: Label("Archives", systemImage: "tray.full")) {
            switch (emails.isEmpty, hasEmailFetchError, persistedAPIKey == nil) {
            case (_, _, true):
                Text("Add your Buttondown API key in settings, then pull to refresh here!")
            case (true, true, false):
                Text("Failed to retrieve emails; try pulling to refresh!")
            case (true, false, false):
                ProgressView()
            case (false, _, false):
                ForEach(emails.reversed()) { email in
                    NavigationLink(destination: EmailView(email: email)) {
                        LazyVStack(alignment: .leading) {
                            Text(email.subject)
                                .font(.headline)
                            Text(email.publishDate.formatted())
                                .font(.subheadline)
                        }
                    }
                }
            }
        }
    }
}
