//
//  ShareVideoController.swift
//  NYU Mobility
//
//  Created by Jin Kim on 7/26/20.
//  Copyright © 2020 Jin Kim. All rights reserved.
//

import UIKit
import Photos
import CoreData

class ShareVideoController: UIViewController {
    
    var session: NSManagedObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // Gets the directory that the video is stored in
    func getPathDirectory() -> URL {
        // Searches a FileManager for paths and returns the first one
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = paths[0]
        return documentDirectory
    }

    func generateURL() -> URL? {
        let path = getPathDirectory().appendingPathComponent(session.value(forKey: "videoURL") as! String)
        return path
    }
    
    @IBAction func shareVideo(_ sender: Any) {
        saveVideoToAlbum(generateURL()!) { (error) in
            // Do something with error
        }
    }
    
    func requestAuthorization(completion: @escaping () -> Void) {
            if PHPhotoLibrary.authorizationStatus() == .notDetermined {
                PHPhotoLibrary.requestAuthorization { (status) in
                    DispatchQueue.main.async {
                        completion()
                    }
                }
            } else if PHPhotoLibrary.authorizationStatus() == .authorized{
                completion()
            }
        }



    func saveVideoToAlbum(_ outputURL: URL, _ completion: ((Error?) -> Void)?) {
            requestAuthorization {
                PHPhotoLibrary.shared().performChanges({
                    let request = PHAssetCreationRequest.forAsset()
                    request.addResource(with: .video, fileURL: outputURL, options: nil)
                }) { (result, error) in
                    DispatchQueue.main.async {
                        if let error = error {
                            print(error.localizedDescription)
                        } else {
                            print("Saved successfully")
                        }
                        completion?(error)
                    }
                }
            }
        }
    
}
