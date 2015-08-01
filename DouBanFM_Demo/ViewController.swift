//
//  ViewController.swift
//  DouBanFM_Demo
//
//  Created by 游义男 on 15/7/31.
//  Copyright (c) 2015年 游义男. All rights reserved.
//

import UIKit
import MediaPlayer

class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,HttpProtocol,ChannelProtocol {
    
    //歌曲列表
    @IBOutlet weak var songsTableView: UITableView!
    //背景
    @IBOutlet weak var background: UIImageView!
    // 组件歌曲封面
    @IBOutlet weak var rotationImage: IndexImageView!
    
    //  网络操作类的实例
    var eHttp:HTTPController = HTTPController()
    
    // 使用SwiftyJson
    
    //接受频道的歌曲数据

    var tableData:[JSON] = []
    
    //接受频道的数据
    var channelData:[JSON] = []
    
    //定义一个图片缓存的字典
    var imageCache = Dictionary<String,UIImage>()
    
    //声明一个媒体播器的实例
    var audioPlayer:MPMoviePlayerController = MPMoviePlayerController()
    
    //声明一个计时器
    var timer:NSTimer?
    
    //  判断歌曲是否是自然结束
    var isAutoFinish:Bool = true
    //认为结束的三种情况 1.点击按钮，2点击频道列表。3点击歌曲列表中的某一行
    
    
    @IBOutlet weak var playTime: UILabel!
    
    @IBOutlet weak var progress: UIImageView!
    

    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var btnPlay: CustomButton!
    @IBOutlet weak var btnPre: UIButton!

    
    //当前实在播放第几首
    var currIndex:Int = 0

    // 播放顺序按钮
    @IBOutlet weak var btnOrder: OrderButton!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        rotationImage.onRotation()
        
        //背景模糊
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame.size = CGSize(width: view.frame.width, height: view.frame.height)
        background.addSubview(blurView)
        
        //设置tableview的数据源和代理
        songsTableView.dataSource = self
        songsTableView.delegate = self
        
        //为网络操作类设置代理
        eHttp.delegate = self
        //获取频道
        eHttp.onSerach("http://www.douban.com/j/app/radio/channels")
        eHttp.onSerach("http://douban.fm/j/mine/playlist?type=n&channel=0&from=mainsite")
        
        //让tableView背景透明
        songsTableView.backgroundColor = UIColor.clearColor()
        
        //监听按钮点击
        //注意一定不能少了感叹号！切记切记！！！！！！！
        btnPlay.addTarget(self, action: "onPlay:", forControlEvents: UIControlEvents.TouchUpInside)
        btnNext.addTarget(self, action: "onClick:", forControlEvents: UIControlEvents.TouchUpInside)
        btnPre.addTarget(self, action: "onClick:", forControlEvents: UIControlEvents.TouchUpInside)
        btnOrder.addTarget(self, action:"onOrder:", forControlEvents: UIControlEvents.TouchUpInside)
        
