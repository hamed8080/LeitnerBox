//
//  ShareViewController.swift
//  Share
//
//  Created by hamed on 5/24/22.
//

import UIKit
import UniformTypeIdentifiers

@objc(ShareViewController)
class ShareViewController: UIViewController {

    static let groupName = "group.ir.app_group"
    
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var lbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        importFile()
    }
    
    func importFile() {
        //       extracting the path to the URL that is being shared
        let attachments = (self.extensionContext?.inputItems.first as? NSExtensionItem)?.attachments ?? []
        for provider in attachments {
            // Check if the content type is the same as we expected
            if provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
                provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { (data, error) in
                    // Handle the error here if you want
                    guard error == nil else { return }
                    if let url = data as? URL{
                        AppGroupLocalStorage.shared.saveFile(fileURL: url) { errorSaveFile in
                            if let error = errorSaveFile{
                                DispatchQueue.main.async {
                                    self.lbl.text = error.localizedDescription
                                }
                            }else{
                                DispatchQueue.main.async {
                                    self.lbl.text = "Imported. Please open application to sync import."
                                    self.img.isHidden =  false
                                    Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { timer in
                                        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
                                    }
                                }
                            }
                        }
                    } else {
                        // Handle this situation as you prefer
                        fatalError("Impossible to save image")
                    }
                }}
        }
    }
}
