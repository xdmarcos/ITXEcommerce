//
//  QuickStartViewModel.swift
//  ITXEcommerce
//
//  Created by xdmGzDev on 30/3/26.
//

import Foundation

@Observable
class QuickStartViewModel {
    var readmeContent: String {
        guard
            let url = Bundle.main.url(forResource: "README", withExtension: "md"),
            let content = try? String(contentsOf: url, encoding: .utf8)
        else { return "_README.md not found in bundle._" }
        return content
    }
}
