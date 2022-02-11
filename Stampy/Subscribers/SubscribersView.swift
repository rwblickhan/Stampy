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

    private var spammySubscribers: [Subscriber] {
        subscribers.filter { $0.subscriberType == .spammy }
    }

    var body: some View {
        NavigationView {
            List {
                switch (subscribers.isEmpty, hasSubscriberFetchError, persistedAPIKey == nil) {
                case (_, _, true):
                    Text("Add your Buttondown API key in settings, then pull to refresh here!")
                case (true, true, false):
                    Text("Failed to retrieve subscribers; try pulling to refresh!")
                case (true, false, false):
                    ProgressView()
                case (false, _, false):
                    regularSubscribersSection
                    spammySubscribersSection
                }
            }
            .refreshable {
                await fetchAll()
            }
            .onAppear {
                Task { await fetchAll() }
            }
            .listStyle(GroupedListStyle())
            .navigationTitle("Subscribers")
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

    private var regularSubscribersSection: some View {
        Section(header: Label("Regular Subscribers (\(regularSubscribers.count))", systemImage: "person.crop.circle")) {
            ForEach(regularSubscribers) { subscriber in
                LazyVStack(alignment: .leading) {
                    Text(subscriber.email)
                        .font(.headline)
                    Text("Subscribed since \(subscriber.creationDate.formatted())")
                        .font(.subheadline)
                }
            }
        }
    }

    private var spammySubscribersSection: some View {
        Section(header: Label(
            "Spammy Subscribers (\(spammySubscribers.count))",
            systemImage: "person.crop.circle.badge.exclamationmark")) {
                ForEach(spammySubscribers) { subscriber in
                    LazyVStack(alignment: .leading) {
                        Text(subscriber.email)
                            .font(.headline)
                        Text("Subscribed since \(subscriber.creationDate.formatted())")
                            .font(.subheadline)
                    }
                }
            }
    }
}
