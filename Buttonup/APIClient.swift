//
//  APIClient.swift
//  Buttonup
//
//  Created by Russell Blickhan on 1/12/22.
//

import Foundation
import Combine

enum HTTPMethod: String {
    case get
    case post
    case patch
    case put
    case delete
}

protocol APIRequest {
    associatedtype Response: Codable
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: [(String, String)]? { get }
    var body: Data? { get }
}

extension APIRequest {
    var parameters: [(String, String)]? { nil }
    var body: Data? { nil }
}

struct APIClient {
    private struct Constants {
        static let baseURL = URL(string: "https://api.buttondown.email")!
    }

    func send<T: APIRequest>(_ request: T) async throws -> T.Response {
        var urlComponents = URLComponents()
        urlComponents.path = request.path
        if let parameters = request.parameters {
            assert(request.method != .post, "POST requests should not have parameters")
            urlComponents.queryItems = parameters.map { parameter in
                let (name, value) = parameter
                return URLQueryItem(name: name, value: value)
            }
        }
        guard let url = urlComponents.url(relativeTo: Constants.baseURL) else {
            assert(false, "URL should always be able to be constructed")
            throw NSError()
        }

        guard let apiKey = UserDefaults.standard.string(forKey: "api_key") else { throw NSError() }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.httpBody = request.body
        // Be a very naughty boy and overwrite Authorization header
        urlRequest.setValue("Token \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        let fractionalSecondsDateFormatter = ISO8601DateFormatter()
        fractionalSecondsDateFormatter.formatOptions = [
            .withFullDate,
            .withFullTime,
            .withDashSeparatorInDate,
            .withColonSeparatorInTime,
            .withFractionalSeconds,
        ]

        let nonFractionalSecondsDateFormatter = ISO8601DateFormatter()
        nonFractionalSecondsDateFormatter.formatOptions = [
            .withFullDate,
            .withFullTime,
            .withDashSeparatorInDate,
            .withColonSeparatorInTime,
        ]

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            if let date = fractionalSecondsDateFormatter.date(from: dateString) {
                return date
            } else if let date = nonFractionalSecondsDateFormatter.date(from: dateString) {
                return date
            } else {
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Date string \(dateString) has unexpected format"
                )
            }
        }
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        
        do {
            let decodedData = try! decoder.decode(T.Response.self, from: data)
            return decodedData
        } catch {
            throw NSError()
        }
    }
}
