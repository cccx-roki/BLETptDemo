//
//  ViewController.swift
//  BLETptDemo
//
//  Created by dete108 on 2021/9/27.
//  Copyright © 2021 dete108. All rights reserved.
//

import UIKit
import Foundation


class ViewController: UIViewController {
        
    let gradientLayer = MyGradientLayer()
    let arcLayer = MyArcLayer()
    let circleLayer = MyCircleLayer()

    override func viewDidLoad() {//view创建但还没有显示在屏幕上
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //初始化界面
        makeUI()
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            
            self.makeUpdate()
            print(">>> Countdown Number: \(tptNowNum)")
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let maxWidth = UIScreen.main.bounds.width
        let maxHeight = UIScreen.main.bounds.height
        
        gradientLayer.frame = CGRect(x: 0, y: 0, width: maxWidth, height: maxHeight)
        arcLayer.frame = CGRect(x: 0, y: 0, width: maxWidth, height: maxHeight)
        circleLayer.frame = CGRect(x: 0, y: 0, width: maxWidth, height: maxHeight)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        gradientLayer.setNeedsDisplay()
        circleLayer.setNeedsDisplay()
        arcLayer.setNeedsDisplay()
    }

    ///绘制三角形
    ///
    /// 首先在页面上显示一个三角形
    /// 根据传入温度值进行旋转
    /// 最多只能旋转到220℃的角度
    /// - number ：传入温度值
    ///
    /// - NotG：传入一个Int类型的参数
    func buildTriangle(number: Int) {
        let maxWidth = UIScreen.main.bounds.width
        let maxHeight = UIScreen.main.bounds.height
        
        //绘制三角形
        let trianglePath = UIBezierPath()
        var point = CGPoint(x: 0, y: maxWidth*0.3)
        trianglePath.move(to: point)
        point = CGPoint(x: maxWidth*0.14, y: maxWidth*0.3)
        trianglePath.addLine(to: point)
        point = CGPoint(x: maxWidth*0.07, y: 0)
        trianglePath.addLine(to: point)
        trianglePath.close()
        //创建图层
        let triangleLayer = CAShapeLayer()
        //设置三角形路径所在的父控件大小，设置为与三角形等高等宽
        view.layer.insertSublayer(triangleLayer, at: 2)
        triangleLayer.frame = CGRect(x: 0, y: 0, width: maxWidth*0.14, height: maxWidth*0.3)
        triangleLayer.path = trianglePath.cgPath
        triangleLayer.fillColor = UIColor(red: 180/255, green: 54/255, blue: 29/255, alpha: 1).cgColor
        //设置锚点，将三角形的中心位置放到指定的屏幕中心
        triangleLayer.position = CGPoint(x: maxWidth/2, y: maxHeight/2)
        triangleLayer.anchorPoint = CGPoint(x: 0.5, y: 1)
        
        /*
         *设置旋转角度，以y轴向上为0º
         *-135º为0℃
         *135º为220℃
         *温度每变化1℃，角度往前或往后增减270/220(约1.225)º
         */
        
        //将温度做个限制，最高只达220摄氏度
        if number > 220 {
            let angle = (round(Double(220) * (270/220)) + -135) / 360
            triangleLayer.transform = CATransform3DMakeRotation(CGFloat(angle) * CGFloat.pi * 2, 0, 0, 1)
        }else{
            let angle = (round(Double(number) * (270/220)) + -135) / 360
            
            triangleLayer.transform = CATransform3DMakeRotation(CGFloat(angle) * CGFloat.pi * 2, 0, 0, 1)
        }
    }
    
    ///绘制文字
    ///
    ///根据传入的温度值，在页面上显示不同的CATextLayer
    /// - number ：传入温度值
    ///
    /// - NotG：传入一个Int类型的参数
    func buildText(number: Int) {
        let tpt = number
        let maxWidth = UIScreen.main.bounds.width
        let maxHeight = UIScreen.main.bounds.height
        let text1 = CATextLayer()
        let text2 = CATextLayer()
        let text3 = CATextLayer()
        
        //固定文本text1
        text1.string = "当前温度"
        text1.frame = CGRect(x: maxWidth/2 - maxWidth*0.12, y: maxHeight/2 + maxWidth*0.17, width: maxWidth*0.24, height: maxWidth*0.07)
        text1.foregroundColor = UIColor(red: 180/255, green: 54/255, blue: 29/255, alpha: 1).cgColor
        text1.fontSize = maxWidth*0.05
        text1.alignmentMode = .center
        text1.contentsScale = UIScreen.main.scale
        view.layer.insertSublayer(text1, at: 4)
        //实时温度text2
        if tpt >= 220 {
            text2.string = "220℃"
        }else{
            text2.string = "\(tpt)℃"
        }        
        text2.frame = CGRect(x: maxWidth/2 - maxWidth*0.18, y: maxHeight/2 + maxWidth*0.25, width: maxWidth*0.36, height: maxWidth*0.15)
        text2.foregroundColor = UIColor(red: 180/255, green: 54/255, blue: 29/255, alpha: 1).cgColor
        text2.font = UIFont.systemFont(ofSize: maxWidth*0.15, weight: UIFont.Weight.bold)
        text2.alignmentMode = .center
        text2.contentsScale = UIScreen.main.scale
        view.layer.insertSublayer(text2, at: 5)
        
        //警告文本text3
        if tpt >= 220 {
            text3.string = "已经达到极限啦!"
            text3.frame = CGRect(x: maxWidth/2 - maxWidth * 0.2, y: maxHeight * 0.1, width: maxWidth * 0.4, height: maxWidth * 0.07)
            text3.foregroundColor = UIColor(red: 210/255, green: 55/255, blue:35/255,alpha: 1).cgColor
            text3.backgroundColor = UIColor.white.cgColor
            text3.fontSize = maxWidth*0.05
            text3.alignmentMode = .center
            text3.contentsScale = UIScreen.main.scale
            view.layer.insertSublayer(text3, at: 6)
        }
    }
    
