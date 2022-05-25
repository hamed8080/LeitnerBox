//
//  ActivityViewControllerWrapper.swift
//  ChatApplication
//
//  Created by Hamed Hosseini on 10/16/21.
//

import SwiftUI
import LinkPresentation

struct ActivityViewControllerWrapper : UIViewControllerRepresentable{
 
    var activityItems:[URL]
    var applicationActivities:[UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> some UIActivityViewController {
        let vc = UIActivityViewController(activityItems: [LinkMetaDataManager(url: activityItems.first!)] , applicationActivities: nil)
        return vc
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}


class LinkMetaDataManager:NSObject,UIActivityItemSource{
    
    let url:URL
    
    init(url:URL) {
        self.url = url
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return ""
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return url
    }
    
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let image = UIImage(named: "global_app_icon")
        let imageProvider = NSItemProvider(object: image!)
        let metadata = LPLinkMetadata()
        metadata.originalURL = url
        metadata.url = url
        metadata.imageProvider = imageProvider
        metadata.title = url.lastPathComponent
        return metadata
    }
    
    
}
