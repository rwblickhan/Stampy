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
    @AppStorage("api_key", store: UserDefaults.standard) private var persistedAPIKey: String?
    @State private var loadingState: LoadingState = .none
    @State private var queryString: String = ""

    private var regularSubscribers: [Subscriber] {
        subscribers
            .filter { $0.subscriberType == .regular }
            .filter { queryString.isEmpty ? true : $0.email.lowercased().contains(queryString.lowercased()) }
    }

    private var spammySubscribers: [Subscriber] {
        subscribers
            .filter { $0.subscriberType == .spammy }
            .filter { queryString.isEmpty ? true : $0.email.lowercased().contains(queryString.lowercased()) }
    }

    var body: some View {
        NavigationView {
            List {
                if subscribers.isEmpty {
                    switch (loadingState, persistedAPIKey == nil) {
                    case (.loading, _):
                        ProgressView()
                    case (_, true):
                        Text("Add your Buttondown API key in settings, then come back here!")
                    case (.error, false):
                        Text("Failed to retrieve subscribers; try pulling to refresh!")
                    case (.none, false):
                        Text("Huh, looks like you don't have any subscribers yet. Sorry!")
                    }
                } else {
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
        .searchable(text: $queryString)
    }

    private func fetchAll() async {
        do {
            loadingState = .loading
            try await subscriberRepo.fetchAll()
            loadingState = .none
        } catch {
            print("\(error)")
            loadingState = .error
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
