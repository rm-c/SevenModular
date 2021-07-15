//
//  QPUTERemind.swift
//  Seven
//
//  Created by crm on 2021/5/18.
//  Copyright © 2021 crm. All rights reserved.
//

import Foundation
import ObjectMapper
import WCDBSwift
import UTESmartBandApi

public enum QPUTERemindType : Int, ColumnJSONCodable {
    case QPUTE_Phone = 0
    case QPUTE_SMS
    case QPUTE_Wechat
    case QPUTE_QQ
    case QPUTE_Other = 16
}


public class QPUTERemind:NSObject, Mappable, TableCodable, TableModel {
    
    static var tableName: String {
        return String(describing: QPUTERemind.self)
    }
    
    var id: Int!
    @objc public var name: String! = ""
    var remindType: QPUTERemindType! = .QPUTE_Phone
    @objc public var remindSwitch: Bool = false
    @objc public var remindIcon: String! = ""
    
    @objc public func remindTypeInt() -> Int {
        return self.remindType.rawValue
    }
    
    init(name: String, remindType: QPUTERemindType, remindSwitch: Bool, remindIcon: String){
        self.name = name
        self.remindType = remindType
        self.remindSwitch = remindSwitch
        self.remindIcon = remindIcon
        self.id = remindType.rawValue
    }
    
    @objc public static func defaultedNotiArray() ->[QPUTERemind] {
        return [QPUTERemind.init(name: "来电提醒", remindType: .QPUTE_Phone, remindSwitch: false, remindIcon: "band_noti_0"),QPUTERemind.init(name: "短信提醒", remindType: .QPUTE_SMS, remindSwitch: false, remindIcon: "band_noti_1"),QPUTERemind.init(name: "微信提醒", remindType: .QPUTE_Wechat, remindSwitch: false, remindIcon: "band_noti_2"),QPUTERemind.init(name: "QQ提醒", remindType: .QPUTE_QQ, remindSwitch: false, remindIcon: "band_noti_3"),QPUTERemind.init(name: "其他提醒", remindType: .QPUTE_Other, remindSwitch: false, remindIcon: "band_noti_4")]
    }
    
    
    @objc public static func searchData() -> [QPUTERemind] {
        
        var array:[QPUTERemind] = Database.defaulted.seven_getObjects(on: QPUTERemind.Properties.all)
        if !array.isEmpty {
            return array
        } else {
            array = QPUTERemind.defaultedNotiArray()
            Database.defaulted.seven_insert(objects: array)
            //第一次需要配对
            UTESmartBandClient.sharedInstance().setUTEOption(UTEOption.openRemindIncall)
        }
        return array
    }
    
    @objc public static func insertData(models: [QPUTERemind]) {
        Database.defaulted.seven_insert(objects: models)
    }
    
    @objc public static func updateData(model: QPUTERemind) {
        Database.defaulted.seven_update(objects: model, on: QPUTERemind.Properties.all, where: QPUTERemind.Properties.id == model.id)
    }
    
    required public init?(map: Map) {
        
    }
    
    public func mapping(map: Map) {
        
        name <- map["name"]
        remindType <- map["platformType"]
        remindSwitch <- map["platform_switch"]
        remindIcon <- map["platform_icon"]
    }
    
    
    public enum CodingKeys: String, CodingTableKey {
        public typealias Root = QPUTERemind

        case id
        case name
        case remindType
        case remindSwitch
        case remindIcon

        public static let objectRelationalMapping = TableBinding(CodingKeys.self)

        public static var columnConstraintBindings: [CodingKeys: ColumnConstraintBinding]? {
            return [
                id: ColumnConstraintBinding(isPrimary: true)
            ]
        }
    }
}
