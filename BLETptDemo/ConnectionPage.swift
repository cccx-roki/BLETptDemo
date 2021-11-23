//
//  ConnectionPage.swift
//  BLETptDemo
//
//  Created by dete108 on 2021/10/22.
//  Copyright © 2021 dete108. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth
import MJRefresh

var tptNowNum:Int = 26

/**
 创建数据数组
 
 在方法中创建多个TptMessage对象作为数据源
 添加到数组中
 */
class TptMessage: NSObject {
    var RSSI: String
    var NAME: String
    var UUID: String
    var BP: CBPeripheral
    
    init(rssi: String, name: String?, uuid: String, peripheral: CBPeripheral) {
        self.RSSI = rssi
        self.NAME = name ?? "nil"
        self.UUID = uuid
        self.BP = peripheral
    }
}

var tptData = [TptMessage]()

class ConnectionPage: UIViewController{
    @IBOutlet weak var listTableView: UITableView!

    var centralManager: CBCentralManager?
    //顶部刷新；利用MJRefresh框架
    let header = MJRefreshNormalHeader()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //创建中央设备管理器，遵循代理
        centralManager = CBCentralManager.init(delegate: self, queue: nil)
        
//        listTableView.delegate = self
        listTableView.dataSource = self
        
        //下拉刷新相关设置
        header.setRefreshingTarget(self, refreshingAction: #selector(headerRefresh))
        self.listTableView.mj_header = header
        
        //每2秒刷新方法
        twoSLoadOnce()
    }
    
    ///顶部下拉刷新
    ///
    ///下拉tableview时触发，将数组清空、重新扫描、重载页面
    @objc func headerRefresh(){
        print("下拉刷新")
        sleep(2)
        print("准备开删")
        tptData.removeAll()
        print("删除完毕，开始扫描")
        self.centralManager?.scanForPeripherals(withServices: nil, options: nil)
        //正在计时
        Foundation.Timer.scheduledTimer(withTimeInterval: 10.0 ,repeats: false){ timer in
            self.centralManager?.stopScan()
            print("stop RefreshScan")
            //结束扫描
        }
        //停止刷新
        self.listTableView.mj_header?.endRefreshing()
    }
    /// 每隔2秒刷新页面
    ///
    /// 隔2秒钟进行一次数组去重，页面重载；同时将新扫到的同名设备的信号值更新
    func twoSLoadOnce(){
        Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { timer in
            print("重载")
            self.removeRepeat()
        }
    }
    
    func removeRepeat(){
        for index in (0..<tptData.count).reversed(){
            for item in (index+1..<tptData.count).reversed() {
                if tptData[item].UUID == tptData[index].UUID {
                    tptData[index].RSSI = tptData[item].RSSI
                    tptData.remove(at: item)
                }
            }
        }
        self.listTableView.reloadData()
    }
}

//遵守三个协议
extension ConnectionPage:CBCentralManagerDelegate,CBPeripheralDelegate,UITableViewDataSource{
    /** 先是TableView的绘制部分 */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tptData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = listTableView.dequeueReusableCell(withIdentifier: "listCell") as! EquipmentList //重用单元格，给其提供标识符; as! 后接CocoaTouchClass文件
        //根据行数，找到对应的索引，再将对应索引的值添加到行中
        let soyn = tptData[indexPath.row]
        cell.listImageView.image = UIImage(named: "link_circle_fill")
        cell.listLabel1.text = soyn.RSSI
        cell.listLabel2.text = "信号强度"
        cell.listLabel3.text = soyn.NAME
        cell.listLabel4.text = soyn.UUID
        cell.listView.layer.cornerRadius = cell.listView.frame.height / 2
        cell.listButton.layer.cornerRadius = cell.listButton.frame.height / 2
        
        //通过tag传参，未写入文档
        cell.listButton.tag = indexPath.row
        cell.listButton.addTarget(self, action: #selector(connectToPer(sender:)), for: .touchUpInside)
        
        return cell
    }
    
    /**再是中央设备对外围设备的处理 */
    
    //检测蓝牙状态，判断设备蓝牙是否开启
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("开始检测蓝牙状态")
            switch central.state {
            case .unknown:
                print("未知状态")
            case .resetting:
                print("检测到您的手机蓝牙重置")
            case .unsupported:
                print("检测到您的手机不支持蓝牙4.0")
            case .unauthorized:
                print("检测到您的手机蓝牙没有授权")
            case .poweredOff:
                print("您的手机蓝牙未开启")
            case .poweredOn:
                print("检测到您的手机蓝牙正常开启，可以扫描外围设备")
                firstScan()
//                central.scanForPeripherals(withServices: nil, options: nil)
                
            default:
                print("error")
            }
        }
    
    /**
     扫描到外设之后，就会回调下面方法，可以在方法中继续设置筛选条件
     central                       中央设备管理器
     peripheral                  外围设备
     advertisementData    设备信息
     RSSI                          信号强度，可以用以判断周边设备李中央设备的远近
     */
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String:Any], rssi RSSI: NSNumber) {
        //打印信息
        print("外设UUID-->\(peripheral.identifier.uuidString)")
        
        //将数据添加到ConnectionPage的列表tptData中
        let thisRSSI = RSSI.stringValue //将NSNumber转为String
        let thisName = peripheral.name
        let thisUUID = peripheral.identifier.uuidString
        let thisBP = peripheral
        
        let ble:TptMessage = TptMessage(rssi: thisRSSI, name: thisName, uuid: thisUUID, peripheral: thisBP)
        tptData.append(ble)
    }

    ///按钮点击事件
    ///
    ///通过修改tag值传入行数索引，再通过行数找到数组中的值，拿到uuid，通过uuid连接到正确的设备
    ///
    ///- NotG：在调用前先将tag值修改
    @objc func connectToPer(sender: UIButton){
        let index = sender.tag
        
        let BPWillConnect = tptData[index].BP
        
        print("\(index)")
        print("\(tptData[index].BP)")
        self.centralManager?.connect(BPWillConnect, options: nil)
        print("已进行连接")
    }
    
    /// 加载初始页面
    ///
    ///进入eqr界面后，开始扫描周围外设，10秒之后停止扫描
    func firstScan(){
        print("start scan!")
        self.centralManager?.scanForPeripherals(withServices: nil, options: nil)
        //10秒钟之后停止扫描
//        Foundation.Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false){ timer in
//                self.centralManager?.stopScan()
//                print("stop scan")
//            }
    }
    
    //连接设备成功
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        central.stopScan()
        print("连接成功，停止扫描")
        peripheral.delegate = self
        //开始寻找所有Services
        peripheral.discoverServices(nil)
        
        print("外设的所有服务--> \(String(describing: peripheral.services))")
    }
    //连接设备失败，并打印错误信息
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("连接失败\(error.debugDescription)")
    }
    //断开连接
}