    func makeGradient(){
        /* 渐变背景图层*/
        view.layer.insertSublayer(gradientLayer, at: 0)
        gradientLayer.contentsScale = UIScreen.main.scale
    }
    func makeArc(){
        /* 圆弧图层*/
        view.layer.insertSublayer(arcLayer, at: 1)
        arcLayer.contentsScale = UIScreen.main.scale
    }
    func makeCircle(){
        /* 圆形图层*/
        view.layer.insertSublayer(circleLayer, at: 3)
        circleLayer.contentsScale = UIScreen.main.scale
    }
    func makeUI(){
        makeGradient()
        makeArc()
        buildTriangle(number: tptNowNum)
        makeCircle()
        buildText(number: tptNowNum)
    }
    func makeUpdate(){
        /*
         *每次更新之前清空图层，再更新图层
         *温度小于220，每次更新只删2和5
         *温度大于等于220，每次删除256
         * 搞不定，一气之下全删除
         */
        if tptNowNum >= 220 {
            self.view.layer.sublayers?.removeAll()

            self.makeGradient()
            self.makeArc()
            self.buildTriangle(number: tptNowNum)
            self.makeCircle()
            self.buildText(number: tptNowNum)
            
            tptNowNum -= 10
        }else{
            self.view.layer.sublayers?.removeAll()
            
            self.makeGradient()
            self.makeArc()
            self.buildTriangle(number: tptNowNum)
            self.makeCircle()
            self.buildText(number: tptNowNum)
            
            tptNowNum += 10
        }
    }
    
}

/*
 *绘制覆盖屏幕的渐变矩形图层
 */
class MyGradientLayer: CAGradientLayer {
    override func draw(in ctx: CGContext) {
        /* 渐变背景 */
        //定义渐变的颜色（从252,186,129到252,186,129）
        let topColor = UIColor(red: 180/255, green: 54/255, blue: 29/255, alpha: 1).cgColor
        let bottomColor = UIColor(red: 252/255, green: 186/255, blue: 129/255, alpha: 1).cgColor
        self.frame = bounds
        self.colors = [topColor,bottomColor]
        self.startPoint = CGPoint(x: 0, y: 0)
        self.endPoint = CGPoint(x: 0, y: 1)
    }
}

/*
 *绘制白色圆弧图层
 */
class MyArcLayer: CALayer {
    override func draw(in ctx: CGContext) {
        let maxWidth = UIScreen.main.bounds.width
        let maxHeight = UIScreen.main.bounds.height
        let center = CGPoint(x: maxWidth*0.5, y: maxHeight*0.5)
        let radius = maxWidth*0.3
        let lineWidth = maxWidth*0.1
        
        //绘制圆弧
        ctx.setStrokeColor(UIColor.white.cgColor)
        ctx.setLineWidth(lineWidth)
        ctx.addArc(center: center, radius: radius, startAngle: 45/360 * CGFloat.pi * 2, endAngle: 135/360 * CGFloat.pi * 2, clockwise: true)
        ctx.strokePath()
    }
}

/*
 *绘制两个圆圈的图层
 */
class MyCircleLayer: CALayer {
    override func draw(in ctx: CGContext) {
        let maxWidth = UIScreen.main.bounds.width
        let maxHeight = UIScreen.main.bounds.height
        let center = CGPoint(x: maxWidth*0.5, y: maxHeight*0.5)
        let radiusOne = maxWidth*0.1
        let radiusTwo = maxWidth*0.07
        
        //绘制中心的两个圆
        //圆一 下层 鹿皮鞋色
        ctx.setFillColor(UIColor(red: 255/255, green: 228/255, blue: 181/255, alpha: 1).cgColor)
        ctx.addArc(center: center, radius: radiusOne, startAngle: 0 * CGFloat.pi * 2, endAngle: 1 * CGFloat.pi * 2, clockwise: true)
        ctx.fillPath()
        
        //圆二 上层 湛蓝色
        ctx.setFillColor(UIColor(red: 30/255, green: 144/255, blue: 255/255, alpha: 1).cgColor)
        ctx.addArc(center: center, radius: radiusTwo, startAngle: 0 * CGFloat.pi * 2, endAngle: 1 * CGFloat.pi * 2, clockwise: true)
        
        ctx.fillPath()
        }
}

