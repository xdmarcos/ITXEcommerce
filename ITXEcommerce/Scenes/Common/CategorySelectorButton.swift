//
//  CategorySelectorButton.swift
//  ITXEcommerce
//
//  Created by xdmGzDev on 30/3/26.
//

import SwiftUI

struct CategorySelectorButton<SelectionValue: Displayable>: View {
    private var selectedCategory: Binding<SelectionValue?>
    private var categories: [SelectionValue]

    init(selectedCategory: Binding<SelectionValue?>, allCases: [SelectionValue]) {
        self.selectedCategory = selectedCategory
        self.categories = allCases
    }

    var body: some View {
        Menu {
            Picker("Category", selection: selectedCategory) {
                Text("All").tag(Optional<SelectionValue>.none)
                ForEach(categories, id: \.self) { category in
                    Text(category.displayName).tag(Optional(category))
                }
            }
        } label: {
            Image(systemName: selectedCategory.wrappedValue == nil
                  ? "line.3.horizontal.decrease.circle"
                  : "line.3.horizontal.decrease.circle.fill")
        }
        .accessibilityLabel("Filter by category")
    }
}

// MARK: - Previews

#Preview {
    CategorySelectorButton(
        selectedCategory: .constant(.none),
        allCases: [
            ProductCategory(rawValue: "miscellaneous")!, // swiftlint:disable:this force_unwrapping
            ProductCategory(rawValue: "beauty")! // swiftlint:disable:this force_unwrapping
        ]
    )
}
