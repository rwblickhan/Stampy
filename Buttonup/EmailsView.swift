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
    @State private var hasError = false

    var body: some View {
        NavigationView {
            VStack {
            switch (emails.isEmpty, hasError) {
            case (true, true):
                List {
                    Text("Failed to retrieve emails; try pulling to refresh!")
                }.refreshable {
                    await fetchAll()
                }
            case (true, false):
                ProgressView()
                    .task { await fetchAll() }
            case (false, _):
                List(emails.reversed()) { email in
                    NavigationLink(destination: EmailView(email: email)) {
                        Text(email.subject)
                    }
                }.refreshable { await fetchAll() }
            }
            }.navigationTitle("Emails")
        }
    }

    private func fetchAll() async {
        do {
            try await emailRepo.fetchAll()
            hasError = false
        } catch {
            print("\(error)")
            hasError = true
        }
    }
}
