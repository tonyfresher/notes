//
//  ListTableViewController.swift
//  Notes
//
//  Created by Anton Fresher on 12.07.17.
//  Copyright © 2017 Anton Fresher. All rights reserved.
//

import UIKit
import CocoaLumberjack
import CoreData

class ListTableViewController: UITableViewController {
    
    // PART: - Properties
    
    private var notebook = Notebook(uuid: "3392911E-D663-46AE-85A9-F1CAA702AFE0")
    
    // PART: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let coreDataManager = (UIApplication.shared.delegate as! AppDelegate).coreDataManager        
        coreDataOperationsManager = CoreDataOperationsManager(coreDataManager: coreDataManager)
        
        self.splitViewController?.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: configuring UI
        splitViewController?.preferredDisplayMode = UISplitViewControllerDisplayMode.allVisible
        
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        
        prepareNotebook()
    }
    
    // PART: - UITableViewDataSource conformance
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? notebook.size : 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ListTableViewCell.reuseIdentifier, for: indexPath)
        
        guard let noteCell = cell as? ListTableViewCell else { return cell }
        
        noteCell.note = notebook[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row < notebook.size
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            // TODO: MAKE POPUP VIEW TO ASK IF THE USER SURE
            let note = notebook.remove(at: indexPath.row)
            
            let updateCoreData = coreDataOperationsManager.remove(note, from: notebook)
            Dispatcher.dispatchToCoreData(updateCoreData)
            
            let updateUI = UITableViewOperations.delete(from: tableView, at: [indexPath])
            updateUI.addDependency(updateCoreData)
            Dispatcher.dispatchToMain(updateUI)
        }
    }
    
    // PART: - Segues handling
    
    static let createNoteSegueIdentifier = "Create Note"
    
    static let editNoteSegueIdentifier = "Edit Note"
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailViewController = segue.destination.contents as? DetailViewController {
            if segue.identifier == ListTableViewController.createNoteSegueIdentifier {
                detailViewController.state = .creation
                detailViewController.note = Note()
            } else if segue.identifier == ListTableViewController.editNoteSegueIdentifier,
                let noteIndex = tableView.indexPathForSelectedRow?.row {
                detailViewController.state = .editing
                detailViewController.note = notebook[noteIndex]
            }
        }
    }
    
    // MARK: unwind segue
    @IBAction private func saveNoteAfterEditing(from segue: UIStoryboardSegue) {
        guard let detail = segue.source as? DetailViewController, let note = detail.note else { return }
        
        switch detail.state {
        case .creation:
            notebook.add(note: note)
            
            let updateCoreData = coreDataOperationsManager.add(note, to: notebook)
            Dispatcher.dispatchToCoreData(updateCoreData)
            
            let indexPaths = [IndexPath(row: notebook.size - 1, section: 0)]
            let updateUI = UITableViewOperations.insert(to: tableView, at: indexPaths)
            updateUI.addDependency(updateCoreData)
            Dispatcher.dispatchToMain(updateUI)
            
            DDLogDebug("\(note) was saved to local notebook")
            
        case .editing:
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            
            notebook[indexPath.row] = note
            
            let updateCoreData = coreDataOperationsManager.update(note)
            Dispatcher.dispatchToCoreData(updateCoreData)
            
            let updateUI = UITableViewOperations.reload(in: tableView, at: [indexPath])
            updateUI.addDependency(updateCoreData)
            Dispatcher.dispatchToMain(updateUI)
            
            DDLogDebug("\(note) was locally updated")
            
        default: break
        }
    }
    
    // PART: - Main preparation
    
    private func prepareNotebook() {
        let fetch = coreDataOperationsManager.fetch(notebook: notebook, success: { [weak self] notebook in
            guard let sself = self else { return }
            
            let eraseOutdated = EraseOutdatedOperation(notebook: notebook, manager: sself.coreDataOperationsManager)
            eraseOutdated.success = { [weak self] notebook in
                self?.notebook = notebook
            }
            
            Dispatcher.dispatchToBackground(eraseOutdated)
        })
        let updateUI = UITableViewOperations.reload(sections: [0], in: tableView) // QUESTION: async?
        
        updateUI.addDependency(fetch)
        
        Dispatcher.dispatchToCoreData(fetch)
        Dispatcher.dispatchToMain(updateUI)
    }

    // PART: - Operations with Core Data
    
    private var coreDataOperationsManager: CoreDataOperationsManager!
    
    private func add(_ note: Note, to notebook: Notebook) {
        let operation = coreDataOperationsManager.add(note, to: notebook)
        Dispatcher.dispatchToCoreData(operation)
    }
    
    private func update(_ note: Note) {
        let operation = coreDataOperationsManager.update(note)
        Dispatcher.dispatchToCoreData(operation)
    }
    
    private func remove(_ note: Note, from notebook: Notebook) {
        let operation = coreDataOperationsManager.remove(note, from: notebook)
        Dispatcher.dispatchToCoreData(operation)
    }

}

extension ListTableViewController: UISplitViewControllerDelegate {
    
    func splitViewController(_ splitViewController: UISplitViewController,
                             collapseSecondary secondaryViewController: UIViewController,
                             onto primaryViewController: UIViewController) -> Bool {
        if primaryViewController.contents == self {
            if let noteDetailViewController =
                secondaryViewController.contents as? DetailViewController, noteDetailViewController.state == .blank {
                return true
            }
        }
        
        return false
    }
    
}

extension UIViewController {
    
    fileprivate var contents: UIViewController {
        if let navigationController = self as? UINavigationController {
            return navigationController.visibleViewController ?? self
        } else {
            return self
        }
    }
    
}
