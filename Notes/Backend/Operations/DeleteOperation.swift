//
//  DeleteOperation.swift
//  Notes
//
//  Created by Anton Fresher on 25.07.17.
//  Copyright © 2017 Anton Fresher. All rights reserved.
//

import Foundation

class DeleteOperation: AsyncOperation<Note> {
    
    // PART: - Properties
    
    let note: Note
    
    // PART: - Initialization
    
    init(note: Note) {
        self.note = note
    }
    
    // PART: - Work
    
    override func main() {
        let conversion: (Any) -> Note? = { json in
            // TODO: implement
        }
        
        BackendRequests.performDataTask(method: "DELETE",
                                        request: BackendRequests.delete(note),
                                        using: conversion,
                                        in: self)

    }
    
}