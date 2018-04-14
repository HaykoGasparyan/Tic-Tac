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
    //Rotates view by "angle" parameter degree
    func rotate(angle: CGFloat) {
        let radians = angle / 180.0 * CGFloat(Double.pi)
        let rotation = self.transform.rotated(by: radians)
        self.transform = rotation
    }
    
    //Sets anchor point for rotation to any point
    //Got from google
    //anchorPoint - coordinate of point, which wanted to be set as anchor point (0-1).
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
    
    var BPM: Double = 110       //BPM -> Beats per minute
    var toRight = true
    var isPuased = true
    var isRunning = false
    var rectangle: UIView!
    let trapezium = CAShapeLayer()
    var pauseResumeButton: UIButton!
    var speedButton: UIButton!
    var tac = AVAudioPlayer()
    var tic = AVAudioPlayer()
    var ticCount = 0
    let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
    var blurEffectView: UIVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stackView.alpha = 0
        drawObjects()
        do {
            let tacAudioPlayer = Bundle.main.path(forResource: "Metronome", ofType: "wav")
            let ticAudioPlayer = Bundle.main.path(forResource: "MetronomeUp", ofType: "wav")
            try tac = AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: tacAudioPlayer!) as URL)
            try tic = AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: ticAudioPlayer!) as URL)
            tac.prepareToPlay()
            tic.prepareToPlay()
        } catch {
            
        }
    }

    @IBAction func tap(_ sender: Any) {
        if let blrView = blurEffectView {
            stackView.alpha = 0
            blrView.removeFromSuperview()
        }
    }
    
    @IBAction func chooseSpeed(_ sender: UIButton) {
        let tag = sender.tag
        BPM = Double(sender.tag)
        if tag == 70 {
            speedButton.setTitle("70", for: .normal)
        }
        if tag == 90 {
            speedButton.setTitle("90", for: .normal)
        }
        if tag == 110 {
            speedButton.setTitle("110", for: .normal)
        }
        if tag == 130 {
            speedButton.setTitle("130", for: .normal)
        }
        stackView.alpha = 0
        blurEffectView.removeFromSuperview()
    }
    
    //Plays animation
    //This function is also called in completion of animation(recursia) to animate to the oppossite side
    func playAnimation() {
        if !self.isPuased {
            UIView.animate(withDuration: 60/BPM, animations: {
                self.isRunning = true
                if self.toRight == true {
                    self.rectangle.rotate(angle: 90)
                } else {
                    self.rectangle.rotate(angle: -90)
                }
            }) { (finished) in
                if self.ticCount == 3 {
                    self.tac.play()
                    self.ticCount = 0
                } else {
                    self.tic.play()
                    self.ticCount += 1
                }
                self.toRight = !self.toRight
                if self.isPuased {
                    self.isRunning = false
                }
                self.playAnimation()
            }
        }
    }
    
    //This method is called when pausePlayButtonPressed.
    @objc func pausePlayButtonPressed() {
        if isPuased {
            pauseResumeButton.setImage(UIImage(named: "pause"), for: .normal)
            isPuased = false
            if !isRunning {
                playAnimation()
            }
        } else {
            pauseResumeButton.setImage(UIImage(named: "resume"), for: .normal)
            isPuased = true
        }
    }
    
    //adds blure effect and stackView comes visible
    @objc func speedButtonPressed() {
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.isUserInteractionEnabled = true
        view.addSubview(blurEffectView)
        view.addSubview(stackView)
        stackView.alpha = 1
    }
    
    //drawing trapezium,arrow for tic-tac and two buttons.
    func drawObjects() {
        let screenSize = UIScreen.main.bounds
        let width = screenSize.width
        let height = screenSize.height
        
        let trapeziumPath = UIBezierPath()      //Researched in google (UIBezierPath())
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
        self.rectangle.setAnchorPoint(anchorPoint: CGPoint(x: 1, y: 0.5))
        rectangle.rotate(angle: 45.0)
        self.view.addSubview(rectangle)
        
        let buttonRectFrame = CGRect(x: width * 3/8, y: height * 5/8, width: width * 1/4, height: width * 1/4)
        pauseResumeButton = UIButton(frame: buttonRectFrame)
        pauseResumeButton.setImage(UIImage(named: "resume"), for: .normal)
        pauseResumeButton.addTarget(self, action: #selector(pausePlayButtonPressed), for: .touchUpInside)
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

