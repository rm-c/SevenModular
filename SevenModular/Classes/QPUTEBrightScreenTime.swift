//
//  QPUTEBrightScreenTime.swift
//  Seven
//
//  Created by crm on 2021/5/25.
//  Copyright © 2021 crm. All rights reserved.
//

import Foundation
import ObjectMapper
import WCDBSwift

public class QPUTEBrightScreenTime:NSObject, Mappable, TableCodable, TableModel {
    
    static var tableName: String {
        return String(describing: QPUTEBrightScreenTime.self)
    }
    
    var id: Int! = 0
    @objc var lightTime: Int = 5
    @objc var enable: Bool = true
    
    override init() {
        
    }
    
    @objc static func searchData() -> QPUTEBrightScreenTime {
        guard let dataModel:QPUTEBrightScreenTime = Database.defaulted.seven_getObject(on: QPUTEBrightScreenTime.Properties.all) else {
            let model = QPUTEBrightScreenTime()
            Database.defaulted.seven_insert(objects: model)
            return model
        }
        return dataModel
    }
    
    @objc static func insertData(model: QPUTEBrightScreenTime) {
        Database.defaulted.seven_insert(objects: model)
    }
    
    @objc static func updateData(model: QPUTEBrightScreenTime) {
        Database.defaulted.seven_update(objects: model, on: QPUTEBrightScreenTime.Properties.all, where: QPUTEBrightScreenTime.Properties.id == 0)
    }
    
    required public init?(map: Map) {
        
    }
    
    public func mapping(map: Map) {
        
    }
    
    public enum CodingKeys: String, CodingTableKey {
        public typealias Root = QPUTEBrightScreenTime
        
        case id
        case lightTime
        case enable
        
        public static let objectRelationalMapping = TableBinding(CodingKeys.self)
        
        public static var columnConstraintBindings: [CodingKeys: ColumnConstraintBinding]? {
            return [
                id: ColumnConstraintBinding(isPrimary: true)
            ]
        }
    }
}
