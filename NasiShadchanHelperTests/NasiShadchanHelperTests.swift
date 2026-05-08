//
//  NasiShadchanHelperTests.swift
//  NasiShadchanHelperTests
//
//  Created by user on 4/24/20.
//  Copyright © 2020 user. All rights reserved.
//
import XCTest
@testable import NasiShadchanHelper

final class NasiShadchanHelperTests: XCTestCase {
    
    func test_appLaunchCoordinator_startsUnauthenticatedFlow_whenUserIsLoggedOut() {
        
        let sut = AppLaunchCoordinator()
        
        let result = sut.start(isLoggedIn: false)
        
        XCTAssertEqual(result, AppLaunchFlow.showLogin)
        

    }
    
    func test_appLaunchCoordinator_startsMainFlow_whenUserIsLoggedIn() {

        let sut = AppLaunchCoordinator()

        let result = sut.start(isLoggedIn: true)

        XCTAssertEqual(result, AppLaunchFlow.showMainApp)
    }
    
    func test_appLaunchCoordinator_storesPendingImport_whenDeepLinkIsImportResume() {

        let sut = AppLaunchCoordinator()

        sut.handle(url: URL(string: "matchmaker://import-resume")!)

        //XCTAssertTrue(sut.hasPendingImportResume)
        XCTAssertEqual(sut.pendingRoute, .importResume)
    }
    
    func test_handleURL_whenURLIsNotImportResume_doesNotStorePendingImport() {
        let sut = AppLaunchCoordinator()

        sut.handle(url: URL(string: "matchmaker://something-else")!)

        //XCTAssertFalse(sut.hasPendingImportResume)
        XCTAssertNil(sut.pendingRoute)
    }

}
