//
//  SubscriberRepository.swift
//  Stampy
//
//  Created by Russell Blickhan on 1/19/22.
//

import Combine
import Foundation
import RealmSwift

private struct SubscriberListResponse: Codable {
    let results: [Subscriber]
    let next: String?
    let previous: String?
    let count: Int
}

/// See https://api.buttondown.email/v1/schema#operation/List%20all%20subscribers
private struct SubscriberListRequest: APIRequest {
    typealias Response = SubscriberListResponse
    var path: String { "/v1/subscribers" }
    var method: HTTPMethod { .get }
}

private struct UnsubscriberListResponse: Codable {
    let results: [Unsubscriber]
    let next: String?
    let previous: String?
    let count: Int
}

/// See https://api.buttondown.email/v1/schema#operation/List%20unsubscribers
private struct UnsubscriberListRequest: APIRequest {
    typealias Response = UnsubscriberListResponse
    var path: String { "/v1/unsubscribers" }
    var method: HTTPMethod { .get }
}

class SubscriberRepository: Repository {
    func fetchSubscribers() async throws {
        try await fetch(SubscriberListRequest(), onResponse: { realm, response in
            realm.add(response.results, update: .all)
        })
    }

    func fetchUnsubscribers() async throws {
        try await fetch(UnsubscriberListRequest(), onResponse: { realm, response in
            realm.add(response.results, update: .all)
        })
    }
}
