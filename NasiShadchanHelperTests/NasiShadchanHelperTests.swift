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
    
    func test_processPendingRoute_whenPendingImportAndMainAppReady_startsImportAndClearsRoute() {
        let router = MockResumeImportRouter()
        let sut = AppLaunchCoordinator(resumeImportRouter: router)
        
        sut.handle(url: URL(string: "matchmaker://import-resume")!)
        
        sut.processPendingRoute(isMainAppReady: true)
        
        XCTAssertEqual(router.handleIncomingShareCallCount, 1)
        XCTAssertNil(sut.pendingRoute)
    }
    
    func
    test_start_asksSessionManagerForLoginState() {
        let sessionManager = MockSessionManager(isLoggedIn: true)
        
        let sut = AppLaunchCoordinator(
            sessionManager: sessionManager
        )
        
        let result = sut.start()
        
        XCTAssertEqual(sessionManager.isLoggedInCallCount, 1)
        XCTAssertEqual(result, .showMainApp)
    }
    
    func test_start_showsLogin_whenUserIsLoggedOut() {
        let sessionManager = MockSessionManager(isLoggedIn: false)
        
        let sut = AppLaunchCoordinator(
            sessionManager: sessionManager
        )
        
        let result = sut.start()
        
        XCTAssertEqual(result, .showLogin)
    }
    
    func test_start_whenUserIsLoggedInAndImportRouteIsPending_showsMainAppAndKeepsPendingRoute() {
        let sessionManager = MockSessionManager(isLoggedIn: true)

        let sut = AppLaunchCoordinator(
            sessionManager: sessionManager
        )

        sut.handle(url: URL(string: "matchmaker://import-resume")!)

        let result = sut.start()

        XCTAssertEqual(result, .showMainApp)
        XCTAssertEqual(sut.pendingRoute, .importResume)
    }
    
    func test_start_whenUserIsLoggedOutAndImportRouteIsPending_showsLoginAndKeepsPendingRoute() {
        let sessionManager = MockSessionManager(isLoggedIn: false)

        let sut = AppLaunchCoordinator(
            sessionManager: sessionManager
        )

        sut.handle(url: URL(string: "matchmaker://import-resume")!)

        let result = sut.start()

        XCTAssertEqual(result, .showLogin)
        XCTAssertEqual(sut.pendingRoute, .importResume)
    }
}

private final class MockResumeImportRouter: ResumeImportRouting {

    private(set) var handleIncomingShareCallCount = 0

    func handleIncomingShare() {
        handleIncomingShareCallCount += 1
    }
}

private final class MockSessionManager: SessionManaging {
    private let loggedIn: Bool
    private(set) var isLoggedInCallCount = 0

    init(isLoggedIn: Bool) {
        self.loggedIn = isLoggedIn
    }

    func isLoggedIn() -> Bool {
        isLoggedInCallCount += 1
        return loggedIn
    }
}




