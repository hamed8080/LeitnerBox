//
// NotAnyToReviewView.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

import SwiftUI

struct NotAnyToReviewView: View {
    var body: some View {
        VStack {
            Image(systemName: "rectangle.and.text.magnifyingglass")
                .resizable()
                .scaledToFit()
                .frame(width: 128, height: 128)
                .foregroundColor(.gray)
            Text("There is nothing to review here at the moment.")
                .font(.title2.weight(.medium))
                .foregroundColor(.gray)
        }
    }
}

struct NotAnyToReviewView_Previews: PreviewProvider {
    static var previews: some View {
        NotAnyToReviewView()
    }
}
