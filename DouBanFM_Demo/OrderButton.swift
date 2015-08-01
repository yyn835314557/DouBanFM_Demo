//
//  OrderButton.swift
//  DouBanFM_Demo
//
//  Created by 游义男 on 15/8/1.
//  Copyright (c) 2015年 游义男. All rights reserved.
//

import UIKit

class OrderButton: UIButton {
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
    // Drawing code
    }
    */
    
    var order:Int = 1
    
    let order1:UIImage = UIImage(named: "order1")!
    let order2:UIImage = UIImage(named: "order2")!
    let order3:UIImage = UIImage(named: "order3")!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addTarget(self, action: "onClick:", forControlEvents: UIControlEvents.TouchUpInside)
    }
    func onClick(sender:UIButton){
        order++
        if order == 1{
            self.setImage(order1, forState: UIControlState.Normal)
        }else if order == 2 {
            self.setImage(order2, forState: UIControlState.Normal)
        }else if order == 3 {
            self.setImage(order3, forState: UIControlState.Normal)
        }else if order > 3 {
            order = 1
            self.setImage(order1, forState: UIControlState.Normal)
        }
    }
}




