//
//  MenuSelectorButton.swift
//  ITXEcommerce
//
//  Created by xdmGzDev on 30/3/26.
//

import SwiftUI

struct MenuSelectorButton<SelectionValue: Displayable>: View {
    private var selectedCategory: Binding<SelectionValue?>
    private var categories: [SelectionValue]
    private let title: String
    private let resetTitle: String
    private let checkedSystemName: String
    private let uncheckedSystemName: String
    private let accessibilityLabel: String?

    init(
        selectedCategory: Binding<SelectionValue?>,
        allCases: [SelectionValue],
        title: String,
        resetTitle: String,
        checkedSystemName: String,
        uncheckedSystemName: String,
        accessibilityLabel: String? = nil
    ) {
        self.selectedCategory = selectedCategory
        self.categories = allCases
        self.title = title
        self.resetTitle = resetTitle
        self.checkedSystemName = checkedSystemName
        self.uncheckedSystemName = uncheckedSystemName
        self.accessibilityLabel = accessibilityLabel
    }

    var body: some View {
        Menu {
            Picker(title, selection: selectedCategory) {
                Text(resetTitle).tag(Optional<SelectionValue>.none)
                ForEach(categories, id: \.self) { category in
                    Text(category.displayName).tag(Optional(category))
                }
            }
        } label: {
            Image(systemName: selectedCategory.wrappedValue == nil ? uncheckedSystemName : checkedSystemName)
        }
        .accessibilityLabel(accessibilityLabel ?? "Menu selector")
    }
}
