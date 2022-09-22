//
//  playButtonController.swift
//  studyBuddy
//
//  Created by Hayden Kreuter on 3/4/22.
//  Copyright © 2022 Hayden Kreuter. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class PlayButtonController: NSObject, AVAudioPlayerDelegate {
    var audioPlayer: AVAudioPlayer!
    var button: UIButton?
    var barButton: UIBarButtonItem?
    var timer: Timer?
    let synthesizer = AVSpeechSynthesizer()
    
    init(audioPlayer: AVAudioPlayer!, button: UIButton!) {
        self.audioPlayer = audioPlayer
        self.button = button
    }
    
    init(audioPlayer: AVAudioPlayer!, barButton: UIBarButtonItem!) {
        self.audioPlayer = audioPlayer
        self.barButton = barButton
        barButton.width = 50
        
    }

    

    func play(path: String, word: String) {
        if audioPlayer != nil && audioPlayer.isPlaying {
            audioPlayer.stop()
            setButtonImage(imageName: "playButton")
        } else {
            if path == "0" { // automatic speach is on so play automatic speach based on language settings
                autoSpeakWord(word)
            } else {
                do {
                    let fileName = getDirectory().appendingPathComponent(path)
                    audioPlayer = try AVAudioPlayer(contentsOf : fileName)
                    audioPlayer.delegate = self
                    setButtonImage(imageName: "stopButton")
                    audioPlayer.play()
                } catch { // error playing audio file fall back on auto speak
                    autoSpeakWord(word)
                }
            }
        }
    }
    
    func autoSpeakWord(_ word: String) {
        setButtonImage(imageName: "stopButton")
        synthesizer.stopSpeaking(at: .immediate)
        let utterance = AVSpeechUtterance(string: "\(word.trimmingCharacters(in: .whitespaces))")
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
     
        utterance.rate = 0.4
    
        synthesizer.speak(utterance)
        timer = Timer.scheduledTimer(timeInterval: 2,
                                     target: self,
                                     selector: #selector(eventWith(timer:)),
                                     userInfo: [],
                                     repeats: false)
    }
    
    @objc func eventWith(timer: Timer!) {
        setButtonImage(imageName: "playButton")
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        setButtonImage(imageName: "playButton")
    }
        
        func getDirectory() -> URL { // gets path to directory  to save audio recordings
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let documentDirectory = paths[0]
            return documentDirectory
        }
    
    
    func setButtonImage(imageName: String) {
        if let button = button {
            button.setImage(UIImage(named: imageName), for: .normal)
        } else if let barButton = barButton {
            barButton.image = UIImage(named: imageName)?.withRenderingMode(.alwaysOriginal)
        }
        
    }
}

