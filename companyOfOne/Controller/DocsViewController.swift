//
//  DocsViewController.swift
//  companyOfOne
//
//  Created by Jamie on 2018-11-03.
//  Copyright © 2018 Jamie. All rights reserved.
//

import UIKit

class DocsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITabBarControllerDelegate , UITabBarDelegate{
    
    enum ExportMode {
        case on
        case off
    }
    
    enum SelectedMode {
        case noneSelected
        case someSelected
        case allSelected
    }
    
    var exportMode:ExportMode = .off
    var selectedMode:SelectedMode = .noneSelected
    var exportCountForObservation: Int = 0 {
        didSet {
            switch exportCountForObservation {
            case 0 :
                print("0 selected")
                filterButton.title = "Select All"
                selectedMode = .noneSelected
                if exportMode == .off {
                    pressedShareButton.tintColor = nil
                }else{
                    pressedShareButton.tintColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1).withAlphaComponent(0.5)
                }
                
            case 1...(ArrayHandler.sharedInstance.documentArray.count-1):
                print("some selected")
                filterButton.title = "Select All"
                pressedShareButton.tintColor = nil
                selectedMode = .someSelected
                
            case ArrayHandler.sharedInstance.documentArray.count:
                print("all selected")
                pressedShareButton.tintColor = nil
                filterButton.title = "Deselect All"
                selectedMode = .allSelected
            default: return
            }
        }
    }
    
    @IBOutlet weak var filterButton: UIBarButtonItem!
    @IBOutlet weak var pressedShareButton: UIBarButtonItem!
    @IBOutlet weak var docTableView: UITableView!
    @IBOutlet weak var navBar: UINavigationBar!
    
    let document = Document()

    override func viewDidLoad() {
        super.viewDidLoad()
        updateViewControllerForSelectedTab()
        registerNibs()
        setupTableViewForPopulation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController!.isNavigationBarHidden = true
        setupTableViewForPopulation()
    }
    
    //MARK: - Custom Functions
    
    func updateViewControllerForSelectedTab(){
        if let selectedTabIndex = tabBarController?.selectedIndex {
            switch selectedTabIndex {
            case 1: self.navBar.topItem?.title = "Documents"
            case 2:  self.navBar.topItem?.title = "Snail Mail"
            case 3:  self.navBar.topItem?.title = "Personal Receipts"
            default: break
            }
        }
    }
    
    func setupTableViewForPopulation(){
        document.retrieveAllDocuments(filteredBy: "\(FetchHandler.sharedInstance.currentFilter)")
        //clear the export Array and deselect all items/cells
        deSelectAllForExport()
        ArrayHandler.sharedInstance.exportArray.removeAll()
        exportMode = .off
        selectedMode = .noneSelected
        docTableView.reloadData()
    }
    
    func registerNibs(){
        let nib = UINib(nibName: "DocViewTableViewCell", bundle: nil)
        docTableView.register(nib, forCellReuseIdentifier: "docViewTableViewCell")
    }
    
    //MARK: - TableView Delegates
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ArrayHandler.sharedInstance.documentArray.count//?? 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "docViewTableViewCell")! as! DocViewTableViewCell
        cell.isSelectedForExport = ArrayHandler.sharedInstance.documentArray[indexPath.row].isSelectedForExport
        if cell.isSelectedForExport{
            cell.accessoryType = UITableViewCell.AccessoryType.checkmark
            //            print("in cellForRow Disclosure\(cell.isSelectedForExport )")
            
        } else {
            cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
            //            print("in cellForRow Disclosure\(cell.isSelectedForExport )")
        }
        
        cell.titleTagLabel.text = ArrayHandler.sharedInstance.documentArray[indexPath.row].titleTag
        cell.categoryLabel.text = ArrayHandler.sharedInstance.documentArray[indexPath.row].toCategory?.name
        cell.subCategoryLabel.text = ArrayHandler.sharedInstance.documentArray[indexPath.row].toSubCategory?.name
        cell.dateLabel.text = ArrayHandler.sharedInstance.documentArray[indexPath.row].documentDate?.format()
        //cell.occurenceLabel.text = document?.occurrence?
        if let imageData = ArrayHandler.sharedInstance.documentArray[indexPath.row].pictureData {
            cell.docImageView.image = UIImage(data: imageData)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let documentToDelete = ArrayHandler.sharedInstance.documentArray[indexPath.row]
            document.deleteDocument(document: documentToDelete)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch exportMode {
        case .on:
            //update UI, update model and add to exportArray
            if let cell = tableView.cellForRow(at: indexPath as IndexPath) {
                cell.accessoryType = .checkmark
                ArrayHandler.sharedInstance.documentArray[indexPath.row].isSelectedForExport = true
                ArrayHandler.sharedInstance.exportArray.append(ArrayHandler.sharedInstance.documentArray[indexPath.row])
                exportCountForObservation = ArrayHandler.sharedInstance.exportArray.count
//                print("(from select) documentArray count: \(ArrayHandler.sharedInstance.documentArray.count)")
//                print("(from select) exportArray count: \(ArrayHandler.sharedInstance.exportArray.count)")
            }
        case .off:
            performSegue(withIdentifier: "toEditViewControllerFromDocs", sender: self)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        //update UI, update model and remove from exportArray
        if let cell = tableView.cellForRow(at: indexPath as IndexPath) {
            cell.accessoryType = .disclosureIndicator
            ArrayHandler.sharedInstance.documentArray[indexPath.row].isSelectedForExport = false
            if let index = ArrayHandler.sharedInstance.exportArray.index(of: ArrayHandler.sharedInstance.documentArray[indexPath.row]) {
                ArrayHandler.sharedInstance.exportArray.remove(at: index)
            }
            exportCountForObservation = ArrayHandler.sharedInstance.exportArray.count
//            print("(from deSelect) documentArray count: \(ArrayHandler.sharedInstance.documentArray.count)")
//            print("(from deSelect) exportArray count: \(ArrayHandler.sharedInstance.exportArray.count)")
            
        }
    }
    
    //MARK: - Actions
    
    @IBAction func shareButton(_ sender: UIBarButtonItem) {
        switch exportMode {
        case .off:
            exportMode = .on

            pressedShareButton.image = nil
            pressedShareButton.tintColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1).withAlphaComponent(0.5)
            pressedShareButton.title = "Export"
            filterButton.image = nil
            
            
            docTableView?.allowsMultipleSelection = true

        case .on:
            switch selectedMode {
            case .noneSelected:
                print("export mode on, none selected :  run the alert function ")
            case .someSelected:
                print("export mode on, \(ArrayHandler.sharedInstance.exportArray.count) items selected :  run the export function ")
            case .allSelected:
                print("export mode on, \(ArrayHandler.sharedInstance.exportArray.count) items selected:  run the export function ")
            }
            //this is for export mode when it is changed to off after export
//            let allCells = docTableView.visibleCells
//            for cell in allCells {
//                cell.accessoryType = .disclosureIndicator
//            }
//            pressedShareButton.tintColor = nil
//            filterButton.title = nil
//            filterButton.image = #imageLiteral(resourceName: "filter")
//            docTableView?.allowsMultipleSelection = false
        }
    }
    
    func updateUIForNoneSelected(){
        pressedShareButton.tintColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1).withAlphaComponent(0.5)
        filterButton.title = "Select All"
    }
    
    @IBAction func filterButtonPressed(_ sender: UIBarButtonItem) {
        switch exportMode {
        case .on:
            print("exportMode is on, in filterButtonPressed")
            switch selectedMode {
            case .noneSelected:
                print("none selected, this press selects all")
                selectAllForExport()
            case .someSelected:
                print("some selected, this press selects all")
                selectAllForExport()
            case.allSelected:
                deSelectAllForExport()
                print("all selected, this press deselects all")
            }
        case .off:
            print("exportMode is off, in filterButtonPressed")
            print("date filter code would run now")
        }
    }
    
    func selectAllForExport(){
        //this sets the model objects isSelectedForExport bool and adds to the exportArray
        let totalRows = docTableView.numberOfRows(inSection: 0)
        for item in ArrayHandler.sharedInstance.documentArray {
            if item.isSelectedForExport == false {
                item.isSelectedForExport = true
                ArrayHandler.sharedInstance.exportArray.append(item)
            }
        }
        docTableView.reloadData()
         //this selects all of the cells in the current display
        for row in 0..<totalRows {
            docTableView.selectRow(at: NSIndexPath(row: row, section: 0) as IndexPath, animated: false, scrollPosition: UITableView.ScrollPosition.none)
        }
        //this updates state and UI
//        selectedMode = .allSelected
        exportCountForObservation = ArrayHandler.sharedInstance.exportArray.count
//        filterButton.title = "Deselect All"
//        print("(from select all) documentArray count: \(ArrayHandler.sharedInstance.documentArray.count)")
//        print("(from select all) exportArray count: \(ArrayHandler.sharedInstance.exportArray.count)")
    }
    
    func deSelectAllForExport(){
        //this clears the model objects isSelectedForExport bool and removes the exportArray
        let totalRows = docTableView.numberOfRows(inSection: 0)
        for item in ArrayHandler.sharedInstance.documentArray {
            item.isSelectedForExport = false
        }
        ArrayHandler.sharedInstance.exportArray.removeAll()
        docTableView.reloadData()
        
        //this deselects all of the cells in the current display
        for row in 0..<totalRows {
            docTableView.deselectRow(at: NSIndexPath(row: row, section: 0) as IndexPath, animated:false)
        }
        //this updates state and UI
       // selectedMode = .noneSelected
        exportCountForObservation = ArrayHandler.sharedInstance.exportArray.count
        //filterButton.title = "Select All"
//        print("(from deSelect all) documentArray count: \(ArrayHandler.sharedInstance.documentArray.count)")
//        print("(from deSelect all) exportArray count: \(ArrayHandler.sharedInstance.exportArray.count)")
    }
    
    func createPDFFromSelected(){
        //        guard let image = UIImage(named: "testDoc") else { return }
        //        let activityController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        //        activityController.completionWithItemsHandler = { (nil, completed, _, error) in
        //            if completed {
        //                print("completed")
        //            } else {
        //                print("cancelled")
        //            }
        //        }
        //        present(activityController, animated: true) {
        //            print("presented")
        //        }
    }
    
    //MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEditViewControllerFromDocs" {
            if let indexPath = self.docTableView.indexPathForSelectedRow {
                let nextController = segue.destination as! EditViewController
                nextController.fromDocsViewController = true
                nextController.currentTableViewIndexPathRow = indexPath.row
                if let titleTag = ArrayHandler.sharedInstance.documentArray[indexPath.row].titleTag {
                    nextController.currentTitleTag = titleTag
                }
                if let categoryName = ArrayHandler.sharedInstance.documentArray[indexPath.row].toCategory?.name {
                    nextController.categorySubCategoryLabels.insert(categoryName, at: 0)
                }
                if let subCategoryName = ArrayHandler.sharedInstance.documentArray[indexPath.row].toSubCategory?.name {
                    nextController.categorySubCategoryLabels.insert(subCategoryName, at: 1)
                }
                if let documentDate = ArrayHandler.sharedInstance.documentArray[indexPath.row].documentDate{
                    nextController.currentDate = documentDate
                }
                if let imageData = ArrayHandler.sharedInstance.documentArray[indexPath.row].pictureData {
                    if let image = UIImage(data: imageData) {
                        nextController.currentImage = image
                    }
                }
            }
        }
    }
}


