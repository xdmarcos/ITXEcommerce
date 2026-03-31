//
//  Displayable.swift
//  ITXEcommerce
//
//  Created by xdmGzDev on 30/3/26.
//

import Foundation
import SwiftUI

protocol Displayable: Hashable {
    var displayName: String { get }
    var color: Color { get }
}
