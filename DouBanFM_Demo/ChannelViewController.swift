//
//  ChannelViewController.swift
//  DouBanFM_Demo
//
//  Created by 游义男 on 15/7/31.
//  Copyright (c) 2015年 游义男. All rights reserved.
//

import UIKit

protocol ChannelProtocol{
    //回调方法，将频道ID 传到代理中
    func onChangeChannel(channel_id:String)
}

class ChannelViewController: UIViewController,UITableViewDelegate {

    @IBOutlet weak var channelTableView: UITableView!
    
    //声明代理 
    var delegate:ChannelProtocol?
    //频道列表数据
    var channelData:[JSON] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.alpha = 0.8
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channelData.count
    }
    
    //设置cell的显示动画
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        //设置cell的现实动画为3d缩放，x,y方向播放动画，初始值为0.1，结束值为1
        cell.layer.transform = CATransform3DMakeScale(0.1, 0.1, 0.1)
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            cell.layer.transform = CATransform3DMakeScale(1, 1, 1)
        })
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = channelTableView.dequeueReusableCellWithIdentifier("channel") as! UITableViewCell
        //获取行书据
        let rowData:JSON = self.channelData[indexPath.row] as JSON
        //设置行数据
        cell.textLabel?.text = rowData["name"].string
        return cell
    }
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let rowData:JSON = self.channelData[indexPath.row] as JSON
        //获取选中行的频道id
        let channel_id:String = rowData["channel_id"].stringValue
        //将频道id反相传给主界面
        delegate?.onChangeChannel(channel_id)
        //关闭当前界面
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

 }
