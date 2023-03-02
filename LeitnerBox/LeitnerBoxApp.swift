//
// LeitnerBoxApp.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

import SwiftUI

@main
struct LeitnerBoxApp: App {

    var body: some Scene {
        WindowGroup {
            ZStack {
                Button {
                    let ctx = PersistenceController.shared.container.viewContext
                    let question = Question(context: ctx)
                    question.question = "Hamed"
                    try? ctx.save()
                } label: {
                    Text("Add")
                }
            }
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
        }
    }
}
