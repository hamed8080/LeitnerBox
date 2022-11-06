//
// LeitnerBoxUITestsLaunchTests.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

import XCTest

class LeitnerBoxUITestsLaunchTests: XCTestCase {
    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        false
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        let ttgc7swiftui19uihostingNavigationBar = app.navigationBars["_TtGC7SwiftUI19UIHosting"]
        ttgc7swiftui19uihostingNavigationBar.buttons["Back"].tap()

        let tables = app.tables
        tables.staticTexts.element(boundBy: 0).tap()
        tables.staticTexts.matching(identifier: "levelRow").element(boundBy: 0).tap()

        app.scrollViews.otherElements.staticTexts["Tap to show answer"].tap()
        ttgc7swiftui19uihostingNavigationBar.buttons["English"].tap()

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app

//        let attachment = XCTAttachment(screenshot: app.screenshot())
//        attachment.name = "Launch Screen"
//        attachment.lifetime = .keepAlways
//        add(attachment)
    }
}
