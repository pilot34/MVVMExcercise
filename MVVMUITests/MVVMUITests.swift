//
//  MVVMUITests.swift
//  MVVMUITests
//
//  Created by Gleb Tarasov on 10/7/18.
//  Copyright © 2018 Gleb Tarasov. All rights reserved.
//

import XCTest

class MVVMUITests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    let app = XCUIApplication()

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSearchWorks() {
        let field = app.textFields.firstMatch
        field.tap()
        field.typeText("Bond")
        field.typeText("\n")

        // look for cell with "Skyfall" title
        let predicate = NSPredicate(format: "label BEGINSWITH \"Skyfall\"")
        let needed = app.cells.staticTexts.containing(predicate).firstMatch
        wait(forElement: needed)
    }

    func testSuggestionsWork() {
        let field = app.textFields.firstMatch
        field.tap()
        field.typeText("Bond")
        field.typeText("\n")

        let backButton = app.navigationBars.buttons.element(boundBy: 0)
        wait(forElement: backButton)
        backButton.tap()
        field.tap()
        field.buttons["Clear text"].tap()

        // check that we have "Bond" suggestion
        // if this line failed, be sure that keyboard is opening when you tap
        // on a text field in the simulator
        XCTAssert(app.cells.staticTexts["Bond"].firstMatch.exists)
    }
}
