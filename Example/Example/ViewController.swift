//
//  ViewController.swift
//  OMMeter
//
//  Created by Jorge Ouahbi on 7/11/16.
//  Copyright © 2016 Jorge Ouahbi. All rights reserved.
//

import UIKit
import AVFoundation

// http://web-tech.ga-usa.com/2012/05/creating-a-custom-hot-to-cold-temperature-color-gradient-for-use-with-rrdtool/

let gradientColorsHotToCold = Array([
    UIColor(hex: "#FF0000"),
    UIColor(hex: "#FF0a00"),
    UIColor(hex: "#FF1400"),
    UIColor(hex: "#FF1e00"),
    UIColor(hex: "#FF2800"),
    UIColor(hex: "#FF3200"),
    UIColor(hex: "#FF3c00"),
    UIColor(hex: "#FF4600"),
    UIColor(hex: "#FF5000"),
    UIColor(hex: "#FF5a00"),
    UIColor(hex: "#FF6400"),
    UIColor(hex: "#FF6e00"),
    UIColor(hex: "#FF7800"),
    UIColor(hex: "#FF8200"),
    UIColor(hex: "#FF8c00"),
    UIColor(hex: "#FF9600"),
    UIColor(hex: "#FFa000"),
    UIColor(hex: "#FFaa00"),
    UIColor(hex: "#FFb400"),
    UIColor(hex: "#FFbe00"),
    UIColor(hex: "#FFc800"),
    UIColor(hex: "#FFd200"),
    UIColor(hex: "#FFdc00"),
    UIColor(hex: "#FFe600"),
    UIColor(hex: "#FFf000"),
    UIColor(hex: "#FFfa00"),
    UIColor(hex: "#fdff00"),
    UIColor(hex: "#d7ff00"),
    UIColor(hex: "#b0ff00"),
    UIColor(hex: "#8aff00"),
    UIColor(hex: "#65ff00"),
    UIColor(hex: "#3eff00"),
    UIColor(hex: "#17ff00"),
    UIColor(hex: "#00ff10"),
    UIColor(hex: "#00ff36"),
    UIColor(hex: "#00ff5c"),
    UIColor(hex: "#00ff83"),
    UIColor(hex: "#00ffa8"),
    UIColor(hex: "#00ffd0"),
    UIColor(hex: "#00fff4"),
    UIColor(hex: "#00e4ff"),
    UIColor(hex: "#00d4ff"),
    UIColor(hex: "#00c4ff"),
    UIColor(hex: "#00b4ff"),
    UIColor(hex: "#00a4ff"),
    UIColor(hex: "#0094ff"),
    UIColor(hex: "#0084ff"),
    UIColor(hex: "#0074ff"),
    UIColor(hex: "#0064ff"),
    UIColor(hex: "#0054ff"),
    UIColor(hex: "#0044ff"),
    UIColor(hex: "#0032ff"),
    UIColor(hex: "#0022ff"),
    UIColor(hex: "#0012ff"),
    UIColor(hex: "#0002ff"),
    UIColor(hex: "#0000ff"),
    UIColor(hex: "#0100ff"),
    UIColor(hex: "#0200ff"),
    UIColor(hex: "#0300ff"),
    UIColor(hex: "#0400ff"),
    UIColor(hex: "#0500ff")].reversed());


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
        
        
        playSound(name: "test_-20dBs",withExtension: "mp3")
        
        let dpLink = CADisplayLink( target:self, selector:#selector(updateMeters));
        dpLink.add(to: RunLoop.current,forMode:RunLoopMode.commonModes);
    }
}

