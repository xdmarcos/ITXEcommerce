//
//  ITXEcommerceMigrationPlan.swift
//  ITXEcommerce
//

import SwiftData

enum ITXEcommerceMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] { [SchemaV1.self] }
    static var stages: [MigrationStage] { [] }
}

enum SchemaV1: VersionedSchema {
    static let versionIdentifier = Schema.Version(1, 0, 0)
    static var models: [any PersistentModel.Type] { [Product.self, CartItem.self] }
}
