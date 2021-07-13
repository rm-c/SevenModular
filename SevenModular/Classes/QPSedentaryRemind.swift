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

class QPSedentaryRemind:NSObject, Mappable,TableCodable, TableModel {
    
    static var tableName: String {
        return String(describing: QPSedentaryRemind.self)
    }
    
    var id: Int! = 0
    @objc var startTime: String! = "9:00"
    @objc var endTime: String! = "21:00"
    @objc var enable: Bool = false
    @objc var duration: Int = 60
    @objc var enableSiesta: Bool = false
    
    @objc func turnRemind() -> UTEModelDeviceSitRemind {
        let model = UTEModelDeviceSitRemind()
        model.startTime = self.startTime
        model.endTime = self.endTime
        model.enable = self.enable
        model.duration = self.duration
        model.enableSiesta = self.enableSiesta
        return model
    }
    
    @objc static func searchData() -> QPSedentaryRemind {
        guard let dataModel:QPSedentaryRemind = Database.defaulted.seven_getObject(on: QPSedentaryRemind.Properties.all) else {
            let model = QPSedentaryRemind()
            model.enable = UTESmartBandClient.sharedInstance().connectedDevicesModel!.isHasSitRemindDuration
            Database.defaulted.seven_insert(objects: model)
            return model
        }
        return dataModel
    }
    
    @objc static func updateData(model: QPSedentaryRemind) {
        Database.defaulted.seven_update(objects: model, on: QPSedentaryRemind.Properties.all, where: QPSedentaryRemind.Properties.id == 0)
    }
    
    
    override init() {
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        startTime <- map["startTime"]
        endTime <- map["endTime"]
        enable <- map["enable"]
        duration <- map["duration"]
        enableSiesta <- map["enableSiesta"]
    }
    
    
    enum CodingKeys: String, CodingTableKey {
        typealias Root = QPSedentaryRemind
        
        case id
        case startTime
        case endTime
        case enable
        case duration
        case enableSiesta
        static let objectRelationalMapping = TableBinding(CodingKeys.self)
        
        static var columnConstraintBindings: [CodingKeys: ColumnConstraintBinding]? {
            return [
                id: ColumnConstraintBinding(isPrimary: true)
            ]
        }
    }
}
