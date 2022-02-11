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
    @AppStorage("api_key", store: UserDefaults.standard) private var persistedAPIKey: String?
    @State private var loadingState: LoadingState = .none
    @State private var queryString: String = ""

    private var filteredEmails: [Email] {
        emails
            .filter { queryString.isEmpty ? true : $0.subject.lowercased().contains(queryString.lowercased()) }
            .reversed()
    }

    var body: some View {
        NavigationView {
            List {
                if emails.isEmpty {
                    switch (loadingState, persistedAPIKey == nil) {
                    case (.loading, _):
                        ProgressView()
                    case (_, true):
                        Text("Add your Buttondown API key in settings, then come back here!")
                    case (.error, false):
                        Text("Failed to retrieve emails; try pulling to refresh!")
                    case (.none, false):
                        Text("Huh, looks like you don't have any emails yet. Get writing!")
                    }
                } else {
                    //                draftsSection
                    //                scheduledSection
                    archivesSection
                }
            }.refreshable {
                await fetchAll()
            }.onAppear {
                Task { await fetchAll() }
            }
            .listStyle(GroupedListStyle())
            .navigationTitle("Emails")
        }
        .searchable(text: $queryString)
    }

    private func fetchAll() async {
        do {
            loadingState = .loading
            try await emailRepo.fetchAll()
            loadingState = .none
        } catch {
            print("\(error)")
            loadingState = .error
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
            ForEach(filteredEmails) { email in
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
