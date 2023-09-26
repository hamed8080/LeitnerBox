//
//  ObservableObject+.swift
//  LeitnerBox
//
//  Created by hamed on 9/26/23.
//

import Foundation
import Foundation
import Combine
import SwiftUI

public extension ObservableObject where Self.ObjectWillChangePublisher == ObservableObjectPublisher {

    func animateObjectWillChange() {
        Task {
            await MainActor.run {
                withAnimation {
                    objectWillChange.send()
                }
            }
        }
    }
}
