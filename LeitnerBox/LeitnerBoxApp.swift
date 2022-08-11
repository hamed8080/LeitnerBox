//
//  LeitnerBoxApp.swift
//  LeitnerBox
//
//  Created by hamed on 5/19/22.
//

import SwiftUI
import UniformTypeIdentifiers

@main
struct LeitnerBoxApp: App, DropDelegate {
    
    
    
    @Environment(\.scenePhase) var scenePhase
    
    @ObservedObject
    var persistenceController = PersistenceController.shared
    
    @State private var dragOver = false
    
    var body: some Scene {
        WindowGroup {
//            ZStack{
//                ScrollView(.vertical){
//                    let columns: [GridItem] = Array(repeating: .init(.fixed(64)), count: 14)
//                    LazyVGrid(columns: columns) {
//                        ForEach(allFlags(), id:\.self){ flag in
//                            Text(flag)
//                                .font(.system(size: 64))
//                        }
//                    }
//                }
//            }
            LeitnerView()
                .onDrop(of: [.fileURL, .data], delegate: self)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onChange(of: scenePhase) { newPhase in
                    if newPhase == .active {
                        PersistenceController.shared.replaceDBIfExistFromShareExtension()
                    } else if newPhase == .inactive {
                        print("Inactive")
                    } else if newPhase == .background {
                        print("Background")
                    }
                }
        }
    }

    func flag(from country:String) -> String {
        let base : UInt32 = 127397
        var s = ""
        for v in country.uppercased().unicodeScalars {
            s.unicodeScalars.append(UnicodeScalar(base + v.value)!)
        }

        return s
    }

    func allFlags() -> [String] {
        let isoCodes = Locale.isoRegionCodes
        var flags: [String] = []
        for isoCode in isoCodes {
            flags.append(flag(from: isoCode))
        }
        return flags
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        let proposal = DropProposal.init(operation: .copy)
        return proposal
    }
    
    func performDrop(info: DropInfo) -> Bool {
        PersistenceController.shared.dropDatabase(info)
        return true
    }
}
