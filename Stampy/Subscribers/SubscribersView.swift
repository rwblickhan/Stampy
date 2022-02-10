//
//  SubscribersView.swift
//  Stampy
//
//  Created by Russell Blickhan on 1/19/22.
//

import RealmSwift
import SwiftUI

struct SubscribersView: View {
    private let subscriberRepo = SubscriberRepository()

    @ObservedResults(Subscriber.self) private var subscribers
    @State private var hasSubscriberFetchError = false
    @AppStorage("api_key", store: UserDefaults.standard) private var persistedAPIKey: String?

    private var regularSubscribers: [Subscriber] {
        subscribers.filter { $0.subscriberType == .regular }
    }

    var body: some View {
        NavigationView {
            VStack {
                List {
                    regularSubscribersSection
                }.refreshable {
                    await fetchAll()
                }.onAppear {
                    Task { await fetchAll() }
                }.navigationTitle("Subscribers")
            }
        }
    }

    private func fetchAll() async {
        do {
            hasSubscriberFetchError = false
            try await subscriberRepo.fetchAll()
        } catch {
            print("\(error)")
            hasSubscriberFetchError = true
        }
    }

    private var regularSubscribersHeader: some View {
        HStack {
            Image(systemName: "person.2")
            Text("Regular Subscribers")
        }
    }

    private var regularSubscribersSection: some View {
        Section(header: regularSubscribersHeader) {
            switch (regularSubscribers.isEmpty, hasSubscriberFetchError, persistedAPIKey == nil) {
            case (_, _, true):
                Text("Add your Buttondown API key in settings, then pull to refresh here!")
            case (true, true, false):
                Text("Failed to retrieve subscribers; try pulling to refresh!")
            case (true, false, false):
                ProgressView()
            case (false, _, false):
                ForEach(regularSubscribers) { subscriber in
                    VStack(alignment: .leading) {
                        Text(subscriber.email)
                            .font(.headline)
                        Text("Subscribed since \(subscriber.creationDate.formatted())")
                            .font(.subheadline)
                    }
                }
            }
        }
    }
}
