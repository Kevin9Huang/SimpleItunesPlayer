//
//  XCTestCase+TrackMemoryLeaks.swift
//  SimpleItunesPlayerTests
//
//  Created by CMP2024008 on 12/03/25.
//

import Foundation
import XCTest

extension XCTestCase {
    /// Given an instance, it will track at the end of every test case if it has been deallocated alerting about potential memory leak.
    func trackForMemoryLeaks(
        _ instance: AnyObject,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(
                instance, "Instance is not dealocated. Potential memory leak",
                file: file,
                line: line
            )
        }
    }
}
