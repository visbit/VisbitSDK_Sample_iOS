//
//  ViewController.swift
//  VRSample-Swift
//
//  Created by Ji Fang on 7/27/17.
//  Copyright © 2017 visbit. All rights reserved.
//

import UIKit
import VideoPlayer_iOS_Native

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        loadVideoList()
    }

    private func loadVideoList() {
        let task = LoadVideoListTask()
        task.startLoading(at: 0) { (responseObject: LoadVideoListTask.TaskResponse?) in
            if let response = responseObject {
                self.onLoadComplete(response)
            }
            else {
                self.onLoadFailed()
            }
        }
    }

    private func onLoadFailed() {
        print("Load Failed")
    }

    private func onLoadComplete(_ response: LoadVideoListTask.TaskResponse) {
        if let videoModel = response.data().first {
            let playerVC = VBMoviePlayerController(videoModel: videoModel)
            present(playerVC, animated: true) {}
        }
    }

}

