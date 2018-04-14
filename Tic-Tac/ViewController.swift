//
//  ViewController.swift
//  Tic-Tac
//
//  Created by Armenian Code Academy on 4/12/18.
//  Copyright © 2018 Armenian Code Academy. All rights reserved.
//

import UIKit
import AVFoundation

extension UIView {
    func rotate(angle: CGFloat) {
        let radians = angle / 180.0 * CGFloat(Double.pi)
        let rotation = self.transform.rotated(by: radians)
        self.transform = rotation
    }
    
    func setAnchorPoint(anchorPoint: CGPoint) {
        
        var newPoint = CGPoint(x: self.bounds.size.width * anchorPoint.x, y: self.bounds.size.height * anchorPoint.y)
        var oldPoint = CGPoint(x: self.bounds.size.width * self.layer.anchorPoint.x, y: self.bounds.size.height * self.layer.anchorPoint.y)
        
        newPoint = newPoint.applying(self.transform)
        oldPoint = oldPoint.applying(self.transform)
        
        var position : CGPoint = self.layer.position
        
        position.x -= oldPoint.x
        position.x += newPoint.x;
        
        position.y -= oldPoint.y;
        position.y += newPoint.y;
        
        self.layer.position = position;
        self.layer.anchorPoint = anchorPoint;
    }
    
}

class ViewController: UIViewController, AVAudioPlayerDelegate {
    
    @IBOutlet weak var stackView: UIStackView!
    
    var BPM: Double = 110
    var thirdHelperFlag = true
    var secondHelperFlag = true
    var helperFlag = true
    var rectangle: UIView!
    let trapezium = CAShapeLayer()
    var pauseResumeButton: UIButton!
    var speedButton: UIButton!
    var player1 = AVAudioPlayer()
    var player2 = AVAudioPlayer()
    var count = 0
    let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
    var blurEffectView: UIVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stackView.alpha = 0
        drawObjects()
        do {
            let audioPlayer1 = Bundle.main.path(forResource: "Metronome", ofType: "wav")
            let audioPlayer2 = Bundle.main.path(forResource: "MetronomeUp", ofType: "wav")
            try player1 = AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: audioPlayer1!) as URL)
            try player2 = AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: audioPlayer2!) as URL)
        } catch {
            
        }
    }

    @IBAction func tap(_ sender: Any) {
        if let blrView = blurEffectView {
            stackView.alpha = 0
            blrView.removeFromSuperview()
        }
    }
    
    @IBAction func speedChosen(_ sender: UIButton) {
        BPM = Double(sender.tag)
        if sender.tag == 70 {
            speedButton.setTitle("70", for: .normal)
        }
        if sender.tag == 90 {
            speedButton.setTitle("90", for: .normal)
        }
        if sender.tag == 110 {
            speedButton.setTitle("110", for: .normal)
        }
        if sender.tag == 130 {
            speedButton.setTitle("130", for: .normal)
        }
        stackView.alpha = 0
        blurEffectView.removeFromSuperview()
    }
    
     func pressedPlay() {
        if self.thirdHelperFlag {
            UIView.animate(withDuration: 60/BPM, animations: {
                if self.secondHelperFlag == true {
                    self.rectangle.rotate(angle: 90)
                } else {
                    self.rectangle.rotate(angle: -90)
                }
            }) { (finished) in
                if self.count == 3 {
                    self.player1.play()
                    self.count = 0
                } else {
                    self.player2.play()
                    self.count += 1
                }
                self.secondHelperFlag = !self.secondHelperFlag
                self.pressedPlay()
            }
        }
    }
    
    @objc func pressedButton() {
        if helperFlag {
            thirdHelperFlag = true
            pauseResumeButton.setImage(UIImage(named: "pause"), for: .normal)
            helperFlag = false
            pressedPlay()
        } else {
            pauseResumeButton.setImage(UIImage(named: "resume"), for: .normal)
            helperFlag = true
            thirdHelperFlag = false
        }
    }
    
    @objc func speedButtonPressed() {
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.isUserInteractionEnabled = true
        view.addSubview(blurEffectView)
        view.addSubview(stackView)
        stackView.alpha = 1
    }
    
    func drawObjects() {
        let screenSize = UIScreen.main.bounds
        let width = screenSize.width
        let height = screenSize.height
        
        let trapeziumPath = UIBezierPath()
        trapeziumPath.move(to: CGPoint(x: width * 1/4, y: height * 1/8))
        trapeziumPath.addLine(to: CGPoint(x: width * 3/4, y: height * 1/8))
        trapeziumPath.addLine(to: CGPoint(x: width * 7/8, y: height * 3/8))
        trapeziumPath.addLine(to: CGPoint(x: width * 1/8, y: height * 3/8))
        trapeziumPath.close()
        trapezium.path = trapeziumPath.cgPath
        trapezium.fillColor = UIColor.orange.cgColor
        self.view.layer.addSublayer(trapezium)

        let rectFrame = CGRect(x: width * 1/16, y: height * 3/8 - 5, width: width * 7/16, height: 5)
        rectangle = UIView(frame: rectFrame)
        rectangle.backgroundColor = UIColor.black
        self.rectangle.setAnchorPoint(anchorPoint: CGPoint(x: 1, y: 1))
        rectangle.rotate(angle: 45.0)
        self.view.addSubview(rectangle)
        
        let buttonRectFrame = CGRect(x: width * 3/8, y: height * 5/8, width: width * 1/4, height: width * 1/4)
        pauseResumeButton = UIButton(frame: buttonRectFrame)
        pauseResumeButton.setImage(UIImage(named: "resume"), for: .normal)
        pauseResumeButton.addTarget(self, action: #selector(pressedButton), for: .touchUpInside)
        self.view.addSubview(pauseResumeButton)
        
        let buttonRect = CGRect(x: width * 1/2 - width * 3/16 , y: height * 13/16, width: width * 3/8, height: height * 1/16)
        speedButton = UIButton(frame: buttonRect)
        speedButton.setTitle("110", for: .normal)
        speedButton.addTarget(self, action: #selector(speedButtonPressed), for: .touchUpInside)
        speedButton.backgroundColor = UIColor.init(red: 105/255, green: 55/255, blue: 221/255, alpha: 1.0)
        speedButton.layer.cornerRadius = 0.02 * speedButton.bounds.size.width
        speedButton.setTitleColor(UIColor.white, for: .normal)
        self.view.addSubview(speedButton)
    }
}

