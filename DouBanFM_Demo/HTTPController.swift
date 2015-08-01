
//
//  HTTPController.swift
//  DouBanFM_Demo
//
//  Created by 游义男 on 15/8/1.
//  Copyright (c) 2015年 游义男. All rights reserved.
//

import UIKit

class HTTPController:NSObject {
    //定义一个代理
    var delegate:HttpProtocol?
    //接受网址，回调代理的方法，传回数据
    func onSerach(url:String){
        //访问参数，网址，网络地址携带的参数，编码
        Alamofire.manager.request(Method.GET, url).responseJSON(options: NSJSONReadingOptions.MutableContainers) { (_, _, data, error) -> Void in
            self.delegate?.didRecieveResults(data!)
        }
    }
}

// http协议
protocol HttpProtocol{
    // 定义一个方法,接受一个参数，AnyObject
    func didRecieveResults(results:AnyObject)
}
