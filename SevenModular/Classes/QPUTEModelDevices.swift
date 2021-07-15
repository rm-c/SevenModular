//
//  QPUTEModelDevices.swift
//  Seven
//
//  Created by crm on 2021/5/26.
//  Copyright © 2021 crm. All rights reserved.
//

import Foundation
import ObjectMapper
import WCDBSwift
import UTESmartBandApi

public class QPUTEModelDevices:NSObject, Mappable, TableCodable, TableModel {
    
    static var tableName: String {
        return String(describing: QPUTEModelDevices.self)
    }
    
    var id: Int! = 0
    var identifier: String! = ""
    var name: String! = ""
    
    override init() {
        
    }
    
    func save(device: UTEModelDevices) {
        self.name = device.name
        self.identifier = device.identifier
        
        Database.defaulted.seven_insertOrReplace(objects: self)
    }
    
    static func setDevice() -> UTEModelDevices? {
        var devices:[QPUTEModelDevices] = []
        devices = Database.defaulted.seven_getObjects(on: QPUTEModelDevices.Properties.all)
        if let device = devices.last {
            let model = UTEModelDevices()
            model.name = device.name
            model.identifier = device.identifier
            return model
        }
        return nil
    }
    
    @objc static func deleteDevice(device: UTEModelDevices) {
//        let model = QPUTEModelDevices()
//        model.name = device.name
//        model.identifier = device.identifier
        
        Database.defaulted.seven_deleteObject(with: QPUTEModelDevices.self, where: QPUTEModelDevices.Properties.identifier == device.identifier)
    }
    
    required public init?(map: Map) {
        
    }
    
    public func mapping(map: Map) {
        
    }
    
    public enum CodingKeys: String, CodingTableKey {
        public typealias Root = QPUTEModelDevices
        
        case id
        case identifier
        case name
        
        public static let objectRelationalMapping = TableBinding(CodingKeys.self)
        
        public static var columnConstraintBindings: [CodingKeys: ColumnConstraintBinding]? {
            return [
                identifier: ColumnConstraintBinding(isPrimary: true),
                id: ColumnConstraintBinding(isAutoIncrement: true)
            ]
        }
    }
}
