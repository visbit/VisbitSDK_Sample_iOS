# Visbit iOS SDK Sample

## Prerequisites ##
* XCode 8.3
* Visbit VR Streaming Account (free signup at [www.visbit.co](www.visbit.co))

## Note
In app's Info.plist, replace the value of key **co.visbit.vrplayer.appIdentifier** with your App ID.

## Integration with the SDK
**Limitation:** This SDK currently only supports swift based project.
1. Copy VideoPlayer_iOS_Native.framework to your project
2. Copy "Copy-frameworks.sh" to your project
3. Add **Run Script** build phase and execute the "Copy-frameworks.sh" script
4. Add **co.visbit.vrplayer.appIdentifier** key in the App Info.plist with the value of your App ID
5. Register with the App ID
	```swift
    import VideoPlayer_iOS_Native
    class AppDelegate: UIResponder, UIApplicationDelegate, StreamManagerListener {
       	func application(_ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
            // Override point for customization after application launch.
            StreamManager.register(listener: self)
            return true
        }

        func onRegistrationSucceed()
        {
        }

        func onRegistrationFailed(errorCode : Int, errorMessage: String)
        {
            print(errorMessage)
        }
    ```
6. Load the video list
	```swift
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
    }
    ```
7. Launch the player
	```swift
    ...
    private func onLoadComplete(_ response: LoadVideoListTask.TaskResponse) {
        if let videoModel = response.data().first {
            let playerVC = VBMoviePlayerController(videoModel: videoModel)
            present(playerVC, animated: true) {}
        }
    }
    ...
    ```
8. Build Settings
	* Enable Bitcode →  No
