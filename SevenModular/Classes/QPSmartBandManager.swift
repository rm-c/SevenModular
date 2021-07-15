//
//  QPSmartBandManager.swift
//  Seven
//
//  Created by crm on 2021/5/21.
//  Copyright © 2021 crm. All rights reserved.
//

import UIKit
import WCDBSwift
//import JSONModel
import ObjectMapper
//import MJExtension
import UTESmartBandApi

let ScreenWidth = UIScreen.main.bounds.width
let ScreenHeight = UIScreen.main.bounds.height

struct QPBandSync {
    var success: Bool! = false
    var syncType: UTEDeviceDataType?
    var syncing: Bool! = false  //true是正在同步中
    
    var bodyTemperature: Bool! = false//同步体温
    
    init(_ success: Bool,_ type: UTEDeviceDataType? = nil, temperature bodyTemperature: Bool = false) {
        self.success = success
        self.syncType = type
        self.bodyTemperature = bodyTemperature
    }
}

public class QPSmartBandManager: NSObject, UTEManagerDelegate {
    
    @objc public static let shareManger = QPSmartBandManager()
    
//    public typealias findDevicesBlock = (_ devicesState: UTEDevicesSate?) -> Void
//    public typealias callBackBlock = (_ devicesState: UTECallBack?) -> Void
    
    @objc open var mArrayDevices:[UTEModelDevices] = []
    
//    open var devicesSateBlock : findDevicesBlock?
//    open var callBackSateBlock : callBackBlock?
    
    @objc public var devicesSateBlock: ( (Int) -> Void )?   //UTEDevicesSate
    @objc public var callBackSateBlock: ( (Int) -> Void )?  //UTECallBack
    
    @objc public let smartBandMgr = UTESmartBandClient.sharedInstance()
    var passwordType : UTEPasswordType?
    @objc public var weatherIndex: QPUTEWeatherIndex?    //天气
    //    weak var connectVc : SmartBandConnectedControl?
    weak var alertView : UIAlertController?
    
    override init() {
        super.init()
        
        smartBandMgr.initUTESmartBandClient()
        smartBandMgr.isScanRepeat = true
        smartBandMgr.filerServers = ["5533"]
        smartBandMgr.delegate = self
        
//        smartBandMgr.debugUTELog = true
        
        if let device = QPUTEModelDevices.setDevice() {
            self.smartBandMgr.connect(device)
        }
    }
    
    // MARK: - UTEManagerDelegate
    public func uteManagerDiscover(_ modelDevices: UTEModelDevices!) {
        
        var sameDevices = false
        for model in self.mArrayDevices {
            if (model.identifier?.isEqual(modelDevices.identifier as String))! {
                model.rssi = modelDevices.rssi
                model.name = modelDevices.name
                sameDevices = true
                break
            }
            
        }
        
        if !sameDevices {
            print("***Scanned device name=\(String(describing: modelDevices.name)) id=\(String(describing: modelDevices.identifier))")
            self.mArrayDevices.append(modelDevices)
        }
        
        self.devicesSateBlock?(-1)
    }
    
    public func uteManagerExtraIsAble(_ isAble: Bool) {
        
        if isAble {
            print("***Successfully turn on the additional functions of the device")
        } else {
//            SVProgressHUD.showError(withStatus: "设备没有配对,推送信息不能使用")
            DispatchQueue.main.async {
                self.callBackSateBlock?(-1)
            }
            print("***Failed to open the extra functions of the device, the device is actively disconnected, please reconnect the device")
        }
        
    }
    
    public func uteManagerReceiveTodaySteps(_ runData: UTEModelRunData!) {
        
        print("***Today time=\(String(describing: runData.time))，Total steps=\(runData.totalSteps),Total distance=\(runData.distances),Total calories=\(runData.calories),Current hour steps=\(runData.hourSteps)")
        
    }
    
    public func uteManagerReceiveTodaySport(_ dict: [AnyHashable : Any]!) {
        
        let walk : UTEModelSportWalkRun = dict[kUTEQuerySportWalkRunData] as! UTEModelSportWalkRun
        print("sport device step=\(walk.stepsTotal)")
        
    }
    
