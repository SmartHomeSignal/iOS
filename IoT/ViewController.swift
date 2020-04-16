//
//  ViewController.swift
//  IoT
//
//  Created by Дамир Зарипов on 12.04.2020.
//  Copyright © 2020 itisIOSLab. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var signalingStatusLabel: UILabel!
    @IBOutlet weak var signalingButton: UIButton!
    var webSocketTask: URLSessionWebSocketTask!
    var statusSignaling: Bool!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let urlSession = URLSession(configuration: .default)
        webSocketTask = urlSession.webSocketTask(with: URL(string: "ws://45.15.253.128:8090/clients/signal")!)
        webSocketTask.resume()
        receiveMessage()
        signalingButton.layer.cornerRadius = 100
        signalingButton.layer.masksToBounds = true
    }
    
    func receiveMessage() {
      webSocketTask.receive { result in
        switch result {
        case .failure(let error):
          print("Error in receiving message: \(error)")
        case .success(let message):
          switch message {
          case .string(let text):
            if text == "true" {
                self.statusSignaling = true
            } else {
                self.statusSignaling = false
            }
            print("Received string: \(text)")
            DispatchQueue.main.async {
                self.apply(state: self.statusSignaling)
            }
          case .data(let data):
            print("Received data: \(data)")
          @unknown default:
            fatalError()
          }
          self.receiveMessage()
        }
      }
    }
    
    func sendOff() {
        let message = URLSessionWebSocketTask.Message.string("false")
        webSocketTask.send(message) { error in
          if let error = error {
            print("WebSocket couldn’t send message because: \(error)")
            }
        }
    }
    
    func sendOn() {
        let message = URLSessionWebSocketTask.Message.string("true")
        webSocketTask.send(message) { error in
          if let error = error {
            print("WebSocket couldn’t send message because: \(error)")
            }
        }
    }
    
    func apply(state: Bool) {
        if state {
            signalingButton.backgroundColor = UIColor.red
            signalingStatusLabel.text = "Сигнализация включена"
            signalingButton.setTitle("Выключить", for: .normal)
        } else {
            signalingButton.backgroundColor = UIColor.green
            signalingStatusLabel.text = "Сигнализация выключена"
            signalingButton.setTitle("Включить", for: .normal)
        }
    }
    
    @IBAction func signalingButtonPressed(_ sender: Any) {
        if statusSignaling {
            sendOff()
        } else {
            sendOn()
        }
        
        statusSignaling.toggle()
        self.apply(state: statusSignaling)
    }
}


