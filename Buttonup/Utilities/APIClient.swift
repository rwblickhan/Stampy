//
//  APIClient.swift
//  Buttonup
//
//  Created by Russell Blickhan on 1/12/22.
//

import Combine
import Foundation

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
    private let urlSession = URLSession.shared
    private enum Constants {
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
            throw NSError(domain: "", code: 0, userInfo: nil)
        }

        guard let apiKey = UserDefaults.standard.string(forKey: "api_key")
        else { throw NSError(domain: "", code: 0, userInfo: nil) }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.httpBody = request.body
        // Be a very naughty boy and overwrite Authorization header
        urlRequest.setValue("Token \(apiKey)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await urlSession.data(for: urlRequest)

        guard
            let httpResponse = response as? HTTPURLResponse,
            httpResponse.statusCode == 200 else {
            throw NSError(
                domain: "Bad status code (\((response as? HTTPURLResponse)?.statusCode ?? 0)",
                code: 0,
                userInfo: nil)
        }

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
                    debugDescription: "Date string \(dateString) has unexpected format")
            }
        }
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        do {
            let decodedData = try decoder.decode(T.Response.self, from: data)
            return decodedData
        } catch {
            throw NSError(domain: "", code: 0, userInfo: nil)
        }
    }
}
