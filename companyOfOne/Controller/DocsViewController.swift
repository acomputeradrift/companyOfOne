//
//  DocsViewController.swift
//  companyOfOne
//
//  Created by Jamie on 2018-11-03.
//  Copyright © 2018 Jamie. All rights reserved.
//

import UIKit

class DocsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITabBarControllerDelegate , UITabBarDelegate, UISearchBarDelegate {
    
    //MARK: - Enums
    enum ExportMode {
        case on
        case off
    }
    
    enum SelectedMode {
        case noneSelected
        case someSelected
        case allSelected
    }
    
    //MARK: - Instance Variables
    
    var exportMode:ExportMode = .off
    var selectedMode:SelectedMode = .noneSelected
    
    //MARK: - Property Observers
    var exportCountObserverForUIUpdates: Int = 0 {
        didSet {
            switch exportCountObserverForUIUpdates {
            case 0 :
                if exportMode == .on{
                    print("0 selected for export")
                }
                filterButton.title = "Select All"
                selectedMode = .noneSelected
                if exportMode == .off {
                    pressedShareButton.tintColor = nil
                }else{
                    pressedShareButton.tintColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1).withAlphaComponent(0.5)
                }
            // TODO: - TO FIX: What happens when there is only one items --> Thread 1: Fatal error: Can't form Range with upperBound < lowerBound
            case 1...(ArrayHandler.sharedInstance.documentArray.count-1):
                if exportMode == .on{
                    print("some selected for export")
                }
                filterButton.title = "Select All"
                pressedShareButton.tintColor = nil
                selectedMode = .someSelected
            case ArrayHandler.sharedInstance.documentArray.count:
                if exportMode == .on{
                    print("all selected for export")
                }
                pressedShareButton.tintColor = nil
                filterButton.title = "Deselect All"
                selectedMode = .allSelected
            default: return
            }
        }
    }
    
    //MARK: - Outlets
    
    @IBOutlet weak var documentSearchBar: UISearchBar!
    @IBOutlet weak var filterButton: UIBarButtonItem!
    @IBOutlet weak var pressedShareButton: UIBarButtonItem!
    @IBOutlet weak var docTableView: UITableView!
    @IBOutlet weak var navBar: UINavigationBar!
    
    let document = Document()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("from viewDidLoad:")
        registerNibs()
        updateViewControllerForSelectedTab()
        setupTableViewForPopulation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("from viewWillAppear:")
        navigationController!.isNavigationBarHidden = true
        updateViewControllerForSelectedTab()
        setupTableViewForPopulation()
    }
    
    //MARK: - Custom Functions For Loading View
    
    func updateViewControllerForSelectedTab(){
       if let selectedTabIndex = tabBarController?.selectedIndex {
        //TODO: - TO FIX: This index is not working correctly
            print("selected tab index: \(selectedTabIndex )")
            switch selectedTabIndex  {
            case 0: self.navBar.topItem?.title = "Home"
            case 1: self.navBar.topItem?.title = "Documents"
            case 2:  self.navBar.topItem?.title = "Snail Mail"
            case 3:  self.navBar.topItem?.title = "Personal Receipts"
            default: break
            }
        }
            //docTableView.reloadData()
        }
    
    func setupTableViewForPopulation(){
        //clear the export Array and deselect all items/cells
        deSelectAllForExport()
        ArrayHandler.sharedInstance.exportArray.removeAll()
        exportMode = .off
        selectedMode = .noneSelected
        // docTableView.reloadData()
    }
    
    func registerNibs(){
        let nib = UINib(nibName: "DocViewTableViewCell", bundle: nil)
        docTableView.register(nib, forCellReuseIdentifier: "docViewTableViewCell")
    }
    
    //MARK: - Seach Bar Delegates
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        documentSearchBar.showsCancelButton = true
        documentSearchBar.showsScopeBar = true
        documentSearchBar.scopeButtonTitles = ["Title/Tag", "Category", "Subcategory"]
        documentSearchBar.selectedScopeButtonIndex = 0
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        FetchHandler.fetchFilteredDocuments(searchTerm: searchText)
        //FetchHandler.currentFilter = searchText
       // document.retrieveAllDocuments(filteredBy: "\(FetchHandler.currentFilter)")
        docTableView.reloadData()
        //print("current filter in textDidChange: \(FetchHandler.currentFilter)")
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //print("Beginning complete search from SearchButtonClicked")
        completeSearch()
        //print("Ending complete search from SearchButtonClicked")
        
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        //resetSearchBar()
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        //print("Beginning reset search from CancelButtonClicked")
        resetSearch()
        //print("Ending reset search from CancelButtonClicked")
    }
    
    //MARK: - Search Bar Custom Functions
    
    func resetSearch(){
        documentSearchBar.endEditing(true)
        documentSearchBar.showsCancelButton = false
        documentSearchBar.showsScopeBar = false
        resignFirstResponder()
        updateViewControllerForSelectedTab()
        
    }
    
    func completeSearch(){
        //document.retrieveAllDocuments(filteredBy: "\(FetchHandler.currentFilter)")
        documentSearchBar.endEditing(true)
        docTableView.reloadData()
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
        } else {
            cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
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
            FetchHandler.deleteDocumentAndFetchFilteredDocuments(document: ArrayHandler.sharedInstance.documentArray[indexPath.row])
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
                //this propery observer updates state and UI
                exportCountObserverForUIUpdates = ArrayHandler.sharedInstance.exportArray.count
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
            //this propery observer updates state and UI
            exportCountObserverForUIUpdates = ArrayHandler.sharedInstance.exportArray.count
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
        }
    }
    
    @IBAction func filterButtonPressed(_ sender: UIBarButtonItem) {
        switch exportMode {
        case .on:
            switch selectedMode {
            case .noneSelected:
                selectAllForExport()
            case .someSelected:
                selectAllForExport()
            case.allSelected:
                deSelectAllForExport()
            }
        case .off:
            print("run the date filter function here")
        }
    }
    
    //MARK: - Export Functions
    
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
        //this propery observer updates state and UI
        exportCountObserverForUIUpdates = ArrayHandler.sharedInstance.exportArray.count
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
        ///this propery observer updates state and UI
        exportCountObserverForUIUpdates = ArrayHandler.sharedInstance.exportArray.count
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
    
    //MARK: - Segue Functions
    
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


