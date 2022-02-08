//
//  EmailRepository.swift
//  Stampy
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

/// See https://api.buttondown.email/v1/schema#operation/Retrieve%20an%20existing%20email.
private struct EmailRequest: APIRequest {
    typealias Response = Email
    var path: String { "/v1/emails/\(emailID)" }
    var method: HTTPMethod { .get }

    let emailID: String
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

    func fetch(_ emailID: String) async throws {
        let response = try await apiClient.send(EmailRequest(emailID: emailID))
        try await MainActor.run {
            try realm.write {
                realm.add(response, update: .all)
            }
        }
    }
}
