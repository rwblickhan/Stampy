//
//  Subscriber.swift
//  Stampy
//
//  Created by Russell Blickhan on 1/19/22.
//

import Foundation
import RealmSwift

enum SubscriberType: String, Codable, PersistableEnum {
    case unactivated
    case unpaid
    case unknown
    case regular
    case removed
    case spammy

    init(from decoder: Decoder) throws {
        let rawString = try decoder.singleValueContainer().decode(String.self)
        if let subscriberType = SubscriberType(rawValue: rawString) {
            self = subscriberType
        } else {
            self = .unknown
        }
    }
}

class Subscriber: Object, Codable, Identifiable {
    @Persisted(primaryKey: true) var id: String
    @Persisted var email: String
    @Persisted var creationDate: Date
    @Persisted var notes: String
    @Persisted var subscriberType: SubscriberType
}

class Unsubscriber: Object, Codable, Identifiable {
    @Persisted(primaryKey: true) var id: String
    @Persisted var email: String
    @Persisted var creationDate: Date
    @Persisted var notes: String
}
