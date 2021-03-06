//
//  FetchNotebookOperation.swift
//  Notes
//
//  Created by Anton Fresher on 24.07.17.
//  Copyright © 2017 Anton Fresher. All rights reserved.
//

import Foundation
import CoreData
import CocoaLumberjack

class FetchNotebookOperation: AsyncOperation<Notebook> {
    
    // PART: - Properties
    
    let notebook: Notebook
    
    let context: NSManagedObjectContext
    
    // PART: - Initialization
    
    init(notebook: Notebook, context: NSManagedObjectContext, success: @escaping (Notebook) -> ()) {
        self.notebook = notebook
        self.context = context
        
        super.init()
        
        self.success = success
    }
    
    // PART: - Work
    
    override func main() {
        context.perform { [weak self] in
            guard let sself = self else { return }
            
            do {
                let notebookEntity = try NotebookEntity.findOrCreateNotebookEntity(matching: sself.notebook, in: sself.context)

                try sself.context.save(recursively: true)
                
                if let notebook = notebookEntity.toNotebook() {
                    sself.success?(notebook)
                }
            } catch {
                DDLogError("Error while fetching notebook(UUID: \(sself.notebook.uuid)): \(error.localizedDescription)")
                sself.cancel()
            }
            
            sself.finish()
        }
    }
    
}
