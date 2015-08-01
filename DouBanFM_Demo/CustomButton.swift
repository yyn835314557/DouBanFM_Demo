//
//  CustomButton.swift
//  DouBanFM_Demo
//
//  Created by 游义男 on 15/8/1.
//  Copyright (c) 2015年 游义男. All rights reserved.
//

import UIKit

class CustomButton: UIButton {
    
	var isPlay:Bool = true
    let imgPlay:UIImage = UIImage(named: "play")!
    let imgPause:UIImage = UIImage(named: "pause")!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addTarget(self, action: "onClick", forControlEvents: UIControlEvents.TouchUpInside)
    }
    func onClick(){
        isPlay = !isPlay
        if isPlay{
            self.setImage(imgPause, forState: UIControlState.Normal)
        }else{
            self.setImage(imgPlay, forState: UIControlState.Normal)
        }
    }
    func onPlay(){
        isPlay = true
        self.setImage(imgPause, forState: UIControlState.Normal)
    }

}
