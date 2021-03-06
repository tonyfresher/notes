//
//  CreateOrUpdateNoteOperation.swift
//  Notes
//
//  Created by Anton Fresher on 24.07.17.
//  Copyright © 2017 Anton Fresher. All rights reserved.
//

import Foundation
import CoreData
import CocoaLumberjack

class CreateOrUpdateNoteOperation: AsyncOperation<Void> {
    
    // PART: - Properties
    
    let note: Note
    
    let context: NSManagedObjectContext
    
    // PART: - Initialization
    
    init(note: Note, context: NSManagedObjectContext) {
        self.note = note
        self.context = context
    }
    
    // PART: - Work
    
    override func main() {
        context.perform { [weak self] in
            guard let sself = self else { return }
            
            do {
                let noteEntity = try NoteEntity.findOrCreateNoteEntity(matching: sself.note, in: sself.context)
                noteEntity.update(from: sself.note)
                
                try sself.context.save(recursively: true)
                
                sself.success?()
            } catch {
                DDLogError("Error while updating \(sself.note): \(error.localizedDescription)")
                sself.cancel()
            }
            
            sself.finish()
        }
    }
    
}
