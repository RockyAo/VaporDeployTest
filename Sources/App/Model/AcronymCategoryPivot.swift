//
//  AcronymCategoryPivot.swift
//  App
//
//  Created by Rocky on 2018/6/4.
//

import Foundation
import FluentPostgreSQL

final class AcronymCategoryPivot: PostgreSQLUUIDPivot {
    
    //id
    var id:UUID?
    
    //连接两个模型的ID
    var acronymID: Acronym.ID
    var categoryID: Category.ID
    
    //定义Pivot 需要的属性. fluent会由此得出数据库的关联类型
    typealias Left = Acronym
    typealias Right = Category
    
    // IDkeypath
    static let leftIDKey: LeftIDKey = \.acronymID
    static let rightIDKey: RightIDKey = \.categoryID
    
    init(_ acronymID: Acronym.ID, _ categoryID: Category.ID) {
        self.acronymID = acronymID
        self.categoryID = categoryID
    }
}

extension AcronymCategoryPivot: Migration {
    // 2
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
            // 3
            return Database.create(self, on: connection) { builder in
                // 4
                try addProperties(to: builder)
                // 5
                try builder.addReference(from: \.acronymID,
                                         to: \Acronym.id)
                // 6
                try builder.addReference(from: \.categoryID,
                                         to: \Category.id)
            }
    }
}
