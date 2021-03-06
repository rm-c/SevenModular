//
//  QPSmartWatchData.swift
//  Seven
//
//  Created by crm on 2021/5/27.
//  Copyright © 2021 crm. All rights reserved.
//

import Foundation
import ObjectMapper
import WCDBSwift
import UTESmartBandApi

public enum QPData24Type: Int {
    case QPDataTypeHRM = 0
    case QPDataTypeBlood
//    case QPDataTypeSleep
    case QPDataTypeTemperature
}

//心率
public class QPSmartHRMData: NSObject, Mappable, TableCodable, TableModel {
    
    static var tableName: String {
        return String(describing: QPSmartHRMData.self)
    }
    
    var id: Int!
    var heartTime: String! = ""
    var heartCount: String! = ""
//    var heartType: Int! = 0//QPUTEHRMType! = .QPHRMTypeNormal
    var uploadSeven: Bool! = false
    
    @objc override public init() {
        
    }
    
    @objc public static func dataSearch(time: String) -> [QPSmartHRMData] {
        return Database.defaulted.seven_getObjects(on: QPSmartHRMData.Properties.all,where: QPSmartHRMData.Properties.heartTime.like(time))
    }
    
    @objc public static func heartCounts(time: String,datas: [QPSmartHRMData] = []) -> [String] {
        return (datas.isEmpty ? self.dataSearch(time: time) : datas).compactMap { data -> String in
            return data.heartCount
        }
    }
    
    @objc public static func dataReload(time: String,datas: [QPSmartHRMData] = []) -> [Day24Data] {
        let oneDays = datas.isEmpty ? self.dataSearch(time: time) : datas
        
        var day24Array:[Day24Data] = []//Array.init(repeating: Day24Data(), count: 24)
        for index in 0...23 {
            let item = Day24Data()
            let time = "\(time.replacingOccurrences(of: "%", with: "")) " + String.init(format: "%02d", index)
            oneDays.forEach { data in
                if data.heartTime.contains(time) {
                    item.index = index
                    item.time = String.init(format: "%02d:00-%02d:59", index,index)//time
                    item.values.append(data.heartCount)
                    // item.time = data.bloodTime
                    item.is_empty = false
                    item.data_type = 0;
                }
            }
            if !item.values.isEmpty {
                day24Array.append(item)
            }
        }
//        for (index,_) in day24Array.enumerated() {
//            let item = day24Array[index]
//            item.index = index
//            item.time = "\(time)-" + String.init(format: "%2d", index)
//            oneDays.forEach { data in
//                if data.heartTime.contains(item.time) {
//                    item.values.append(data.heartCount)
//                    item.is_empty = false
//    //                    item.time = data.bloodTime
//                }
//            }
//        }
        return day24Array
    }
    
    @objc public static func jsonToModel(array: Array<[String : Any]>) -> [QPSmartHRMData]? {
        return Mapper<QPSmartHRMData>().mapArray(JSONArray: array)
    }
    
    //数据存储
    @objc public static func dataInsert(datas: [QPSmartHRMData]) {
        Database.defaulted.seven_insertOrReplace(objects: datas, on: QPSmartHRMData.Properties.all)
    }
    
    required public init?(map: Map) {
        
    }
    
    public func mapping(map: Map) {
        id <- map["id"]
        heartTime <- map["date"]
        heartCount <- map["heart_rate"]
//        heartType <- map["heartType"]
        
    }
    
    public enum CodingKeys: String, CodingTableKey {
        public typealias Root = QPSmartHRMData
        
        case id
        case heartTime
        case heartCount
//        case heartType
        case uploadSeven
        
        public static let objectRelationalMapping = TableBinding(CodingKeys.self)
        
        public static var columnConstraintBindings: [CodingKeys: ColumnConstraintBinding]? {
            return [
                heartTime: ColumnConstraintBinding(isPrimary: true, isUnique: true)
            ]
        }
    }
}


extension UTEModelHRMData {
    
