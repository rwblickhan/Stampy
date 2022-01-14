//
//  Email.swift
//  Buttonup
//
//  Created by Russell Blickhan on 1/12/22.
//

import Foundation
import RealmSwift

class Email: Object, Codable, Identifiable {
    @Persisted(primaryKey: true) var id: String
    @Persisted var body: String
    @Persisted var publishDate: Date
    @Persisted var subject: String
}
