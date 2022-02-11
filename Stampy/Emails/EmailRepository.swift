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

private struct ScheduledEmailListResponse: Codable {
    let results: [Email]
    let next: String?
    let previous: String?
    let count: Int
}

/// See https://api.buttondown.email/v1/schema#operation/List%20all%20scheduled%20emails.
private struct ScheduledEmailListRequest: APIRequest {
    typealias Response = ScheduledEmailListResponse
    var path: String { "/v1/scheduled-emails" }
    var method: HTTPMethod { .get }
}

/// See https://api.buttondown.email/v1/schema#operation/Retrieve%20an%20existing%20email.
private struct EmailRequest: APIRequest {
    typealias Response = Email
    var path: String { "/v1/emails/\(emailID)" }
    var method: HTTPMethod { .get }

    let emailID: String
}

class EmailRepository: Repository {
    func fetchArchive() async throws {
        try await fetch(EmailListRequest(), onFetch: { realm, response in
            realm.delete(realm.objects(Email.self).filter { $0.publishDate <= Date() })
            realm.add(response.results, update: .all)
        })
    }

    func fetchScheduled() async throws {
        try await fetch(ScheduledEmailListRequest(), onFetch: { realm, response in
            realm.delete(realm.objects(Email.self).filter { $0.publishDate > Date() })
            realm.add(response.results, update: .all)
        })
    }

    func fetch(_ emailID: String) async throws {
        try await fetch(EmailRequest(emailID: emailID), onFetch: { realm, response in
            realm.add(response, update: .all)
        })
    }
}