    func hrmData() -> QPSmartHRMData {
        let data = QPSmartHRMData()
        data.heartTime = Date.date(withTimeUTEString: self.heartTime);//self.heartTime
        data.heartCount = self.heartCount
//        data.heartType = self.heartType.rawValue//QPUTEHRMType.init(rawValue: self.heartType.rawValue)
        
        return data
    }
}

//血压
public class QPSmartBloodData: NSObject, Mappable, TableCodable, TableModel {
    
    static var tableName: String {
        return String(describing: QPSmartBloodData.self)
    }
    
    var id: Int!
    var bloodTime: String! = ""
    var bloodSystolic: String! = ""
    var bloodDiastolic: String! = ""
//    var bloodType: Int! = 0
//    var heartRateIrregular: Bool! = false
    var uploadSeven: Bool! = false
    
    @objc override public init() {
        
    }
    
    @objc public static func dataSearch(time: String) -> [QPSmartBloodData] {
        return Database.defaulted.seven_getObjects(on: QPSmartBloodData.Properties.all,where: QPSmartBloodData.Properties.bloodTime.like(time))
    }
    
    @objc public static func bloodHigh(time: String,datas: [QPSmartBloodData] = []) -> [String] {
        return (datas.isEmpty ? self.dataSearch(time: time) : datas).compactMap { data -> String in
            return data.bloodSystolic
        }
    }
    
    @objc public static func bloodLow(time: String,datas: [QPSmartBloodData] = []) -> [String] {
        return (datas.isEmpty ? self.dataSearch(time: time) : datas).compactMap { data -> String in
            return data.bloodDiastolic
        }
    }
    
    //高压最大值
    @objc public static func maxBlood(values: [QPSmartBloodData]) -> String {
        var bloodMax = values.first!
        values.forEach { blood in
            if let bloodSystolic = Int(blood.bloodSystolic), let maxBlood = Int(bloodMax.bloodSystolic), bloodSystolic > maxBlood {
                bloodMax = blood
            }
        }
        return "\(bloodMax.bloodSystolic ?? "")/\(bloodMax.bloodDiastolic ?? "")"
    }
    //最小
    @objc public static func minBlood(values: [QPSmartBloodData]) -> String {
        var bloodMin = values.first!
        values.forEach { blood in
            if let bloodDiastolic = Int(blood.bloodDiastolic), let maxBlood = Int(bloodMin.bloodDiastolic), bloodDiastolic < maxBlood {
                bloodMin = blood
            }
        }
        return "\(bloodMin.bloodSystolic ?? "")/\(bloodMin.bloodDiastolic ?? "")"
    }
    
    //把一天的数据分成24份 一个小时一份 用来画折线图
    @objc public static func dataReload(time: String,datas: [QPSmartBloodData] = []) -> [Day24Data] {
        let oneDays = datas.isEmpty ? self.dataSearch(time: time) : datas
        
        var day24Array:[Day24Data] = []// = Array.init(repeating: Day24Data(), count: 24)
        for index in 0...23 {
            let item = Day24Data()
            let time = "\(time.replacingOccurrences(of: "%", with: "")) " + String.init(format: "%02d", index)
            
            oneDays.forEach { data in
                if data.bloodTime.contains(time) {
                    item.index = index
                    item.time = String.init(format: "%02d:00-%02d:59", index,index)//time
                    item.values.append(data.bloodSystolic)
                    item.other_values.append(data.bloodDiastolic)
                    // item.time = data.bloodTime
                    item.is_empty = false
                    item.data_type = 1;
                }
            }
            if !item.values.isEmpty {
                day24Array.append(item)
            }
        }
        
//        for (index,_) in day24Array.enumerated() {
//            let item = day24Array[index]
//            item.index = index
//            item.time = "\(time)-" + String.init(format: "%2d", index)
//            oneDays.forEach { data in
//                if data.bloodTime.contains(item.time) {
//                    item.values.append(data.bloodSystolic)
//                    item.other_values.append(data.bloodDiastolic)
//                    // item.time = data.bloodTime
//                    item.is_empty = false
//                }
//            }
//        }
        return day24Array
    }
    
