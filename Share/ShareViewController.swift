//
// ShareViewController.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

import UIKit
import UniformTypeIdentifiers

@objc(ShareViewController)
final class ShareViewController: UIViewController {
    static let groupName = "group.my.app_group"

    @IBOutlet var img: UIImageView!
    @IBOutlet var lbl: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        importFile()
    }

    func importFile() {
        //       extracting the path to the URL that is being shared
        let attachments = (extensionContext?.inputItems.first as? NSExtensionItem)?.attachments ?? []
        for provider in attachments where provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { data, error in
                // Handle the error here if you want
                guard error == nil else { return }
                if let url = data as? URL {
                    AppGroupLocalStorage.shared.saveFile(fileURL: url) { errorSaveFile in
                        if let error = errorSaveFile {
                            DispatchQueue.main.async {
                                self.lbl.text = error.localizedDescription
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.lbl.text = "Imported. Please open application to sync import."
                                self.img.isHidden = false
                                Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
                                    self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
                                }
                            }
                        }
                    }
                } else {
                    // Handle this situation as you prefer
                    fatalError("Impossible to save image")
                }
            }
        }
    }
}
