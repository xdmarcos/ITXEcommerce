//
//  ColumnsSelectorButton.swift
//  ITXEcommerce
//
//  Created by xdmGzDev on 30/3/26.
//

import SwiftUI

struct ColumnsSelectorButton: View {
    enum ColumnsCount: Int, CaseIterable {
        case two = 2
        case three = 3
    }

    private var columnCount: ColumnsCount
    private var onTap: () -> Void = { }

    init(columnCount: ColumnsCount = .two, onTap: @escaping () -> Void = { }) {
        self.columnCount = columnCount
        self.onTap = onTap
    }

    var body: some View {
        Button(action: onTap) {
            Image(systemName: columnCount.rawValue == 2 ? "square.grid.3x3" : "square.grid.2x2")
        }
        .accessibilityLabel(columnCount.rawValue == 2 ? "Switch to 3 columns" : "Switch to 2 columns")
    }
}

// MARK: - Previews

#Preview {
    ColumnsSelectorButton(columnCount: .two)
}