    @objc public static func jsonToModel(array: Array<[String : Any]>) -> [QPSmartBloodData]? {
        return Mapper<QPSmartBloodData>().mapArray(JSONArray: array)
    }
    
    //数据存储
    @objc public static func dataInsert(datas: [QPSmartBloodData]) {
        Database.defaulted.seven_insertOrReplace(objects: datas, on: QPSmartBloodData.Properties.all)
    }
    
    required public init?(map: Map) {
        
    }
    
    public func mapping(map: Map) {
        id <- map["id"]
        bloodTime <- map["date"]
        bloodSystolic <- map["systolicPressure"]
        bloodDiastolic <- map["diastolicPressure"]
        uploadSeven <- map["uploadSeven"]
    }
    
    public enum CodingKeys: String, CodingTableKey {
        public typealias Root = QPSmartBloodData
        
        case id
        case bloodTime
        case bloodSystolic
        case bloodDiastolic
        case uploadSeven
//        case heartRateIrregular
//        case heartCount
        
        public static let objectRelationalMapping = TableBinding(CodingKeys.self)
        
        public static var columnConstraintBindings: [CodingKeys: ColumnConstraintBinding]? {
            return [
                bloodTime: ColumnConstraintBinding(isPrimary: true, isUnique: true)
            ]
        }
    }
}


extension UTEModelBloodData {
    
    func bloodData() -> QPSmartBloodData {
        let data = QPSmartBloodData()
        data.bloodTime = Date.date(withTimeUTEString: self.bloodTime);//self.bloodTime
//        data.heartCount = self.heartCount
        data.bloodSystolic = self.bloodSystolic
        data.bloodDiastolic = self.bloodDiastolic
//        data.bloodType = self.bloodType.rawValue//UTEBloodType.init(rawValue: self.bloodType.rawValue)
//        data.heartRateIrregular = self.heartRateIrregular
        return data
    }
}

//体温
public class QPSmartBodyTemperatureData: NSObject, Mappable, TableCodable, TableModel {
    
    static var tableName: String {
        return String(describing: QPSmartBodyTemperatureData.self)
    }
    
    var id: Int!
    var time: String! = ""
    var bodyTemperature: String! = ""
//    var shellTemperature: String! = ""
    var uploadSeven: Bool! = false
    
    @objc override public init() {
        
    }
    
    @objc public static func dataSearch(time: String) -> [QPSmartBodyTemperatureData] {
        return Database.defaulted.seven_getObjects(on: QPSmartBodyTemperatureData.Properties.all,where: QPSmartBodyTemperatureData.Properties.time.like(time))
    }
    
    @objc public static func bodyTemperatureCounts(time: String, datas: [QPSmartBodyTemperatureData] = []) -> [String] {
        return (datas.isEmpty ? self.dataSearch(time: time) : datas).compactMap { data -> String in
            return data.bodyTemperature
        }
    }
    
    @objc public static func dataReload(time: String, datas: [QPSmartBodyTemperatureData] = []) -> [Day24Data] {
        let oneDays = datas.isEmpty ? self.dataSearch(time: time) : datas
        
        var day24Array:[Day24Data] = []//Array.init(repeating: Day24Data(), count: 24)
        for index in 0...23 {
            let item = Day24Data()
            let time = "\(time.replacingOccurrences(of: "%", with: "")) " + String.init(format: "%02d", index)
            oneDays.forEach { data in
                if data.time.contains(time) {
                    item.index = index
                    item.time = String.init(format: "%02d:00-%02d:59", index,index)//time
                    item.values.append(data.bodyTemperature)
                    // item.time = data.bloodTime
                    item.is_empty = false
                    item.data_type = 2;
                }
            }
            if !item.values.isEmpty {
                day24Array.append(item)
            }
        }
//        for (index,_) in day24Array.enumerated() {
//            let item = day24Array[index]
//            item.index = index
//            item.time = "\(time)-" + String.init(format: "%2d", index)
//            oneDays.forEach { data in
//                if data.heartTime.contains(item.time) {
//                    item.values.append(data.heartCount)
//                    item.is_empty = false
//    //                    item.time = data.bloodTime
//                }
//            }
//        }
        return day24Array
    }
    
