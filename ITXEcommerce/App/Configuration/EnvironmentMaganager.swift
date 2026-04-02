//
//  EnvironmentMaganager.swift
//  ITXEcommerce
//
//  Created by xdmGzDev on 2/4/26.
//

import Foundation

public struct EnvironmentManager: Sendable {

    public enum Environment: String {
        case staging, production
    }

    public static let shared = EnvironmentManager()
    public var environment: Environment {
        #if Debug_STAGE || Release_STAGE
            return .staging
        #else
            return .production
        #endif
    }

    var isStaging: Bool {
        environment == .staging
    }
}
