//
//  AudioPlaye.swift
//  QPSmartJackets
//
//  Created by qipai on 2021/4/8.
//  Copyright © 2021 MinewTech. All rights reserved.
//

import Foundation
import UIKit
import AVKit

enum MusicPlayType {
    case musicTypeTracker   //iphone呼叫防丢器
    case musicTypeIphone    //防丢器呼叫iphone
    case musicTypeBackground    //进到后台
}

class UTEAudioPlayer: NSObject {
    
    static let shareInstance = UTEAudioPlayer()
    
//    private var avplayer: AVPlayer!
//    private var playerItem: AVPlayerItem!
    var is_background = false {
        didSet {
            is_background ? backgroundPlay() : stop()
            
        }
    } //是否进入到后台
    
    private var audioPlayer: AVAudioPlayer?
    private var last_type: MusicPlayType? //记录上一次播放的状态 用来区分是防丢器呼叫iPhone还是iPhone呼叫防丢器
    
    override init() {
        super.init()
//        avplayer = AVPlayer()
//        self.resetPlayer()
    }
    
    //停止
    func stop() {
        audioPlayer?.delegate = nil
        audioPlayer?.stop()
    }
    
    //播放
    private func play()->Bool {
//        if audioPlayer?.isPlaying ?? false && last_type == .musicTypeBackground {
////            audioPlayer.pause()
//
//            return false
//        } else {
            audioPlayer?.play()
            return true
//        }
    }
    
    //暂停
    func pause() {
        audioPlayer?.pause()
    }
    
    //iphone呼叫防丢器
    func callsTracker() {
        resetPlayer()
        audioPlayer?.numberOfLoops = 2
    }
    
    //防丢器呼叫iphone
    func callsIphone() {
        resetPlayer(type: .musicTypeIphone)
        audioPlayer?.numberOfLoops = 0
    }
    
    func resetPlayer(type:MusicPlayType = .musicTypeTracker) {
//        guard last_type == nil || last_type != type else {
//            return
//        }
        last_type = type
        var music_name:String
        switch type {
        case .musicTypeTracker:
            music_name = "find_phone_m.wav"
        case .musicTypeIphone:
            music_name = "seachPhoneRing.wav"
        case .musicTypeBackground:
            music_name = "empty_music.m4r"
        }
        guard let path = Bundle.main.path(forResource: music_name, ofType: nil) else {
            return
        }
        stop()
        do {
            try audioPlayer = AVAudioPlayer.init(contentsOf: URL(fileURLWithPath: path))
            audioPlayer?.delegate = self
            _ = play()
        } catch {
            audioPlayer = nil
        }
    }
    
    //后台播放无声音乐 循环播放
    func backgroundPlay() {
        resetPlayer(type: .musicTypeBackground)
        audioPlayer?.numberOfLoops = -1
    }
    
    deinit {
        audioPlayer = nil
    }
}


extension UTEAudioPlayer: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        guard flag && is_background && last_type != .musicTypeBackground else {
            return
        }
        backgroundPlay()
    }
}