    @objc public static func jsonToModel(array: Array<[String : Any]>) -> [QPSmartBodyTemperatureData]? {
        return Mapper<QPSmartBodyTemperatureData>().mapArray(JSONArray: array)
    }
    
    //数据存储
    @objc public static func dataInsert(datas: [QPSmartBodyTemperatureData]) {
        Database.defaulted.seven_insertOrReplace(objects: datas, on: QPSmartBodyTemperatureData.Properties.all)
    }
    
    required public init?(map: Map) {
        
    }
    
    public func mapping(map: Map) {
        id <- map["id"]
        time <- map["date"]
        bodyTemperature <- map["temperature"]
//        shellTemperature <- map["shellTemperature"]
        
    }
    
    public enum CodingKeys: String, CodingTableKey {
        public typealias Root = QPSmartBodyTemperatureData
        
        case id
        case time
        case bodyTemperature
//        case shellTemperature
        case uploadSeven
        
        public static let objectRelationalMapping = TableBinding(CodingKeys.self)
        
        public static var columnConstraintBindings: [CodingKeys: ColumnConstraintBinding]? {
            return [
                time: ColumnConstraintBinding(isPrimary: true, isUnique: true)
            ]
        }
    }
}

extension UTEModelBodyTemperature {
    
    func bodyTemperatureData() -> QPSmartBodyTemperatureData {
        let data = QPSmartBodyTemperatureData()
        data.time = Date.date(withTimeUTEYMDMSString: self.time);//self.time
        data.bodyTemperature = self.bodyTemperature
        return data
    }
}

//用来画线
public class Day24Data: NSObject {
    @objc public var index:Int = 0
    @objc public var is_empty: Bool = true
    @objc public var values:[String]! = []   //存放数组里面的数据  高压
    @objc public var other_values:[String]! = []  //其他数据 舒张压
    @objc public var time:String = ""
    @objc public var data_type: Int = 0 //数据类型。0心率 1血压 2体温
    
    @objc public func averageValues() -> Float {
        return values.compactMap{Float($0)}.reduce(0, +)/Float(values.count)
    }
    
    @objc public func averageotherValues() -> Float {
        return other_values.compactMap{Float($0)}.reduce(0, +)/Float(other_values.count)
    }
    
    
//    @objc public open func averageValuesFloat() -> Float {
//        return Float(values.compactMap{Float($0)}.reduce(0, +)/Float(values.count))
//    }
    
    //获取平均值
    @objc public static func averageObtain(values: [String]) -> Float {
        return values.compactMap{Float($0)}.reduce(0, +)/Float(values.count)
    }
    //获取最大值
    @objc public static func highBodyObtain(values: [String]) -> Float {
        return values.compactMap{Float($0)}.max() ?? 36
    }
    //获取最小值
    @objc public static func lowBodyObtain(values: [String]) -> Float {
        return values.compactMap{Float($0)}.min() ?? 0
    }
}

//步数
public class QPSportWalk: Mappable {
    
    var step_count: Int! = 0
    var use_time: String! = "0"
    var calories: CGFloat! = 0
    var kilometer: CGFloat! = 0
    var date: String! = ""
    
    init() {
        
    }
    
