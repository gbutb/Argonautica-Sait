//
//  SpeechController.swift
//  Argonautica-Sait
//
//  Created by Giorgi Butbaia on 11/13/20.
//  Copyright © 2020 Argonautica. All rights reserved.
//

import Foundation
import Speech

protocol SpeechControllerDelegate {
    func start()
    func stop()
}

class SpeechController {
    var delegate: SpeechControllerDelegate?

    // Audio handlers
    let audioEngine = AVAudioEngine()
    let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-GB"))
    let request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
    
    init() {
        // Initialize speech recognizer
        SFSpeechRecognizer.requestAuthorization {
            [unowned self] (authStatus) in
                switch authStatus {
                    case .authorized:
                        self.startRecognition()
                    case .denied:
                        print("Speech recognition authorization denied")
                    case .restricted:
                        print("Not available on this device")
                    case .notDetermined:
                        print("Not determined")
                    default:
                        print("Unable to authorize.")
                }
        }
    }

    private func startRecognition() {
        print(SFSpeechRecognizer.supportedLocales())
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)

        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) {
            [unowned self] (buffer, _) in self.request.append(buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("Error")
        }
        
        recognitionTask = speechRecognizer?.recognitionTask(with: request) {
            [unowned self] (result, _) in
            if let transcription = result?.bestTranscription {
                if transcription.formattedString.lowercased().contains("start") {
                    self.delegate?.start()
                }
            }
        }
    }
}
