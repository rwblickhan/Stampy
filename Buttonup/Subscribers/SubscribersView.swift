//
//  SubscribersView.swift
//  Buttonup
//
//  Created by Russell Blickhan on 1/19/22.
//

import RealmSwift
import SwiftUI

struct SubscribersView: View {
    private let subscriberRepo = SubscriberRepository()

    @ObservedResults(Subscriber.self) private var subscribers
    @State private var hasSubscriberFetchError = false

    var body: some View {
        NavigationView {
            List {
                switch (subscribers.isEmpty, hasSubscriberFetchError) {
                case (true, true):
                    Text("Failed to retrieve emails; try pulling to refresh!")
                case (true, false):
                    ProgressView()
                case (false, _):
                    ForEach(subscribers) { subscriber in
                        VStack(alignment: .leading) {
                            Text(subscriber.email)
                                .font(.headline)
                            Text("Subscribed since \(subscriber.creationDate.formatted())")
                                .font(.subheadline)
                        }
                    }
                }
            }
            .refreshable {
                await fetchAll()
            }.task {
                await fetchAll()
            }.navigationTitle("Subscribers")
        }
    }

    private func fetchAll() async {
        do {
            try await subscriberRepo.fetchAll()
            hasSubscriberFetchError = false
        } catch {
            print("\(error)")
            hasSubscriberFetchError = true
        }
    }
}
