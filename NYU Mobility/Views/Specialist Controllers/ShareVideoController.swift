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
//        saveAndExport()
        writeJSONFile()
    }
    
    func requestAuthorization(completion: @escaping () -> Void) {
        if PHPhotoLibrary.authorizationStatus() == .notDetermined {
            PHPhotoLibrary.requestAuthorization { (status) in
                DispatchQueue.main.async {
                    completion()
                }
            }
        } else if PHPhotoLibrary.authorizationStatus() == .authorized {
            completion()
        }
    }

    /**
        Given the url of the video, a request is created to the photo library to be added
        - Parameters:
            - outputURL: URL that is sent to be saved
            - completion: Handles possible failures with saving the URL
        - Returns: An error if applicable
     */
    func saveVideoToAlbum(_ outputURL: URL, _ completion: ((Error?) -> Void)?) {
        requestAuthorization {
            PHPhotoLibrary.shared().performChanges({
                let request = PHAssetCreationRequest.forAsset()
                request.addResource(with: .video, fileURL: outputURL, options: nil)
            }) { (result, error) in
                DispatchQueue.main.async {
//                    if let error = error {
//                        print(error.localizedDescription)
//                        let alertController = UIAlertController(title: "Your video could not be saved", message: nil, preferredStyle: .alert)
//                        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//                        alertController.addAction(defaultAction)
//                        self.present(alertController, animated: true, completion: nil)
//                    } else {
//                        let alertController = UIAlertController(title: "Your video was successfully saved", message: nil, preferredStyle: .alert)
//                        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//                        alertController.addAction(defaultAction)
//                        self.present(alertController, animated: true, completion: nil)
//                    }
                    completion?(error)
                }
            }
        }
    }
    
    // Export Functionality
    
    /**
       Generates a temporary directory with a URL and creates a file to be exported as a JSON
    */
    func writeJSONFile() {
        let file = "\((session.value(forKey: "videoURL") as! String)[0..<36]).json"
        let content = session.value(forKey: "json") as! String
        print(file)

        
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = directory.appendingPathComponent(file)
        
        do {
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            print("Error: \(error)")
        }
        
        let objectsToShare = [fileURL]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)

        activityVC.setValue("Export", forKey: "subject")

        // New Excluded Activities Code
        if #available(iOS 9.0, *) {
            activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList,
                                                UIActivity.ActivityType.assignToContact, UIActivity.ActivityType.copyToPasteboard,
                                                UIActivity.ActivityType.mail, UIActivity.ActivityType.message,
                                                UIActivity.ActivityType.openInIBooks, UIActivity.ActivityType.postToTencentWeibo,
                                                UIActivity.ActivityType.postToVimeo, UIActivity.ActivityType.postToWeibo,
                                                UIActivity.ActivityType.print]
        // Fallback on earlier versions
        } else {
            activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList,
                                                UIActivity.ActivityType.assignToContact, UIActivity.ActivityType.copyToPasteboard,
                                                UIActivity.ActivityType.mail, UIActivity.ActivityType.message,
                                                UIActivity.ActivityType.postToTencentWeibo, UIActivity.ActivityType.postToVimeo,
                                                UIActivity.ActivityType.postToWeibo, UIActivity.ActivityType.print]
        }

        present(activityVC, animated: true, completion: nil)
    }
}
