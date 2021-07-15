//
//  SedentaryRemind.swift
//  Seven
//
//  Created by crm on 2021/5/25.
//  Copyright © 2021 crm. All rights reserved.
//

import Foundation
import ObjectMapper
import WCDBSwift
import UTESmartBandApi

public class QPSedentaryRemind:NSObject, Mappable,TableCodable, TableModel {
    
    static var tableName: String {
        return String(describing: QPSedentaryRemind.self)
    }
    
    var id: Int! = 0
    @objc open var startTime: String! = "9:00"
    @objc open var endTime: String! = "21:00"
    @objc open var enable: Bool = false
    @objc open var duration: Int = 60
    @objc open var enableSiesta: Bool = false
    
    @objc public func turnRemind() -> UTEModelDeviceSitRemind {
        let model = UTEModelDeviceSitRemind()
        model.startTime = self.startTime
        model.endTime = self.endTime
        model.enable = self.enable
        model.duration = self.duration
        model.enableSiesta = self.enableSiesta
        return model
    }
    
    @objc public static func searchData() -> QPSedentaryRemind {
        guard let dataModel:QPSedentaryRemind = Database.defaulted.seven_getObject(on: QPSedentaryRemind.Properties.all) else {
            let model = QPSedentaryRemind()
            model.enable = UTESmartBandClient.sharedInstance().connectedDevicesModel!.isHasSitRemindDuration
            Database.defaulted.seven_insert(objects: model)
            return model
        }
        return dataModel
    }
    
    @objc public static func updateData(model: QPSedentaryRemind) {
        Database.defaulted.seven_update(objects: model, on: QPSedentaryRemind.Properties.all, where: QPSedentaryRemind.Properties.id == 0)
    }
    
    
    override public init() {
    }
    
    required public init?(map: Map) {
        
    }
    
    public func mapping(map: Map) {
        startTime <- map["startTime"]
        endTime <- map["endTime"]
        enable <- map["enable"]
        duration <- map["duration"]
        enableSiesta <- map["enableSiesta"]
    }
    
    
    public enum CodingKeys: String, CodingTableKey {
        public typealias Root = QPSedentaryRemind
        
        case id
        case startTime
        case endTime
        case enable
        case duration
        case enableSiesta
        public static let objectRelationalMapping = TableBinding(CodingKeys.self)
        
        public static var columnConstraintBindings: [CodingKeys: ColumnConstraintBinding]? {
            return [
                id: ColumnConstraintBinding(isPrimary: true)
            ]
        }
    }
}
