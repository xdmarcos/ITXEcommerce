//
//  RootViewModel.swift
//  ITXEcommerce
//
//  Created by xdmGzDev on 30/3/26.
//

import Foundation

@Observable
final class RootViewModel {
    #if CONF_PROD
    var selection: AppTabConfig = .quickStart
    #else
    var selection: AppTabConfig = .catalog
    #endif
}
