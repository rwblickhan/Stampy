//
//  Repository.swift
//  Stampy
//
//  Created by Russell Blickhan on 2/11/22.
//

import Foundation
import RealmSwift

class Repository {
    let realm: Realm
    let apiClient: APIClient

    init() {
        let configuration = Realm.Configuration(deleteRealmIfMigrationNeeded: false)
        realm = try! Realm(configuration: configuration)
        apiClient = APIClient()
    }

    func makeRequest(_: APIRequest) {
        try await MainActor.run {
            try realm.write {
                realm.add(response.results, update: .all)
            }
        }
    }
}
