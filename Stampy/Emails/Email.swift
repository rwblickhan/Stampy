//
//  Email.swift
//  Stampy
//
//  Created by Russell Blickhan on 1/12/22.
//

import Foundation
import RealmSwift

enum EmailType: String, Codable, PersistableEnum {
    case `public`
    case `private`
    case premium
    case promoted
    case unknown

    init(from decoder: Decoder) throws {
        let rawString = try decoder.singleValueContainer().decode(String.self)
        if let emailType = EmailType(rawValue: rawString) {
            self = emailType
        } else {
            self = .unknown
        }
    }
}

class Email: Object, Codable, Identifiable {
    @Persisted(primaryKey: true) var id: String
    @Persisted var body: String
    @Persisted var publishDate: Date
    @Persisted var subject: String
    @Persisted var emailType: EmailType
}
