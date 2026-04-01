//
//  ServiceProvider.swift
//  ITXEcommerce
//
//  Created by xdmGzDev on 31/3/26.
//

import CoreNetwork
import Foundation

nonisolated
enum DummyJsonEndpointProvider: EndpointProvider {
    struct Pagination {
        let limit: Int
        let skip: Int?
    }

    case getProducts(pagination: Pagination?)
    case getProductById(productId: String)
    case getCategories
    case getCategoriesByName(name: String)

    var scheme: CoreNetwork.CoreHTTPScheme { .https }

    var baseURL: String { "dummyjson.com" }

    var path: String {
        switch self {
        case .getProducts:
            return "/products"
        case let .getProductById(productId):
            return "/products/\(productId)"
        case .getCategories:
            return "/products/category-list"
        case let .getCategoriesByName(category):
            return "/products/category/\(category)"
        }
    }

    var method: CoreNetwork.CoreHTTPMethod { .get }

    var queryItems: [URLQueryItem]? {
        switch self {
        case let .getProducts(pagination):
            guard let pagination else { return nil }
            var items = [
                URLQueryItem(name: "limit", value: "\(pagination.limit)")
            ]

            if let skip = pagination.skip {
                items.append(URLQueryItem(name: "skip", value: "\(skip)"))
            }

            return items

        case .getProductById:
            return nil

        case .getCategories:
            return nil

        case .getCategoriesByName:
            return nil
        }
    }

    var authorization: CoreNetwork.CoreHTTPAuthorizationMethod? { nil }
    var headers: [CoreNetwork.CoreHTTPHeaderKey: String]? { nil }
    var body: (any Encodable & Sendable)? { nil }
    var mockFile: String? { nil }
    var multipart: CoreNetwork.Multipart? { nil }
}
