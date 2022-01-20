//
//  EmailRepository.swift
//  Buttonup
//
//  Created by Russell Blickhan on 1/12/22.
//

import Combine
import Foundation
import RealmSwift

private struct EmailListResponse: Codable {
    let results: [Email]
    let next: String?
    let previous: String?
    let count: Int
}

/// See https://api.buttondown.email/v1/schema#operation/emails_list.
private struct EmailListRequest: APIRequest {
    typealias Response = EmailListResponse
    var path: String { "/v1/emails" }
    var method: HTTPMethod { .get }
}

class EmailRepository {
    private let realm: Realm
    private let apiClient: APIClient

    init() {
        realm = try! Realm()
        apiClient = APIClient()
    }

    func fetchAll() async throws {
        let response = try await apiClient.send(EmailListRequest())
        try await MainActor.run {
            try realm.write {
                realm.add(response.results, update: .all)
            }
        }
    }

    func fetch(_ id: String) -> Email? {
        realm.objects(Email.self).first(where: { $0.id == id })
    }
}
