//
//  ViewController.swift
//  OMMeter
//
//  Created by Jorge Ouahbi on 7/11/16.
//  Copyright © 2016 Jorge Ouahbi. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var audioMeterSteroR:OMMeter!
    @IBOutlet weak var audioMeterSteroL:OMMeter!
    var averagePower:Bool = true
    var player: AVAudioPlayer = AVAudioPlayer()
    
    func playSound(name:String,withExtension:String = "mp3", numberOfLoops:Int = -1, meteringEnabled:Bool = true) {
        guard let url = Bundle.main.url(forResource: name, withExtension: withExtension) else {
            print("url not found")
            return
        }
        do {
            /// this codes for making this app ready to takeover the device audio
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            /// change fileTypeHint according to the type of your audio file (you can omit this)
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            player.isMeteringEnabled = meteringEnabled
            player.numberOfLoops     = numberOfLoops
            // no need for prepareToPlay because prepareToPlay is happen automatically when calling play()
            player.play()
        } catch let error as NSError {
            print("error: \(error.localizedDescription)")
        }
    }
    
    
    @objc func updateMeters() {
        if (player.isPlaying ) {
            player.updateMeters()
            var power = 0.0;
            var peak  = 0.0;
            for i in 0 ..< player.numberOfChannels {
                power = Double(player.averagePower(forChannel: i))
                peak  = Double(player.peakPower(forChannel: i))
                
                if averagePower {
                    if i == 0 {
                        audioMeterSteroR.value = CGFloat(power)
                    } else {
                        audioMeterSteroL.value = CGFloat(power)
                    }
                } else {
                    if i == 0 {
                        audioMeterSteroR.value = CGFloat(peak)
                    } else {
                        audioMeterSteroL.value = CGFloat(peak)
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        audioMeterSteroR.minimumValue = -80
        audioMeterSteroR.maximumValue = 20
        audioMeterSteroR.gradientColors = [UIColor.green,UIColor.yellow,UIColor.orange,UIColor.red]
        
        
        audioMeterSteroL.minimumValue = -80
        audioMeterSteroL.maximumValue = 20
        audioMeterSteroL.gradientColors = [UIColor.green,UIColor.yellow,UIColor.orange,UIColor.red]
        
        
        playSound(name: "atmosbasement",withExtension: "mp3")
        
        let dpLink = CADisplayLink( target:self, selector:#selector(updateMeters));
        dpLink.add(to: RunLoop.current,forMode:RunLoopMode.commonModes);
    }
}

