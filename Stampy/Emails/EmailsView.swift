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
    @State private var archivesLoadingState: LoadingState = .none
    @State private var scheduledLoadingState: LoadingState = .none
    @State private var queryString: String = ""

    private var filteredArchives: [Email] {
        emails
            .filter { $0.publishDate <= Date() }
            .filter { queryString.isEmpty ? true : $0.subject.lowercased().contains(queryString.lowercased()) }
            .sorted(by: { e1, e2 in
                // Newest first
                e1.publishDate > e2.publishDate
            })
    }

    private var filteredScheduled: [Email] {
        emails
            .filter { $0.publishDate > Date() }
            .filter { queryString.isEmpty ? true : $0.subject.lowercased().contains(queryString.lowercased()) }
            .sorted(by: { e1, e2 in
                // Soonest first
                e1.publishDate < e2.publishDate
            })
    }

    var body: some View {
        NavigationView {
            List {
                if emails.isEmpty && (archivesLoadingState == .loading || scheduledLoadingState == .loading) {
                    ProgressView()
                } else if emails.isEmpty && persistedAPIKey == nil {
                    Text("Add your Buttondown API key in settings, then come back here!")
                } else {
                    //                draftsSection
                    scheduledSection
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
            archivesLoadingState = .loading
            try await emailRepo.fetchArchive()
            archivesLoadingState = .none
        } catch {
            print("\(error)")
            archivesLoadingState = .error
        }

        do {
            scheduledLoadingState = .loading
            try await emailRepo.fetchScheduled()
            scheduledLoadingState = .none
        } catch {
            print("\(error)")
            scheduledLoadingState = .error
        }
    }

    private var draftsSection: some View {
        Section(header: Label("Drafts", systemImage: "envelope")) {}
    }

    private var scheduledSection: some View {
        Section(header: Label("Scheduled Emails", systemImage: "tray.and.arrow.up")) {
            if scheduledLoadingState == .error {
                Text("Failed to retrieve scheduled emails; try pulling to refresh!")
            } else {
                ForEach(filteredScheduled) { email in
                    NavigationLink(destination: EmailView(email: email)) {
                        LazyVStack(alignment: .leading) {
                            Text(email.subject)
                                .font(.headline)
                            Text(email.publishDate.formatted())
                                .font(.subheadline)
                        }
                    }
                }
                .onDelete(perform: { indexSet in
                    print("\(indexSet)")
                })
            }
        }
    }

    private var archivesSection: some View {
        Section(header: Label("Archives", systemImage: "tray.full")) {
            if archivesLoadingState == .error {
                Text("Failed to retrieve emails; try pulling to refresh!")
            } else {
                ForEach(filteredArchives) { email in
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
