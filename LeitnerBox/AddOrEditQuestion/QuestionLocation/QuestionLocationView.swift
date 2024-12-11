//
//  QuestionLocationView.swift
//  LeitnerBox
//
//  Created by Hamed Hosseini on 12/8/24.
//

import SwiftUI
import MapKit
import UIKit

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *)
struct QuestionLocationView: View {
    @EnvironmentObject var questionVM: QuestionViewModel
    private let itemSize: CGFloat = 128 // Fixed item size
    let isInReviewView: Bool
    @State var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var pickedLocation: CLLocation?
    @State private var showMapPicker: Bool = false
    let camera = MKMapCamera()
    
    var body: some View {
        VStack(alignment: .leading) {
            headerTitle
            if pickedLocation != nil {
                Map(position: $position)
                    .frame(width: itemSize, height: itemSize)
                    .clipShape(RoundedCorner(radius: 8))
                    .overlay(alignment: .topLeading) {
                        if !isInReviewView {
                            removeButton()
                        }
                    }
                    .onTapGesture { _ in
                        showMapPicker = true
                    }
            }
            
            if pickedLocation == nil {
                addLocationButton
            }
            if !isInReviewView {
                footerView
            }
        }
        .animation(.easeInOut, value: pickedLocation)
        .sheet(isPresented: $showMapPicker) {
            MapPicker(pickedLocation: pickedLocation) { location in
                if let location = location {
                    let camera = MapCamera(centerCoordinate: location, distance: 500)
                    position = .camera(camera)
                    pickedLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
                    questionVM.addLocation(latitude: location.latitude, longitude: location.longitude)
                }
            }
        }
        .task {
            if let tuple = questionVM.questionCoordiante() {
                pickedLocation = CLLocation(latitude: tuple.lat, longitude: tuple.lng)
            }
        }
    }
    
    private var headerTitle: some View {
        HStack {
            Text("Location")
                .foregroundStyle(Color("AccentColor"))
                .fontWeight(.bold)
            Spacer()
        }
    }
    
    private var footerView: some View {
        HStack {
            Text("Attach a geographical location to a question to provide a hint regarding its origin.")
                .foregroundStyle(.gray)
                .font(.footnote)
            Spacer()
        }
    }
    
    private var addLocationButton: some View {
        Button {
            showMapPicker = true
        } label: {
            HStack {
                Image(systemName: "location.square")
                    .foregroundStyle(Color("AccentColor"))
            }
            .padding()
            .clipShape(RoundedCorner(radius: 8))
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color("AccentColor"), lineWidth: 1)
            }
        }
    }
    
    @ViewBuilder
    private func removeButton() -> some View {
        Button {
            questionVM.removeLocation()
            pickedLocation = nil
        } label: {
            Image(systemName: "minus.circle.fill")
                .symbolRenderingMode(.multicolor)
                .resizable()
                .frame(width: 32, height: 32)
                .foregroundStyle(Color.red, Color.white)
        }
        .offset(x: -8, y: -8)
    }
}

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *)
struct MapPicker: View {
    let pickedLocation: CLLocation?
    let onLocation: (CLLocationCoordinate2D?) -> Void
    @Environment(\.dismiss) var dismiss
    @State private var initialPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    
    var body: some View {
        MapReader { reader in
            Map(position: $initialPosition) {
                if let pickedLocation = pickedLocation {
                    Marker("Selected Location", coordinate: pickedLocation.coordinate)
                }
            }
            .onTapGesture { screenCoordinate in
                let converted = reader.convert(screenCoordinate, from: .local)
                onLocation(converted)
                dismiss()
            }
        }
        .onAppear {
            if let pickedLocation = pickedLocation {
                let camera: MapCamera = MapCamera(centerCoordinate: pickedLocation.coordinate, distance: 100_000)
                initialPosition = MapCameraPosition.camera(camera)
            }
        }
    }
}

