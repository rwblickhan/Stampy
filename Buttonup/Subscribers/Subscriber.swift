//
//  Subscriber.swift
//  Buttonup
//
//  Created by Russell Blickhan on 1/19/22.
//

import Foundation
import RealmSwift

class Subscriber: Object, Codable, Identifiable {
    @Persisted(primaryKey: true) var id: String
    @Persisted var email: String
    @Persisted var creationDate: Date
    @Persisted var notes: String
}
