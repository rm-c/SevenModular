//
//  QPUTEAlarm.swift
//  Seven
//
//  Created by crm on 2021/5/19.
//  Copyright © 2021 crm. All rights reserved.
//

import Foundation
import ObjectMapper
import WCDBSwift
import UTESmartBandApi

class QPUTEAlarm:NSObject, Mappable {
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        
    }
}



public class QPUTEAlarmWeek:NSObject, Mappable,TableCodable, TableModel {
    static var tableName: String {
        return String(describing: QPUTEAlarmWeek.self)
    }
    
    var id: Int!
    @objc var title: String! = "闹钟"
    @objc var time: String! = ""
    @objc var week: Int = 0
    @objc var enable: Bool = false
    @objc var num: Int = 0
    @objc var countVibrate: Int = 0
    
    init(title:String, selected: Bool, alarmWeek: UTEAlarmWeek) {
        self.title = title
        self.enable = selected
        self.week = alarmWeek.rawValue
    }
    
    override init() {}
    
    @objc static func searchData() -> [QPUTEAlarmWeek] {
        return Database.defaulted.seven_getObjects(on: QPUTEAlarmWeek.Properties.all)
    }
    
    @objc static func insertData(model: QPUTEAlarmWeek) {
        Database.defaulted.seven_insert(objects: model)
    }
    
    @objc static func deleteData(model: QPUTEAlarmWeek) {
        Database.defaulted.seven_deleteObject(with: QPUTEAlarmWeek.self, where: QPUTEAlarmWeek.Properties.id == model.id)
    }
    
    @objc static func updateData(model: QPUTEAlarmWeek) {
        Database.defaulted.seven_update(objects: model, on: QPUTEAlarmWeek.Properties.all, where: QPUTEAlarmWeek.Properties.id == model.id)
        UTESmartBandClient.sharedInstance().setUTEAlarmArray([model.turnAlarm()], vibrate: 9)
    }
    
    @objc static func turnAlarms(values: [QPUTEAlarmWeek]) -> [UTEModelAlarm] {
        return values.compactMap{$0.turnAlarm()}
    }
    
    //时间选择默认显示
    @objc static func defaultedData() -> [QPUTEAlarmWeek] {
        return [QPUTEAlarmWeek.init(title: "周日", selected: false, alarmWeek: .sunday),QPUTEAlarmWeek.init(title: "周一", selected: false, alarmWeek: .monday),QPUTEAlarmWeek.init(title: "周二", selected: false, alarmWeek: .tuesday),QPUTEAlarmWeek.init(title: "周三", selected: false, alarmWeek: .wednesday),QPUTEAlarmWeek.init(title: "周四", selected: false, alarmWeek: .thursday),QPUTEAlarmWeek.init(title: "周五", selected: false, alarmWeek: .friday),QPUTEAlarmWeek.init(title: "周六", selected: false, alarmWeek: .saturday)]
    }
    
    //过滤选中的 进行组合
    @objc static func dataWeek(models:[QPUTEAlarmWeek]) -> Int {
        var week:Int = 0
        models.filter { model in
            return model.enable
        }.forEach { alarm in
            week = (UTEAlarmWeek(rawValue: UTEAlarmWeek.RawValue(UInt8(week)|UInt8(alarm.week)))!).rawValue
        }
        return week
    }
    
    //过滤选中的
    @objc static func filter(models:[QPUTEAlarmWeek]) -> [QPUTEAlarmWeek] {
        return models.filter { model in
            return model.enable
        }
    }
    
    //计算
    @objc static func reduce(models:[QPUTEAlarmWeek]) -> String {
        return models.reduce("") { weekString, model in
            return weekString + " " + model.title.suffix(2)
        }
    }
    
    //闹钟编号
    @objc static func alarmNum(values:[QPUTEAlarmWeek]) -> Int {
        let nums = values.compactMap{$0.num}
        if !nums.contains(1) {
            return 1
        } else if !nums.contains(2) {
            return 2
        } else {
            return 3
        }
    }
    
    required public init?(map: Map) {
        
    }
    
    @objc func turnAlarm() -> UTEModelAlarm {
        let model = UTEModelAlarm()
        model.time = self.time
        model.enable = self.enable
        model.countVibrate = self.countVibrate
        model.num = UTEAlarmNum.init(rawValue: self.num)!
        model.week = UTEAlarmWeek.init(rawValue: self.week)!
        return model
    }
    
    public func mapping(map: Map) {
        id <- map["id"]
        title <- map["title"]
        time <- map["time"]
        week <- map["week"]
        enable <- map["enable"]
        num <- map["num"]
        countVibrate <- map["countVibrate"]
    }
    
    public enum CodingKeys: String, CodingTableKey {
        public typealias Root = QPUTEAlarmWeek
        
        case id
        case title
        case time
        case week
        case enable
        case num
        case countVibrate
    
        public static let objectRelationalMapping = TableBinding(CodingKeys.self)
        
        public static var columnConstraintBindings: [CodingKeys: ColumnConstraintBinding]? {
            return [
                id: ColumnConstraintBinding(isPrimary: true, isAutoIncrement: true)
            ]
        }
    }
}


//class QPUTEAlarmWeek: Mappable,TableCodable, TableModel {
//
//    static var tableName: String {
//        return String(describing: QPUTEAlarmWeek.self)
//    }
//
//    var id: Int!
//    var name: String! = ""
//    var selected: Bool! = false
//    var alarmWeek: Int! = 0//UTEAlarmWeek!
//
//    public init(name:String, selected: Bool, alarmWeek: UTEAlarmWeek) {
//        self.name = name
//        self.selected = selected
//        self.alarmWeek = alarmWeek.rawValue
//    }
//
//    required init?(map: Map) {
//
//    }
//
//    func mapping(map: Map) {
//        id <- map["id"]
//        name <- map["name"]
//        selected <- map["selected"]
//        alarmWeek <- map["alarmWeek"]
//    }
//
//
//    enum CodingKeys: String, CodingTableKey {
//        typealias Root = QPUTEAlarmWeek
//
//        case id
//        case name
//        case selected
//        case alarmWeek
//
//        static let objectRelationalMapping = TableBinding(CodingKeys.self)
//
//        static var columnConstraintBindings: [CodingKeys: ColumnConstraintBinding]? {
//            return [
//                id: ColumnConstraintBinding(isPrimary: true, isAutoIncrement: true)
//            ]
//        }
//    }
//}
