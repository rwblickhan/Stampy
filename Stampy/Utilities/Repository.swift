//
//  Repository.swift
//  Stampy
//
//  Created by Russell Blickhan on 2/11/22.
//

import Foundation
import RealmSwift

class Repository {
    private let realm: Realm
    private let apiClient: APIClient

    init() {
        let configuration = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
        realm = try! Realm(configuration: configuration)
        apiClient = APIClient()
    }

    func fetch<T: APIRequest>(_ request: T, onResponse: (Realm, T.Response) -> Void) async throws {
        assert(request.method == .get, "Use mutate() for mutating requests!")
        let response = try await apiClient.send(request)
        try await MainActor.run {
            try realm.write {
                onResponse(realm, response)
            }
        }
    }
    
    func mutate<T: APIRequest>(_ request: T, onOptimisticMutation: (Realm) -> Void, onResponse: (Realm, T.Response) -> Void) async throws {
        assert(request.method != .get, "Use fetch() for non-mutating requests!")
        try await MainActor.run {
            try realm.write {
                onOptimisticMutation(realm)
            }
        }
        let response = try await apiClient.send(request)
        try await MainActor.run {
            try realm.write {
                onResponse(realm, response)
            }
        }
    }
}
