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

class SubscriberRepository {
    private let realm: Realm
    private let apiClient: APIClient

    init() {
        realm = try! Realm()
        apiClient = APIClient()
    }

    func fetchAll() async throws {
        let response = try await apiClient.send(SubscriberListRequest())
        try await MainActor.run {
            try realm.write {
                realm.add(response.results, update: .all)
            }
        }
    }

    func fetch(_ id: String) -> Subscriber? {
        realm.objects(Subscriber.self).first(where: { $0.id == id })
    }
}
