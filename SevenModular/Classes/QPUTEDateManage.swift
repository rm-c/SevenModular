//
//  WatchDataIndex.swift
//  Pods-SevenModular_Example
//
//  Created by crm on 2021/7/13.
//

import UIKit

class QPUTEDateManage: NSObject {
    
}


extension Date {
    
    static func date(withDateString dateString: String, formatString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formatString
        let date = dateFormatter.date(from: dateString)
        return date
    }
    
    
    static func formatDateToStringYMDHM(_ date: Date?) -> String? {

        let dateFormat = DateFormatter()
        dateFormat.timeZone = NSTimeZone.default
        dateFormat.dateFormat = "yyyy-MM-dd HH:mm"
        var res: String? = nil
        if let date = date {
            res = dateFormat.string(from: date)
        }

        return res
    }
    
    static func formatDateToStringALLEx(_ date: Date?) -> String? {

        let dateFormat = DateFormatter()
        dateFormat.timeZone = NSTimeZone.default
        dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
        var res: String? = nil
        if let date = date {
            res = dateFormat.string(from: date)
        }

        return res
    }
    
    static func formatDateToStringYMDH(_ date: Date?) -> String? {

        let dateFormat = DateFormatter()
        dateFormat.timeZone = NSTimeZone.default
        dateFormat.dateFormat = "yyyy-MM-dd HH"
        var res: String? = nil
        if let date = date {
            res = dateFormat.string(from: date)
        }

        return res
    }
    
    static func formatDateToStringYMD(_ date: Date?) -> String? {

        let dateFormat = DateFormatter()
        dateFormat.timeZone = NSTimeZone.default
        dateFormat.dateFormat = "yyyy-MM-dd"
        var res: String? = nil
        if let date = date {
            res = dateFormat.string(from: date)
        }

        return res
    }
    
    //计算两个时间相差 返回分钟
    static func startDate(_ startDate: String, endDate: String, formatString: String?) -> Int {
        var formatString = formatString
        
        if formatString == nil {
            formatString = "yyyy-MM-dd HH:mm:ss"
        }
        
        let start = self.date(withDateString: startDate, formatString: formatString!)
        
        let end = self.date(withDateString: endDate, formatString: formatString!)
        
        return Int(((end?.timeIntervalSince1970 ?? 0.0) - (start?.timeIntervalSince1970 ?? 0.0)) / 60)
        
    }
    
    //转yyyy-MM-dd格式
    static func date(with dateString: String) -> String? {
        let date = self.date(withDateString: dateString, formatString: "yyyy-MM-dd-HH:mm")
        return formatDateToStringYMD(date)
    }
    
    //转yyyy-MM-dd mm-ss格式
    static func date(withTimeUTEString dateString: String) -> String? {
        let date = self.date(withDateString: dateString, formatString: "yyyy-MM-dd-HH-mm")
        return formatDateToStringYMDHM(date)
    }
    
    //转yyyy-MM-dd hh-mm-ss格式 专门处理ute手表时间
    static func date(withTimeUTEYMDMSString dateString: String) -> String? {
        let date = self.date(withDateString: dateString, formatString: "yyyy-MM-dd-HH-mm-ss")
        return formatDateToStringALLEx(date)
    }

    //转yyyy-MM-dd mm格式 专门处理ute手表时间
    static func date(withTimeUTEYMDMString dateString: String) -> String? {
        let date = self.date(withDateString: dateString, formatString: "yyyy-MM-dd-HH")
        return formatDateToStringYMDH(date)
    }
    
    //转yyyy-MM-dd格式 专门处理ute手表时间
    static func date(withYMDString dateString: String) -> String? {
        let date = self.date(withDateString: dateString, formatString: "yyyy-MM-dd")
        return formatDateToStringYMD(date)
    }
    
    
}
