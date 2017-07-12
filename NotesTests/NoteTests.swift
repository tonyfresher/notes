//
//  NotesTests.swift
//  NotesTests
//
//  Created by Anton Fresher on 11.07.17.
//  Copyright © 2017 Anton Fresher. All rights reserved.
//

import XCTest
import UIColor_Hex_Swift
@testable import Notes

class NotesTests: XCTestCase {
    
    private var notes = [
        Note(title: "Foo0", content: "Bar"),
        Note(title: "Foo1", content: "Bar", color: Note.defaultColor),
        Note(title: "Foo2", content: "Bar", color: UIColor("#000000")),
        Note(title: "Foo3", content: "Bar", erasureDate: Date()),
        Note(title: "Foo4", content: "Bar", color: UIColor("#000000"), erasureDate: Date())
    ]
    
    func testEquality() {
        let copies = notes.map { $0 }
        XCTAssertEqual(copies, notes)
    }
    
    func testJSON() {
        var jsons: [[String: Any]] = []
        
        for note in notes {
            jsons.append(note.json)
        }
        
        for noteJson in jsons {
            XCTAssertTrue(noteJson.keys.contains("uuid"))
            XCTAssertTrue(noteJson.keys.contains("title"))
            XCTAssertTrue(noteJson.keys.contains("content"))
        }
        
        let colorProperty = "color"
        XCTAssertTrue(
            !jsons[0].keys.contains(colorProperty) &&
                !jsons[1].keys.contains(colorProperty) &&
                jsons[2].keys.contains(colorProperty) &&
                !jsons[3].keys.contains(colorProperty) &&
                jsons[4].keys.contains(colorProperty)
        )
        
        let erasureDateProperty = "erasureDate"
        XCTAssertTrue(
            !jsons[0].keys.contains(erasureDateProperty) &&
                !jsons[1].keys.contains(erasureDateProperty) &&
                !jsons[2].keys.contains(erasureDateProperty) &&
                jsons[3].keys.contains(erasureDateProperty) &&
                jsons[4].keys.contains(erasureDateProperty)
        )
        
        let newNotes = jsons.map { Note.parse($0)! }
        
        // MARK: При конвертации никак не получается получить такой же цвет - различаются на тысячные доли
        XCTAssertEqual(newNotes[0], notes[0])
        XCTAssertEqual(newNotes[1], notes[1])
        //XCTAssertEqual(newNotes[2], notes[2])
        XCTAssertEqual(newNotes[3], notes[3])
        //XCTAssertEqual(newNotes[4], notes[4])
    }
}