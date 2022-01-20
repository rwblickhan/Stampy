//
//  EmailsView.swift
//  Buttonup
//
//  Created by Russell Blickhan on 1/12/22.
//

import RealmSwift
import SwiftUI

struct EmailsView: View {
    private let emailRepo = EmailRepository()

    @ObservedResults(Email.self) private var emails
    @State private var hasEmailFetchError = false

    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section(header: draftsHeader) {}
                    Section(header: scheduledHeader) {}
                    Section(header: archivesHeader) {
                        switch (emails.isEmpty, hasEmailFetchError) {
                        case (true, true):
                            Text("Failed to retrieve emails; try pulling to refresh!")
                        case (true, false):
                            ProgressView()
                        case (false, _):
                            ForEach(emails.reversed()) { email in
                                NavigationLink(destination: EmailView(email: email)) {
                                    VStack(alignment: .leading) {
                                        Text(email.subject)
                                            .font(.headline)
                                        Text(email.publishDate.formatted())
                                            .font(.subheadline)
                                    }
                                }
                            }
                        }
                    }
                }.refreshable {
                    await fetchAll()
                }.task {
                    await fetchAll()
                }.navigationTitle("Emails")
            }
        }
    }

    private func fetchAll() async {
        do {
            try await emailRepo.fetchAll()
            hasEmailFetchError = false
        } catch {
            print("\(error)")
            hasEmailFetchError = true
        }
    }

    private var draftsHeader: some View {
        HStack {
            Image(systemName: "envelope")
            Text("Drafts")
        }
    }
    
    private var scheduledHeader: some View {
        HStack {
            Image(systemName: "tray.and.arrow.up")
            Text("Scheduled Emails")
        }
    }

    private var archivesHeader: some View {
        HStack {
            Image(systemName: "tray.full")
            Text("Archives")
        }
    }
}
