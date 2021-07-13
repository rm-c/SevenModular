//
//  Database.swift
//  Seven
//
//  Created by crm on 2021/5/24.
//  Copyright © 2021 crm. All rights reserved.
//

import Foundation
import WCDBSwift

protocol TableModel {
    static var tableName: String { get }
}

class SEUTEDatabase {
    
}

extension Database {
    static let defaulted = { () -> Database in
        let documentPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)
        let documentPath = documentPaths[0]
        let dbpath = URL(fileURLWithPath: documentPath).appendingPathComponent("DB").appendingPathComponent("Seven.db").path
        #if DEBUG
            print("dbpath:\(dbpath)")
        #endif
        let db = Database(withPath: dbpath)
        
        do {
            //try db.create(table: User.self.tableName, of: User.self)
            try db.create(table: QPUTEAlarmWeek.tableName, of: QPUTEAlarmWeek.self)
            try db.create(table: QPUTERemind.tableName, of: QPUTERemind.self)
            try db.create(table: QPSedentaryRemind.tableName, of: QPSedentaryRemind.self)
            try db.create(table: QPUTEBrightScreenTime.tableName, of: QPUTEBrightScreenTime.self)
            try db.create(table: QPUTEModelDevices.tableName, of: QPUTEModelDevices.self)
            try db.create(table: QPSmartHRMData.tableName, of: QPSmartHRMData.self)
            try db.create(table: QPSmartBloodData.tableName, of: QPSmartBloodData.self)
            try db.create(table: QPSmartBodyTemperatureData.tableName, of: QPSmartBodyTemperatureData.self)
            
        } catch let error {
            print("create table error: \(error)")
            assert(false)
        }
//        FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("DB").appendingPathComponent("Seven.db")
        
        return db
    }()
}

extension Database {
    
    func seven_insert<Object: TableModel>(objects: [Object], on propertyConvertibleList: [PropertyConvertible]? = nil) where Object : TableEncodable {
        do {
            try self.insert(objects: objects, on: propertyConvertibleList, intoTable: Object.self.tableName)
        } catch {
            #if DEBUG
                dump(error)
                print("[ERROR]Database jh_insert error:\(error)")
            #endif
        }
    }
    
    func seven_insert<Object: TableModel>(objects: Object..., on propertyConvertibleList: [PropertyConvertible]? = nil) where Object : TableEncodable {
        do {
            try self.insert(objects: objects, on: propertyConvertibleList, intoTable: Object.self.tableName)
        } catch {
            #if DEBUG
                dump(error)
                print("[ERROR]Database jh_insert error:\(error)")
            #endif
        }
    }
    
    func seven_update<Object: TableModel>(objects: Object, on propertyConvertibleList: [PropertyConvertible], where condition: WCDBSwift.Condition? = nil) where Object : TableEncodable {
        do {
            try self.update(table: Object.self.tableName, on: propertyConvertibleList, with: objects, where: condition, orderBy: nil, limit: nil, offset: nil)
        } catch {
            #if DEBUG
                dump(error)
                print("[ERROR]Database jh_update error:\(error)")
            #endif
        }
    }
    
    func seven_insertOrReplace<Object: TableModel>(objects: [Object], on propertyConvertibleList: [PropertyConvertible]? = nil) where Object : TableEncodable {
        do {
            try self.insertOrReplace(objects: objects, on: propertyConvertibleList, intoTable: Object.self.tableName)
        } catch {
            #if DEBUG
                dump(error)
                print("[ERROR]Database jh_insertOrReplace error:\(error)")
            #endif
        }
    }

    func seven_insertOrReplace<Object: TableModel>(objects: Object..., on propertyConvertibleList: [PropertyConvertible]? = nil) where Object : TableEncodable {
        do {
            try self.insertOrReplace(objects: objects, on: propertyConvertibleList, intoTable: Object.self.tableName)
        } catch {
            #if DEBUG
                dump(error)
                print("[ERROR]Database jh_insertOrReplace error:\(error)")
            #endif
        }
    }
    
    func seven_deleteObject<Object: TableModel>(with objectType: Object.Type, where condition: WCDBSwift.Condition? = nil, orderBy orderList: [WCDBSwift.OrderBy]? = nil, limit: WCDBSwift.Limit? = nil, offset: WCDBSwift.Offset? = nil){
        do {
            try self.delete(fromTable: objectType.tableName, where: condition, orderBy: orderList, limit: limit, offset: offset)
        } catch {
            #if DEBUG
                dump(error)
                print("[ERROR]Database jh_delete error:\(error)")
            #endif
        }
    }
    
    func seven_getObjects<Object: TableModel>(on propertyConvertibleList: [PropertyConvertible], where condition: WCDBSwift.Condition? = nil, orderBy orderList: [WCDBSwift.OrderBy]? = nil, limit: WCDBSwift.Limit? = nil, offset: WCDBSwift.Offset? = nil) -> [Object] where Object : TableDecodable {
        do {
            return try self.getObjects(on: propertyConvertibleList, fromTable: Object.self.tableName, where: condition, orderBy: orderList, limit: limit, offset: offset)
        } catch {
            #if DEBUG
                dump(error)
                print("[ERROR]Database jh_getObjects error:\(error)")
            #endif
        }
        return []
    }
    
    func seven_getObject<Object: TableModel>(on propertyConvertibleList: [PropertyConvertible], where condition: WCDBSwift.Condition? = nil) -> Object? where Object : TableDecodable {
        do {
            return try self.getObject(on: propertyConvertibleList, fromTable: Object.self.tableName, where: condition)
        } catch {
            #if DEBUG
            dump(error)
            print("[ERROR]Database jh_getObject error:\(error)")
            #endif
        }
        return nil
    }
    
//    func seven_getValue<Object: TableModel>(on propertyConvertibleList: PropertyConvertible, where condition: WCDBSwift.Condition? = nil) -> String? where Object : TableDecodable {
//        do {
//            return try self.getValue(on: propertyConvertibleList, fromTable: Object.self.tableName, where: condition)
//        } catch {
//            #if DEBUG
//            dump(error)
//            print("[ERROR]Database jh_getObject error:\(error)")
//            #endif
//        }
//        return nil
//    }
}
