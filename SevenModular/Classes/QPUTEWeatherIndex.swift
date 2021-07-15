//
//  QPUTEWeather.swift
//  Seven
//
//  Created by crm on 2021/7/7.
//  Copyright © 2021 crm. All rights reserved.
//

import UIKit
import ObjectMapper
import UTESmartBandApi

public class QPUTEWeatherIndex: NSObject,Mappable {
    
    var temperature: Int! = 0
    var high_temperature: Int! = 0
    var low_temperature: Int! = 0
//    var tem_high_temperature: Int! = 0
//    var tem_low_temperature: Int! = 0
//    var latitude: String! = ""
//    var longitude: String! = ""
    @objc public var code: Int = 0
    var text: String! = ""
    
    override init() {
        
    }
    
    @objc public static func jsonDic(dic: [String:Any]) -> QPUTEWeatherIndex? {
        return QPUTEWeatherIndex.init(JSON: dic)
    }
    
    func uteWeather() -> UTEModelWeather {
        let weather = UTEModelWeather()
        weather.type = UTEWeatherType(rawValue: code) ?? .wind
        weather.temperatureCurrent = temperature
        weather.temperatureMax = high_temperature
        weather.temperatureMin = low_temperature
        weather.pm25 = 20
        weather.aqi = 20
        return weather
    }
    
    required public init?(map: Map) {
        
    }
    
    public func mapping(map: Map) {
        temperature <- (map["temperature"],IntTransformTyper())
        high_temperature <- (map["high"],IntTransformTyper())
        low_temperature <- (map["low"],IntTransformTyper())
//        tem_high_temperature <- map["tem_high_temperature"]
//        tem_low_temperature <- map["tem_low_temperature"]
//        latitude <- map["latitude"]
//        longitude <- map["longitude"]
        code <- map["code"]
        text <- map["text"]
    }
    
    
}


class IntTransformTyper: TransformOf<Int, Any> {
    init(){
        super.init(fromJSON: { (data) -> Int? in
            if let data = data as? Int {
                return data
            } else if let data = data as? String {
                return Int(data)
            }
            return nil
        }) { (data) -> Any? in
            return data
        }
    }
}
