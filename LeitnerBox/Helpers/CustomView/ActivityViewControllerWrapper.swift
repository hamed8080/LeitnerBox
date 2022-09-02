//
// ActivityViewControllerWrapper.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 9/2/22.

import LinkPresentation
import SwiftUI

struct ActivityViewControllerWrapper: UIViewControllerRepresentable {
    var activityItems: [URL]
    var applicationActivities: [UIActivity]?

    func makeUIViewController(context _: Context) -> some UIActivityViewController {
        let vc = UIActivityViewController(activityItems: [LinkMetaDataManager(url: activityItems.first!)], applicationActivities: nil)
        return vc
    }

    func updateUIViewController(_: UIViewControllerType, context _: Context) {}
}

class LinkMetaDataManager: NSObject, UIActivityItemSource {
    let url: URL

    init(url: URL) {
        self.url = url
    }

    func activityViewControllerPlaceholderItem(_: UIActivityViewController) -> Any {
        ""
    }

    func activityViewController(_: UIActivityViewController, itemForActivityType _: UIActivity.ActivityType?) -> Any? {
        url
    }

    func activityViewControllerLinkMetadata(_: UIActivityViewController) -> LPLinkMetadata? {
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
