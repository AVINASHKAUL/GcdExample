//
//  ViewController.swift
//  dummyAppsAnimations
//
//  Created by Avinash Kaul on 28/06/20.
//  Copyright © 2020 Avinash Kaul. All rights reserved.
//


import UIKit



class Downloader {
    
    static func downloadImageWithURL(_ url:String) -> UIImage? {
        do {
            let data = try Data(contentsOf: URL(string: url)!)
            return UIImage(data: data)
        } catch  {
            print(error.localizedDescription)
        }
        return nil
    }
}

let imageURLs = ["https://www.dccomics.com/sites/default/files/styles/character_thumb_160x160/public/Char_Profile_WonderWoman_20190116_5c3fc6aa51d0e3.49076914.jpg", "https://www.dccomics.com/sites/default/files/Char_Gallery_HarleyQuinn_BoPCharacter_5e1e70598de1b4.57213217.jpg", "https://www.dccomics.com/sites/default/files/styles/character_thumb_160x160/public/Char_Profile_Supergirl_5b6b48d864df16.97644129.jpg", "https://www.dccomics.com/sites/default/files/styles/character_thumb_160x160/public/Char_Profile_Mera_5c102607d8d8c8.01608468.jpg"
    ]

class ViewController: UIViewController {

    @IBOutlet weak var imageView1: UIImageView!
    
    @IBOutlet weak var imageView2: UIImageView!
    
    @IBOutlet weak var imageView3: UIImageView!
    
    @IBOutlet weak var imageView4: UIImageView!
    
    @IBOutlet weak var sliderValueLabel: UILabel!
    
    @IBOutlet var images: [UIImageView]!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    func showMessage(message:String){
        let alert = UIAlertController(title: "Hey", message: message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))

        self.present(alert, animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func didClickOnStart(sender: AnyObject) {
        //downloadImages()
        downloadImagesAsync()
        //downloadImageAsyncGroup()
        //downloadImagesWorkItem()
    }
    
    func downloadImages(){
        let img1 = Downloader.downloadImageWithURL(imageURLs[0])
        self.imageView1.image = img1
        sleep(4)
        
        let img2 = Downloader.downloadImageWithURL(imageURLs[1])
        self.imageView2.image = img2
        
        let img3 = Downloader.downloadImageWithURL(imageURLs[2])
        self.imageView3.image = img3
        
        let img4 = Downloader.downloadImageWithURL(imageURLs[3])
        self.imageView4.image = img4
    }
    
    //Async/Concurrent dispatch queues
       func downloadImagesAsync(){
           let queue = DispatchQueue(label: "image.download.queue", qos: .background, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
           queue.async {
               let img = Downloader.downloadImageWithURL(imageURLs[0])
               sleep(6)
               DispatchQueue.main.async {
                   self.imageView1.image = img
               }
           }
           queue.async {
               let img = Downloader.downloadImageWithURL(imageURLs[1])
               DispatchQueue.main.async {
                   self.imageView2.image = img
               }
           }
           queue.async {
               let img = Downloader.downloadImageWithURL(imageURLs[2])
               DispatchQueue.main.async {
                   self.imageView3.image = img
               }
           }
           queue.async {
               let img = Downloader.downloadImageWithURL(imageURLs[3])
               DispatchQueue.main.async {
                   self.imageView4.image = img
               }
           }
       }
       
    
    //Dispatch Group
    //download first two images async/concurrently
    //download last two images async/seriallt
    //Once both download are down present Alert
    //number of .enter() should be equal to number of .leave() for group to know all queues have finished doing task and execute it's notify
    func downloadImageAsyncGroup(){
        let conQueue = DispatchQueue(label: "image.download.concurrent.queue", qos: .background, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
        let serialQueue = DispatchQueue(label: "image.download.serial.queue")
        let group = DispatchGroup()
        group.enter()
        conQueue.async {
            let img = Downloader.downloadImageWithURL(imageURLs[0])
            DispatchQueue.main.async {
                self.imageView1.image = img
                group.leave()
            }
        }
        group.enter()
        conQueue.async {
            let img = Downloader.downloadImageWithURL(imageURLs[1])
            sleep(2)
            DispatchQueue.main.async {
                self.imageView2.image = img
                group.leave()
            }
        }
        group.enter()
        serialQueue.async {
            let img = Downloader.downloadImageWithURL(imageURLs[2])
            sleep(1)
            DispatchQueue.main.async {
                self.imageView3.image = img
                group.leave()
            }
        }
        //group.enter()
        group.enter()
        serialQueue.async {
            let img = Downloader.downloadImageWithURL(imageURLs[3])
            DispatchQueue.main.async {
                self.imageView4.image = img
                group.leave()
            }
        }
        group.notify(queue: DispatchQueue.main) {
            self.showMessage(message: "All Images shown")
        }
    }
    //Refactoring downloadImagesAsync using WorkItem
    func downloadImagesWorkItem(){
        let downloadWorkItem = DispatchWorkItem(qos: .background, flags: .assignCurrentContext) {[weak self] in
            for (url,imageView) in zip(imageURLs, self?.images ?? []){
                let img = Downloader.downloadImageWithURL(url)
                DispatchQueue.main.async {
                    imageView.image = img
                }
            }
        }
        let queue = DispatchQueue(label: "image.download.queue", qos: .background, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
        queue.async(execute: downloadWorkItem)
    }
    
    @IBAction func sliderValueChanged(sender: UISlider) {
        
        self.sliderValueLabel.text = "\(sender.value * 100.0)"
    }

    @IBAction func resetImages(_ sender: Any) {
        self.imageView1.image = nil
        self.imageView2.image = nil
        self.imageView3.image = nil
        self.imageView4.image = nil
    }
}

