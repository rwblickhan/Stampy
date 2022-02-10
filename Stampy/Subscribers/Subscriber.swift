//
//  Subscriber.swift
//  Stampy
//
//  Created by Russell Blickhan on 1/19/22.
//

import Foundation
import RealmSwift

enum SubscriberType: String, Codable, PersistableEnum {
    case regular
    case unactivated
    case unpaid
    case removed
}

class Subscriber: Object, Codable, Identifiable {
    @Persisted(primaryKey: true) var id: String
    @Persisted var email: String
    @Persisted var creationDate: Date
    @Persisted var notes: String
    @Persisted var subscriberType: SubscriberType?
}