    static func dataReload(datas: [QPSportWalk] = []) -> [QPSportWalk] {

        var dic:[String:[QPSportWalk]] = [:]
        datas.forEach { step in
            if let date = Date.date(withYMDString: step.date) {
                dic.updateValue([], forKey: date)
            }
        }
        
        for item in dic.keys {
            datas.forEach { step in
                if step.date.contains(item) {
                    dic[item]?.append(step)
                }
            }
        }
        
        var oneDays:[QPSportWalk] = []
        for value in dic.values {
            let walk = QPSportWalk()
            if let date = value.first?.date {
                walk.date = Date.date(withYMDString: date)
            }
            for item in value {
                walk.step_count += item.step_count
                walk.calories += item.calories
                walk.kilometer += item.kilometer
                
            }
            oneDays.append(walk)
        }
        return oneDays
    }
    
    required public init?(map: Map) {
        
    }
    
    public func mapping(map: Map) {
        step_count <- map["step_count"]
        use_time <- map["use_time"]
        calories <- map["calories"]
        kilometer <- map["kilometer"]
        date <- map["date"]
        
    }
}

//睡眠
public class QPSleepDataDay: Mappable {
    
    var device_id: Int! = 3
    var end_time_hour: Int! = 0 //结束小时数
    var end_time_minute: Int! = 0   //结束分钟数
    var total_minute: Int! = 0  //总分钟数
    var deep_sleep_count: Int! = 0  //深度睡眠次数
    var light_sleep_count: Int! = 0 //浅度睡眠次数
    var wake_count: Int! = 0    //清醒次数
    var deep_sleep_minute: Int! = 0 //深度睡眠时长
    var light_sleep_minute: Int! = 0    //浅度睡眠时长
    var date: String! = ""  //日期（哪一天的活动数据）
    var sleepData: String! = "" //睡眠分段数据 sleep_status  durations
    
    init() {
        
    }
    //1清醒 2浅睡 3深睡
    //对每一天的数据进行处理
    func sleepData(data:[UTEModelSleepData]) -> QPSleepDataDay {
        
        if let item = data.last {
            self.date = Date.date(with: item.startTime)
        }
        var sleepData: [QPSleepItem]! = []
        data.forEach { (data) in
            let total_minute = Date.startDate(data.startTime, endDate: data.endTime, formatString: "yyyy-MM-dd-HH-mm")
            self.total_minute += total_minute
            var sleepType = 0
            switch data.sleepType {
            case .awake:
                self.wake_count += 1
                sleepType = 1
            case .deepSleep:
                self.deep_sleep_count += 1
                self.deep_sleep_minute += total_minute
                sleepType = 3
            case .lightSleep:
                self.light_sleep_count += 1
                self.light_sleep_minute += total_minute
                sleepType = 2
            default:
                break
            }
            
            let item = QPSleepItem.init(sleepType, total_minute)
            sleepData.append(item)
        }
        self.end_time_hour = self.total_minute/60
        self.sleepData = sleepData.toJSONString()
        return self
    }
    
    required public init?(map: Map) {
        
    }
    
    public func mapping(map: Map) {
        
        end_time_hour <- map["end_time_hour"]
        end_time_minute <- map["end_time_minute"]
        total_minute <- map["total_minute"]
        deep_sleep_count <- map["deep_sleep_count"]
        light_sleep_count <- map["light_sleep_count"]
        wake_count <- map["wake_count"]
        deep_sleep_minute <- map["deep_sleep_minute"]
        light_sleep_minute <- map["light_sleep_minute"]
        date <- map["date"]
        sleepData <- map["sleepData"]
        
    }
}

public class QPSleepItem: Mappable {
    
    var sleep_status: Int! = 0 //睡眠状态
    var durations: Int! = 0   //持续时间
    
    init(_ sleep_status:Int,_ durations: Int) {
        self.sleep_status = sleep_status
        self.durations = durations
    }
    
    required public init?(map: Map) {
        
    }
    
    public func mapping(map: Map) {
        sleep_status <- map["sleep_status"]
        durations <- map["durations"]
    }
}


//extension Array where Element:Hashable {
//    var unique:[Element] {
//        var uniq = Set<Element>()
//        uniq.reserveCapacity(self.count)
//        return self.filter {
//            return uniq.insert($0).inserted
//        }
//    }
//}