    public func uteManagerDevicesSate(_ devicesState: UTEDevicesSate, error: Swift.Error?, userInfo info: [AnyHashable : Any] = [:]) {
        
        if let error = error {
            let code = (error as NSError).code
            let msg = (error as NSError).domain
            print("***error code=\(code),msg=\(msg)")
//            SVProgressHUD.showError(withStatus: msg)
        }
        print("处理完成\(devicesState.rawValue)")
        switch devicesState {
        
        case UTEDevicesSate.connected:
            //CN:每次连上应该设置一下配置，保证App和设备的信息统一
            //EN:You should set up the configuration every time you connect to ensure that the App and device information is unified
            self.setupConfiguration()
            break
        case UTEDevicesSate.disconnected:
            if error != nil {
                //                SVProgressHUD.showError(withStatus: error.localizedDescription)
                print("***Device disconnected abnormally=\(String(describing: error))")
            }else{
                print("***Device disconnected normally connectedDevicesModel=\(String(describing: self.smartBandMgr.connectedDevicesModel))")
            }
            self.devicesSateBlock?(UTEDevicesSate.disconnected.rawValue)
            break
        case UTEDevicesSate.connectingError:
//            SVProgressHUD.showError(withStatus: "连接失败，请稍后再试")
            print("连接失败")
        case UTEDevicesSate.syncBegin:
            print("***Device synchronization starts")
            break
        case UTEDevicesSate.syncSuccess:
            self.syncSucess(info: info)
            break
        case UTEDevicesSate.syncError:
//            modifySyncData()
            break
        case UTEDevicesSate.checkFirmwareError:
            break
        case UTEDevicesSate.updateHaveNewVersion:
            self.smartBandMgr.beginUpdateFirmware()
            break
        case UTEDevicesSate.updateNoNewVersion:
            break
        case UTEDevicesSate.updateBegin:
            break
        case UTEDevicesSate.updateSuccess:
            break
        case UTEDevicesSate.updateError:
            break
        case UTEDevicesSate.heartDetectingProcess:
            let model = info[kUTEQueryHRMData] as? UTEModelHRMData
            if model?.heartType == UTEHRMType.success || model?.heartType == UTEHRMType.fail || model?.heartType == UTEHRMType.timeout {
                print("***Heart rate test completed")
                if model?.heartType == UTEHRMType.success {
                    print("***The final test heart rate result is the next log")
//                    self.uteManagerReceiveTenMinLaterHRM(info)
                }
            }
            //接收到心率值
            self.heartDetectingData(model: model!)
            break
//        case UTEDevicesSate.heartCurrentValue:  //实时心率
//            if let hrm = info[kUTEQueryHRMData] as? UTEModelHRMData {
////                self.uteManagerReceiveTenMinLaterHRM(info)
//                DispatchQueue.main.async {
//                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: UpdateOfMeasurementData), object: nil, userInfo: [UpdateHRMKey:"\(hrm.heartCount ?? "80")"])
//                }
//            }
        case UTEDevicesSate.bloodDetectingProcess:
            if let model = info[kUTEQueryBloodData] as? UTEModelBloodData {
                if model.bloodType == UTEBloodType.success || model.bloodType == UTEBloodType.fail || model.bloodType == UTEBloodType.timeout {
                    print("***Blood pressure test completed")
                    if model.bloodType == UTEBloodType.success {
                        print("***The final blood pressure test result is the next log")
                        let info = [kUTEQueryBloodData:[model]]
                        syncSucess(info: info)
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateOfMeasurementData"), object: nil, userInfo: ["UpdateBloodKey":"\(model.bloodSystolic ?? "120")/\(model.bloodDiastolic ?? "75")"])
                        }
                        
                    }
                }
                self.bloodDetectingData(model: model)
            }
            
            break
        case UTEDevicesSate.heartDetectingStart:
            print("***UTEOptionHeartDetectingStart -> Heart rate test started")
            break
        case UTEDevicesSate.heartDetectingStop:
            print("***UTEOptionHeartDetectingStop -> Heart rate test stopped")
            break
        case UTEDevicesSate.heartDetectingError:
            print("***The device disconnected during the heart rate test")
            break
        case UTEDevicesSate.bloodDetectingStart:
            print("***Blood pressure test started")
            break
        case UTEDevicesSate.bloodDetectingStop:
            print("***Blood pressure test stopped")
            break
        case UTEDevicesSate.bloodDetectingError:
            print("***The device was disconnected during the blood pressure test")
            break
        case UTEDevicesSate.step:
            print("***Step status")
            break
        case UTEDevicesSate.sleep:
            print("***Sleep state")
            break
        case UTEDevicesSate.passwordState:
            let value : NSString = info[kUTEPasswordState] as! NSString
            switch value.integerValue {
            case UTEPasswordState.error.rawValue:
                if self.passwordType == UTEPasswordType.connect {
                    //Wrong password for connection
                    self.showPassAlertView(str: "连接的密码错误，请重新输入")
                }else if self.passwordType == UTEPasswordType.confirm {
                    //The verified password is wrong
                    self.showPassAlertView(str: "验证的密码错误，请重新输入")
                }
                break
            case UTEPasswordState.correct.rawValue:
                if self.passwordType == UTEPasswordType.confirm {
                    self.passwordType = UTEPasswordType.reset
                    //Password verification is successful, please enter a new password
                    self.showPassAlertView(str: "密码验证成功，请输入新的密码")
                }else if self.passwordType == UTEPasswordType.reset {
                    print("***The password is reset successfully, please remember the password")
                }else{
                    print("***The password is entered correctly and the bracelet starts to connect")
                }
                break
            case UTEPasswordState.need.rawValue:
                self.passwordType = UTEPasswordType.connect
                //To connect the bracelet, please enter the password
                self.showPassAlertView(str: "要连接手环，请输入密码")
                break
            case UTEPasswordState.new.rawValue:
                self.passwordType = UTEPasswordType.connect
                //New bracelet, please enter a new password
                self.showPassAlertView(str: "新的手环，请输入新的密码")
                break
            default: break
                
            }
            
        default: break
            
        }
    }
    
    public func uteManagerUTEIbeaconOption(_ option: UTEIbeaconOption, value: String!) {
        
        print("ibeacon value = \(String(describing: value))")
        
    }
    
    public func uteManagerTakePicture() {
        
        print("***I took a photo, if I don’t take a photo, please exit the photo mode")
        
    }
    
    public func uteManagerBluetoothState(_ bluetoothState: UTEBluetoothState) {
        
        weak var weakSelf = self
        DispatchQueue.main.async {
            if bluetoothState == UTEBluetoothState.close {
                if self.alertView != nil {
                    return
                }
                //Please turn on the phone Bluetooth
                let alterVC = UIAlertController.init(title: "提示", message: "请打开手机蓝牙", preferredStyle: UIAlertController.Style.alert)
                
                weakSelf?.alertView = alterVC
                
                let window = UIApplication.shared.keyWindow
                let nav : UINavigationController = window?.rootViewController as! UINavigationController
                
                alterVC.addAction(UIAlertAction.init(title: "好", style: UIAlertAction.Style.cancel, handler: { (cancelAction) in
                    UIApplication.shared.open(URL.init(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                }))
                
                nav.present(alterVC, animated: true, completion: nil)
                self.devicesSateBlock?(-1)
            } else if bluetoothState == UTEBluetoothState.unauthorized {
                if self.alertView != nil {
                    return
                }
                let alterVC = UIAlertController.init(title: "SevenSmart需要蓝牙授权", message: "您可以在“设置”中开启授权", preferredStyle: UIAlertController.Style.alert)
                weakSelf?.alertView = alterVC
                let window = UIApplication.shared.keyWindow
                let nav : UINavigationController = window?.rootViewController as! UINavigationController
                
                alterVC.addAction(UIAlertAction.init(title: "取消", style: UIAlertAction.Style.cancel, handler:nil))
                alterVC.addAction(UIAlertAction.init(title: "去授权", style: UIAlertAction.Style.default, handler: { (action) in
                    UIApplication.shared.open(URL.init(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                }))
                
                nav.present(alterVC, animated: true, completion: nil)
                self.devicesSateBlock?(-1)
            } else{
                self.alertView?.dismiss(animated: true, completion: nil)
                self.alertView = nil
                
            }
        }
    }
    
    public func uteManagerReceiveCustomData(_ data: Data!, result: Bool) {
        
        if result {
            print("******Successfully received data = \(String(describing: data))")
        }else{
            print("***Failed to receive data")
        }
        
    }
    
    public func uteManagerSendCustomDataResult(_ result: Bool) {
        
        if result {
            print("***Send custom data successfully")
        }else{
            print("***Failed to send custom data")
        }
        
    }
    
    public func uteManageTouchDeviceReceive(_ data: Data!) {
        let bytes = [UInt8](data)
        if let byte1 = bytes.first,let byte2 = bytes.last {
//            if (byte1 == 0xd1) && (byte2 == 0x0a) {
//            }
            if byte1&byte2 == 0xd1&0x0a {
                UTEAudioPlayer.shareInstance.callsIphone()
            }
        }
    }
    //设置成功回调
    public func uteManageUTEOptionCallBack(_ callback: UTECallBack) {
        DispatchQueue.main.async {
            self.callBackSateBlock?(callback.rawValue)
        }
    }
    
    //数据同步进度
    public func uteManagerSyncProcess(_ process: Int) {
        print("同步进度:\(process)")
    }
    
//    func uteManagerReceiveSportHRM(_ dict: [AnyHashable : Any]!) {
//        print(dict)
//    }
    
    //心率每10分钟返回一次
    public func uteManagerReceiveTenMinLaterHRM(_ dict: [AnyHashable : Any]!) {
        if let hrm = dict[kUTEQuery24HRMData] as? UTEModelHRMData {
            let dict = [kUTEQuery24HRMData : [hrm]]
            syncSucess(info: dict)
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateOfMeasurementData"), object: nil, userInfo: ["UpdateHRMKey":"\(hrm.heartCount ?? "80")"])
            }
        }
    }
    
    // MARK: - 私有方法
    func setupConfiguration() -> Void {
        
        //CN:关闭扫描
        //EN:Turn off scan
        self.smartBandMgr.stopScanDevices()
        
        //CN:设置设备时间
        //EN:Set device time
        self.smartBandMgr.setUTEOption(UTEOption.syncTime)
        
        //CN:设置设备单位:公尺或者英寸
        //EN:Set device unit: meters or inches
        //        self.smartBandMgr.setUTEOption(UTEOption.unitInch)
        self.smartBandMgr.setUTEOption(UTEOption.unitMeter)
        
        //CN:设置设备中身高、体重 久坐提醒
        //EN:Set the height and weight of the device
        deviceInfoSetting()
        adjustSleepInfoSiesta()
        
        self.smartBandMgr.setUTEOption(UTEOption.heartSwitchDynamic)
        
        self.smartBandMgr.setUTEOption(UTEOption.readBaseStatus)
        
        //CN:设置久坐提醒
        //EN:Set a sedentary reminder
        
//        smartBandMgr.setUTELanguageSwitchDirectly(UTEDeviceLanguage.chinese)
        //CN:设置设备其他特性 忽扰模式
        //EN:Set other features of the device
//        self.smartBandMgr.sendUTEAllTime(UTESilenceType.none, exceptStartTime: "23:00", endTime: "07:00", except: true)
        
        //CN:设置其他配置，防止手环被其他手机连接了，配置与现App不一致
        //EN:Set other configurations to prevent the bracelet from being connected by other phones, and the configuration is inconsistent with the current App
        if let connectDevices = self.smartBandMgr.connectedDevicesModel {
            if let dataModel:QPSedentaryRemind = Database.defaulted.seven_getObject(on: QPSedentaryRemind.Properties.all) {
                if connectDevices.isHasSitRemindDuration {
                    self.onClickSitRemind(remind: dataModel)
                } else {
                    self.smartBandMgr.setUTESitRemindOpenTime(dataModel.duration)
                }
            }
            
            //设置天气
            if let weatherIndex = weatherIndex {
                if connectDevices.isHasWeather {
                    self.smartBandMgr.sendUTETodayWeather(UTEWeatherType(rawValue: weatherIndex.code) ?? .wind, currentTemp: weatherIndex.temperature, maxTemp: weatherIndex.high_temperature, minTemp: weatherIndex.low_temperature, pm25: 20, aqi: 20, tomorrowType: UTEWeatherType(rawValue: weatherIndex.code) ?? .wind, tmrMax: weatherIndex.high_temperature, tmrMin: weatherIndex.low_temperature)
                } else if connectDevices.isHasWeatherSeven {
                    let uteWeathers = [UTEModelWeather](repeating: weatherIndex.uteWeather(), count: 7)
                    self.smartBandMgr.sendUTESevenWeather(uteWeathers)
                }
            }
                
            
            if connectDevices.isHasLanguageSwitchDirectly {
                self.smartBandMgr.setUTELanguageSwitchDirectly(UTEDeviceLanguage.chinese)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                //CN:延迟一会儿，因为刚连接上，设备还在读取信息中
                //EN:Delay for a while, because the device is still reading the information just after connecting
                
//                print("***Device version=\(String(describing: connectDevices.version)) Power=\(String(describing: connectDevices.battery)) ,rssi=\(String(describing: connectDevices.rssi))，address=\(String(describing: connectDevices.address))")
                
                QPUTEModelDevices().save(device: connectDevices)
                
//                self.bandDataSync()
                
                self.devicesSateBlock?(UTEDevicesSate.connected.rawValue)
                
                self.syncData = [QPBandSync.init(false, connectDevices.isHas24HourHRM ? .HRM24 : .HRM),QPBandSync.init(false, .blood),QPBandSync.init(false, .sleep),QPBandSync.init(false, .steps),QPBandSync.init(false, temperature: true)]
            }
        }
        
    }
    
    func onClickSitRemind(remind : QPSedentaryRemind) -> Void {
        
        let model = UTEModelDeviceSitRemind.init()
        model.enable = remind.enable
        model.startTime = remind.startTime
        model.endTime = remind.startTime
        model.duration = remind.duration
        model.enableSiesta = false
        self.smartBandMgr.sendUTESitRemindModel(model)
        
    }
    
    //午睡
    func adjustSleepInfoSiesta() {
        
        let param = UTEModelDeviceSleepAdjust.init()
        
        //CN:设置 中午睡眠时间范围
        param.timeDurationSet = true
        param.timeDurationType = UTEDeviceSleepTimeType.siesta
        param.timeDurationStatus = UTEDeviceSleepStatus.open
        param.timeDurationStart = "13:00"
        param.timeDurationEnd = "14:00"
        self.smartBandMgr.setUTESleepAdjustParam(param)
        
    }
    
    @objc public func deviceInfoSetting(lightTime:Int = 5,handlight: Int = 1,local:Bool = true) {
        
//        guard connectDevices() != nil && SEUserObject.sharedSEUser() != nil else {
//            return
//        }
        
        let infoModel = UTEModelDeviceInfo.init()
//        infoModel.heigh = CGFloat(SEUserObject.sharedSEUser().height > 67 ? SEUserObject.sharedSEUser().height : 175)
//        infoModel.weight = CGFloat(SEUserObject.sharedSEUser().weight > 10 ? SEUserObject.sharedSEUser().weight : 60)
        infoModel.age = 30
//        if let sex = UTEDeviceInfoSex.init(rawValue: SEUserObject.sharedSEUser().sex) {
//            infoModel.sex = sex
//        }
//        infoModel.languageIsChinese = true
        if local, let dataModel:QPUTEBrightScreenTime = Database.defaulted.seven_getObject(on: QPUTEBrightScreenTime.Properties.all) {
            infoModel.handlight = dataModel.enable ? 1 : -1
            infoModel.lightTime = dataModel.lightTime
        } else {
            infoModel.handlight = handlight
            infoModel.lightTime = lightTime
        }
        infoModel.maxHeart = 185
//        if (SEUserObject.sharedSEUser().target.step_goal_count != nil) {
//            infoModel.sportTarget = Int(SEUserObject.sharedSEUser().target.step_goal_count) ?? 6000
//        } else {
//            infoModel.sportTarget = 6000
//        }
        
        
        self.smartBandMgr.setUTEInfoModel(infoModel)
    }
    
    @objc public func connectDevices() -> UTEModelDevices? {
        return self.smartBandMgr.connectedDevicesModel
    }
    
    func syncSucess(info : Dictionary<AnyHashable, Any>) -> Void {
        
        print("Synchronization complete")
//        var syncType: HomeHealthType?
        //        let arrayAllSport = info[kUTEQuerySportHRMData] as! NSArray
        
        if let arrayRun = info[kUTEQueryRunData] as? NSArray {
            for runModel in arrayRun {
                let model = runModel as! UTEModelRunData
                print("normal***time = \(String(describing: model.time)), hourStep = \(model.hourSteps),Total step = \(model.totalSteps) , distance = \(model.distances) ,calorie = \(model.calories)")
            }
        }
        
        if let arraySport = info[kUTEQuerySportWalkRunData] as? NSArray {
            for sportModel in arraySport {
                let model = sportModel as! UTEModelSportWalkRun
                print("sport***time = \(String(describing: model.time)),Total step = \(model.stepsTotal) , walkDistance = \(model.walkDistances) ,walkCalorie = \(model.walkCalories) ,runDistance = \(model.runDistances),runCalorie =\(model.runCalories)")
                
            }
            
            let uteData:[UTEModelSportWalkRun] = arraySport as! [UTEModelSportWalkRun]
            let stepData = uteData.compactMap { hrm -> QPSportWalk in
                return hrm.stepData()
            }
            
            modifySyncData(.steps)
            
            updateSportStep(datas: stepData)
            
//            syncType = HomeHealthType_Step
        }
        
        if let arraySleep = info[kUTEQuerySleepData] as? NSArray {
            for sleepModel in arraySleep {
                let model = sleepModel as! UTEModelSleepData
                print("***start=\(String(describing: model.startTime)),end=\(String(describing: model.endTime)),type=\(model.sleepType)")
                
            }
//            modifySyncData(.sleep)
        }
        
        if let arraySleepDayByDay = info[kUTEQuerySleepDataDayByDay] as? NSArray {
            var sleepDatas: [QPSleepDataDay] = []
            for array in arraySleepDayByDay {
                if let dayByDayArray = array as? [UTEModelSleepData] {
                    sleepDatas.append(QPSleepDataDay().sleepData(data: dayByDayArray))
//                    for sleepModel in dayByDayArray {
//                        let model = sleepModel as! UTEModelSleepData
//                        print("dayByday***start=\(String(describing: model.startTime)),end=\(String(describing: model.endTime)),type=\(model.sleepType)")
//                    }
                }
            }
            modifySyncData(.sleep)
            
            updateSleep(datas: sleepDatas)
            
//            syncType = HomeHealthType_Sleep
        }
        
        if let arrayHRM = info[kUTEQueryHRMData] as? NSArray {
            
            let uteData:[UTEModelHRMData] = arrayHRM as! [UTEModelHRMData]
            let hrmData = uteData.compactMap { hrm -> QPSmartHRMData in
                return hrm.hrmData()
            }
//            Database.defaulted.seven_insertOrReplace(objects: hrmData, on: QPSmartHRMData.Properties.all)
            QPSmartHRMData.dataInsert(datas: hrmData)
            
            modifySyncData(.HRM)
            
            updateHRMData(datas: hrmData)
            
//            syncType = HomeHealthType_HRM
        }
        
        if let array24HRM = info[kUTEQuery24HRMData] as? NSArray {
            
            let uteData:[UTEModelHRMData] = array24HRM as! [UTEModelHRMData]
            let hrmData = uteData.compactMap { hrm -> QPSmartHRMData in
                return hrm.hrmData()
            }
//            Database.defaulted.seven_insertOrReplace(objects: hrmData, on: QPSmartHRMData.Properties.all)
            QPSmartHRMData.dataInsert(datas: hrmData)
            
            modifySyncData(.HRM24)
            
            updateHRMData(datas: hrmData)
            
//            syncType = HomeHealthType_HRM
        }
        
        if let arrayBlood = info[kUTEQueryBloodData] as? NSArray {
            for bloodModel in arrayBlood {
                let model = bloodModel as! UTEModelBloodData
                self.bloodDetectingData(model: model)
            }
            
            let uteData:[UTEModelBloodData] = arrayBlood as! [UTEModelBloodData]
            let bloodData = uteData.compactMap { blood -> QPSmartBloodData in
                return blood.bloodData()
            }
//            print(hrmData)
//            Database.defaulted.seven_insertOrReplace(objects: bloodData, on: QPSmartBloodData.Properties.all)
            QPSmartBloodData.dataInsert(datas: bloodData)
            
            modifySyncData(.blood)
            
            updateBloodData(datas: bloodData)
            
//            syncType = HomeHealthType_Blood
        }
        
        if let arrayTem = info[kUTEQueryBodyTemperature] as? NSArray {
            let uteData:[UTEModelBodyTemperature] = arrayTem as! [UTEModelBodyTemperature]
            
            let temData = uteData.compactMap { tem -> QPSmartBodyTemperatureData in
                return tem.bodyTemperatureData()
            }
//            Database.defaulted.seven_insertOrReplace(objects: temData, on: QPSmartBodyTemperatureData.Properties.all)
            QPSmartBodyTemperatureData.dataInsert(datas: temData)
            
            modifySyncData()
            
            updateBodyTemperatureData(datas: temData)
            
//            syncType = HomeHealthType_Temperature
        }
        
//        if let type = syncType {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
//                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateWatchSyncData"), object: nil, userInfo: ["syncType":type.rawValue])
//            })
//        }
        
    }
    
    //同步完成后调用   syncType为空就是同步体温  error同步错误
    func modifySyncData(_ syncType: UTEDeviceDataType? = nil) {
        
        for (index,item) in syncData.enumerated() {
            
            if let syncType = syncType {
                if syncType == item.syncType {
                    syncData.remove(at: index)
                    break
                }
            } else if item.bodyTemperature {
                syncData.remove(at: index)
                break
            }
        }
    }
    
    func heartDetectingData(model: UTEModelHRMData) -> Void {
        
        print("***heartTime=\(String(describing: model.heartTime)) heartCoun=\(String(describing: model.heartCount)) heartType=\(model.heartType)")
        
    }
    
    func bloodDetectingData(model: UTEModelBloodData) -> Void {
        
        print("***time=\(String(describing: model.bloodTime)) bloodSystolic=\(String(describing: model.bloodSystolic)) bloodDiastolic=\(String(describing: model.bloodDiastolic)) type=\(model.bloodType)")
        
    }
    
    
    func showPassAlertView(str : NSString) -> Void {
        
        let alterVc = UIAlertController.init(title: str as String, message: nil, preferredStyle: UIAlertController.Style.alert)
        
        alterVc.addTextField { (txtName) in
            txtName.keyboardType = UIKeyboardType.numberPad
            txtName.placeholder = "请输入"
        }
        
        let window = UIApplication.shared.keyWindow
        let nav : UINavigationController = window?.rootViewController as! UINavigationController
        
        weak var weakSelf = self
        alterVc.addAction(UIAlertAction.init(title: "确定", style: UIAlertAction.Style.default, handler: { (okAction) in
            
            let txt = alterVc.textFields?.first
            weakSelf?.smartBandMgr.sendUTEPassword(txt!.text!, type: self.passwordType!)
            
        }))
        
        alterVc.addAction(UIAlertAction.init(title: "取消", style: UIAlertAction.Style.cancel, handler: { (cancelAction) in
            
        }))
        
        nav.present(alterVc, animated: true, completion: nil)
    }
    
    func onClickModifyPassword() -> Void {
        
        self.showPassAlertView(str: "请输入密码验证")
        self.passwordType = UTEPasswordType.confirm
        
    }
    
    var syncData:[QPBandSync] = [] {
        didSet {
            for item in syncData {
                if !item.success {
                    if let syncType = item.syncType {
                        self.bandDataSync(syncType)
                    } else if item.bodyTemperature {
//                        modifySyncData()
                        let time = try? Database.defaulted.getValue(on: QPSmartBodyTemperatureData.Properties.time.max(), fromTable: QPSmartBodyTemperatureData.tableName)
//                        syncData[4].syncing = true
                        if var time = time?.stringValue,time.count >= 16 {
                            time = time.replacingOccurrences(of: " ", with: "-").replacingOccurrences(of: ":", with: "-")
                            if time.count > 16 {
                                time = String.init(time.prefix(16))
                            }
                            smartBandMgr.syncBodyTemperature(time)
                        } else {
                            smartBandMgr.syncBodyTemperature("2021-06-01-00-00")
                        }
                    }
                    break
                }
            }
        }
    }
    
    func bandDataSync(_ syncType: UTEDeviceDataType) {
        
        if connectDevices()!.isHasDataStatus {
            onClickSyncDataCustom(syncType)
        } else {
            switch syncType {
            case .HRM,.HRM24:
//                syncData[0].syncing = true
                onClickUTEOption(option: UTEOption.syncAllHRMData.rawValue)
            case .blood:
//                syncData[1].syncing = true
                onClickUTEOption(option: UTEOption.syncAllBloodData.rawValue)
            case .sleep:
//                syncData[2].syncing = true
                onClickUTEOption(option: UTEOption.syncAllSleepData.rawValue)
            case .steps:
//                syncData[3].syncing = true
                onClickUTEOption(option: UTEOption.syncAllStepsData.rawValue)
            default:
                break
            }
        }
        
    }
    
    // MARK: - kUTESyncMethod
    func onClickUTEOption(option : NSInteger) -> Void {
        
        smartBandMgr.setUTEOption(UTEOption(rawValue: option)!)
        
    }
    
    func onClickSyncDataCustom(_ syncType: UTEDeviceDataType) -> Void {
        
        var time: FundamentalValue?
        switch syncType {
//        case .steps:
//            time = try? Database.defaulted.getValue(on: QPSmartHRMData.Properties.heartTime.max(), fromTable: QPSmartHRMData.tableName)
        case .sleep:
            time = try? Database.defaulted.getValue(on: QPSmartHRMData.Properties.heartTime.max(), fromTable: QPSmartHRMData.tableName)
        case .HRM:
            time = try? Database.defaulted.getValue(on: QPSmartHRMData.Properties.heartTime.max(), fromTable: QPSmartHRMData.tableName)
        case .HRM24:
            time = try? Database.defaulted.getValue(on: QPSmartHRMData.Properties.heartTime.max(), fromTable: QPSmartHRMData.tableName)
        case .blood:
            time = try? Database.defaulted.getValue(on: QPSmartBloodData.Properties.bloodTime.max(), fromTable: QPSmartBloodData.tableName)
        default:
            break
        }
        
        if var time =  time?.stringValue,time.count > 12 {
            time = time.replacingOccurrences(of: " ", with: "-").replacingOccurrences(of: ":", with: "-")
            if time.count > 16 {
                time = String.init(time.prefix(16))
            }
            smartBandMgr.syncDataCustomTime(time, type: syncType)
        } else {
            smartBandMgr.syncDataCustomTime("2021-06-01-00-00", type: syncType)
        }
//        orderBy: [(RecommendDraftRecord.Properties.create_time).asOrder(by: .descending)
        
    }
    
    
    func updateHRMData(datas: [QPSmartHRMData]) {
        
//        guard let hrms = datas.toJSONString() else {
//            return
//        }
//
//        let dic:[String:String] = ["heart_rate_list":hrms]
//
//        SEWebManager.uploadHeartRecord(dic) { (data) in
//
//        } fail: { (error) in
//
//        }
        
    }
    
    func updateBloodData(datas: [QPSmartBloodData]) {
//        guard let blood = datas.toJSONString() else {
//            return
//        }
        
//        let dic:[String:String] = ["pressure_list":blood]
        
//        SEWebManager.uploadBloodRecord(dic) { (data) in
//
//        } fail: { (error) in
//
//        }

    }
    
    
    func updateBodyTemperatureData(datas: [QPSmartBodyTemperatureData]) {
//        guard let bodyTem = datas.toJSONString() else {
//            return
//        }
//
//        let dic:[String:String] = ["temperature_list":bodyTem]
        
//        SEWebManager.uploadBodyTemperatureRecord(dic) { (data) in
//
//        } fail: { (error) in
//
//        }
    }
    
    func updateSportStep(datas: [QPSportWalk]) {
        
//        guard let steps = QPSportWalk.dataReload(datas: datas).toJSONString() else {
//            return
//        }
        
//        let dic:[String:String] = ["walk_list":steps]
        
//        SEWebManager.uploadSportStepsData(dic) { (data) in
//
//        } fail: { (error) in
//
//        }
    }
    
    
    func updateSleep(datas: [QPSleepDataDay]) {
        
//        for item in datas {
//            let sleepDic = item.toJSON()
//            SEWebManager.uploadSleepData(sleepDic) { (data) in
//
//            } fail: { (error) in
//
//            }
//        }
    }
}


extension UTEModelSportWalkRun {
    
    func stepData() -> QPSportWalk {
        let model = QPSportWalk()
        model.step_count = self.stepsTotal
        model.use_time = "60"
        model.calories = self.walkCalories
        model.kilometer = self.walkDistances
//        model.date  = NSDate.date(withTimeUTEYMDMString: self.time);//self.time
        
        return model
    }
    
}
