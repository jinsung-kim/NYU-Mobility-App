//
//  ShareSessionController.swift
//  NYU Mobility
//
//  Created by Jin Kim on 7/27/20.
//  Copyright © 2020 Jin Kim. All rights reserved.
//

import UIKit
import MessageUI // Used to send emails

class ShareSessionController: UIViewController, MFMailComposeViewControllerDelegate {
    
    var points: [Point]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func shareSession(_ sender: Any) {
        sendEmail(jsonData: saveAndExport(exportString: generateJSON()))
    }
    
    func generateJSON() -> String {
        let dicArray = points.map { $0.convertToDictionary() }
        if let data = try? JSONSerialization.data(withJSONObject: dicArray, options: .prettyPrinted) {
            let str = String(bytes: data, encoding: .utf8)
            return str!
        }
        return "There was an error generating the JSON file"
    }
    
    // Export Functionality
    
    /**
       Generates a temporary directory with a URL and creates a file to be exported as a JSON
       - Parameters:
           - exportString: The name of the file being executed (all within 'Sound' group)
       - Returns: Data object as a JSON file
    */
    func saveAndExport(exportString: String) -> Data {
        let exportFilePath = NSTemporaryDirectory() + "export.json"
        let exportFileUrl = NSURL(fileURLWithPath: exportFilePath)
        FileManager.default.createFile(atPath: exportFilePath, contents: Data(), attributes: nil)
        var fileHandle: FileHandle? = nil
        // Try to save the file as a URL
        do {
            fileHandle = try FileHandle(forWritingTo: exportFileUrl as URL)
        } catch {
            print("Error with File Handle")
        }
        
        fileHandle?.seekToEndOfFile()
        let jsonData = exportString.data(using: String.Encoding.utf8, allowLossyConversion: false)
        // Writes the JSON data into the file
        fileHandle?.write(jsonData!)
        fileHandle?.closeFile()
        return jsonData ?? Data()
    }
    
    // Gesture Functionality
    func getState() -> Bool {
        let defaults = UserDefaults.standard
        let gesture = defaults.bool(forKey: "state")
        return gesture
    }
    
    // Email Functionality
    
    func saveEmail(_ email: String) {
        let defaults = UserDefaults.standard
        defaults.set(email, forKey: "email")
    }
    
    func getEmail() -> String {
        let defaults = UserDefaults.standard
        let email = defaults.string(forKey: "email")
        return email!
    }
    
    func sendEmail(jsonData: Data) {
        let recipientEmail = getEmail()
        let subject = "JSON Export"
        let body = "Here is the data that I tracked"

        // Show default mail composer
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([recipientEmail])
            mail.setSubject(subject)
            mail.setMessageBody(body, isHTML: false)
            
            mail.addAttachmentData(jsonData, mimeType: "application/json" , fileName: "export.json")

            present(mail, animated: true)

        // Show third party email composer if default Mail app is not present
        } else if let emailUrl = createEmailUrl(to: recipientEmail, subject: subject, body: body) {
            UIApplication.shared.open(emailUrl)
        }
    }
    
    func createEmailUrl(to: String, subject: String, body: String) -> URL? {
        let subjectEncoded = subject.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let bodyEncoded = body.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!

        let gmailUrl = URL(string: "googlegmail://co?to=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        let outlookUrl = URL(string: "ms-outlook://compose?to=\(to)&subject=\(subjectEncoded)")
        let yahooMail = URL(string: "ymail://mail/compose?to=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        let sparkUrl = URL(string: "readdle-spark://compose?recipient=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        let defaultUrl = URL(string: "mailto:\(to)?subject=\(subjectEncoded)&body=\(bodyEncoded)")

        if let gmailUrl = gmailUrl, UIApplication.shared.canOpenURL(gmailUrl) {
            return gmailUrl
        } else if let outlookUrl = outlookUrl, UIApplication.shared.canOpenURL(outlookUrl) {
            return outlookUrl
        } else if let yahooMail = yahooMail, UIApplication.shared.canOpenURL(yahooMail) {
            return yahooMail
        } else if let sparkUrl = sparkUrl, UIApplication.shared.canOpenURL(sparkUrl) {
            return sparkUrl
        }
        return defaultUrl
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
