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
            switch (emails.isEmpty, hasError) {
            case (true, true):
                List {
                    Text("Failed to retrieve emails; try pulling to refresh!")
                }.refreshable {
                    await fetchAll()
                }
            case (true, false):
                ProgressView()
                    .task {
                        await fetchAll()
                    }
            case (false, _):
                List {
                    ForEach(emails) { email in
                        Text(email.subject)
                    }
                }.refreshable {
                    await fetchAll()
                }
            }
        }
    }

    private func fetchAll() async {
        hasError = false
        do {
            try await emailRepo.fetchAll()
        } catch {
            hasError = true
        }
    }
}

struct EmailsView_Previews: PreviewProvider {
    static var previews: some View {
        EmailsView()
    }
}