        //播放结束通知
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playFinish", name: MPMoviePlayerPlaybackDidFinishNotification, object: audioPlayer)
    }
    
  
    func playFinish(){
        if isAutoFinish{
            switch(btnOrder.order){
            case 1:
                //顺序播放
                currIndex++
                if currIndex > tableData.count - 1{
                    currIndex = 0
                }
            case 2:
                //随机播放
                currIndex = random() % tableData.count
            case 3:
                // 单曲循环
                onSelectRow(currIndex)
            default:
                "default"
            }

        }else{
            isAutoFinish = true
        }
    }
    
    func onOrder(btn:OrderButton){
        var message:String = ""
        switch(btn.order){
        case 1:
            message = "顺序播放"
        case 2:
            message = "随即播放"
        case 3:
            message = "单曲循环"
        default:
            message = "default"
        }
        self.view.makeToast(message: message, duration: 0.5, position: "center")
    }
    
    func onClick(btn:UIButton){
        isAutoFinish = false
        if btn == btnNext{
            currIndex++
            if currIndex > self.tableData.count - 1 {
                currIndex = 0
            }
        }else{
            currIndex--
            if currIndex < 0{
                currIndex = self.tableData.count - 1
            }
            
        }
        onSelectRow(currIndex)
    }
    
    func onPlay(btn:CustomButton){
        if btn.isPlay {
            audioPlayer.play()
        }else{
            audioPlayer.pause()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = songsTableView.dequeueReusableCellWithIdentifier("douban") as! UITableViewCell
        //cell背景透明
        cell.backgroundColor = UIColor.clearColor()
        // 获取每一行的数据
        let rowData:JSON = tableData[indexPath.row]
        //标题
        cell.textLabel?.text = rowData["title"].string
        cell.detailTextLabel?.text = rowData["artist"].string
        // 缩略图
        cell.imageView?.image = UIImage(named: "thumb")
        //封面的网址
        let url = rowData["picture"].string
        
//        Alamofire.manager.request(Method.GET, url!).response { (_, _, data, error) -> Void in
//            //将图片数据给UIImage
//            let img = UIImage(data: data! as! NSData)
//            //设置封面的缩略图
//            cell.imageView?.image = img
//        }
        onGetCacheImage(url!, imgView:cell.imageView!)
        return cell
    }
    
    //点击了那一首歌曲
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        isAutoFinish = false
        onSelectRow(indexPath.row)
    }
    
    //设置cell的显示动画
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        //设置cell的现实动画为3d缩放，x,y方向播放动画，初始值为0.1，结束值为1
        cell.layer.transform = CATransform3DMakeScale(0.1, 0.1, 0.1)
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            cell.layer.transform = CATransform3DMakeScale(1, 1, 1)
        })
    }
    
    //选中了哪一行
    func onSelectRow(index:Int){
        //构建一个indexPath
        let indexPath = NSIndexPath(forRow: index, inSection: 0)
        //选中的效果
        songsTableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.Top)
        //获取行数据
        var rowData:JSON = self.tableData[index] as JSON
        //获取图片地址
        let imgUrl = rowData["picture"].string
        //设置封面以及背景
        onSetImage(imgUrl!)
        
        //获取到音乐的文件地址
        var url:String = rowData["url"].string!
        //播放音乐
        onSetAudio(url)
        
    }
    
    //设置歌曲的封面以及背景
    func onSetImage(url:String){
//        Alamofire.manager.request(Method.GET, url).response { (_, _, data, error) -> Void in
//            //将获取的数据赋予UIImage
//            let img = UIImage(data: data! as! NSData)
//            self.rotationImage.image = img
//            self.background.image = img
//            
//        }
        onGetCacheImage(url, imgView:self.rotationImage)
        onGetCacheImage(url, imgView:self.background)
        
    }
    
    //播放音乐的方法
    func onSetAudio(url:String){
        self.audioPlayer.stop()
        self.audioPlayer.contentURL = NSURL(string: url)
        self.audioPlayer.play()
        
        btnPlay.onPlay()
        
        //先停掉计时器
        timer?.invalidate()
        //将计时器归零
        playTime.text = "00:00"
        
        //启动计时器
        timer = NSTimer.scheduledTimerWithTimeInterval(0.4, target: self, selector: "onUpdate", userInfo: nil, repeats: true)
        isAutoFinish = true
    }
    //计时器更新方法
    func onUpdate(){
        //00:00获取播放器当前的播放时间
        let c = audioPlayer.currentPlaybackTime
        if c > 0.0{
            
            // 歌曲的总时间 
            let t = audioPlayer.duration
            //计算百分比
            let pro:CGFloat = CGFloat(c/t)
            //按照百分比显示进度条的宽度
            progress.frame.size.width = view.frame.size.width * pro
            
            
            // 这是一个小算法，来实现 00:00 这种样式的播放移动时间
            
            let all:Int = Int(c)
            let m:Int = all % 60
            let f:Int = Int(all/60)
            var time:String = ""
            if f<10{
                time = "0\(f):"
            }else{
                time = "\(f):"
            }
            if m < 10
            {
                time += "0\(m)"
            }else{
                time += "\(m)"
            }
            
            //更新界面上的文本标签
            playTime.text = time
        }
    }
    
    //图片缓存策略方法
    func onGetCacheImage(url:String,imgView:UIImageView){
        //获取图片地址去缓存中取图片
        let image = self.imageCache[url] as UIImage?
        if image == nil{
            //如果缓存中没有这张图片，就去网络中获取
            Alamofire.manager.request(Method.GET, url).response({ (_, _, data, error) -> Void in
                //获取的图像数据赋予imgView
                let img = UIImage(data: data! as! NSData)
                imgView.image = img
                self.imageCache[url] = img
            })
        }else{
            //如果缓存中有，直接使用
            imgView.image = image!
        }
    }
    
    func didRecieveResults(results: AnyObject) {
//        println("获取到的参数\(results)")
        let json = JSON(results)
        //判断是否是频道数据
        if let channels = json["channels"].array{
            self.channelData = channels
        }else if let song = json["song"].array{
            isAutoFinish = false
            self.tableData = song
            //刷新songsTableView中的数据
            self.songsTableView.reloadData()
            //设置第一首歌的图片以及背景
            onSelectRow(0)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //获取跳转目标
        var channelC:ChannelViewController = segue.destinationViewController as! ChannelViewController
        //代理 
        channelC.delegate = self
        //传递数据
        channelC.channelData = self.channelData
    }
    
    // 频道列表协议的回调方法
    func onChangeChannel(channel_id: String) {
        //拼凑频道列表的歌曲数据网络地址
        //
        let url:String = "http://douban.fm/j/mine/playlist?type=n&channel=\(channel_id)&from=mainsite"
        eHttp.onSerach(url)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

