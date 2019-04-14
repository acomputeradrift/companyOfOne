//
//  ReceiptsViewController.swift
//  companyOfOne
//
//  Created by Jamie on 2018-12-28.
//  Copyright © 2018 Jamie. All rights reserved.
//

import UIKit

class ReceiptsViewController: UIViewController, MySegueDelegate {
    
    
 
    
    
    //This is the template for the new way of doing multiple view controllers sharing a view.
    
    //MARK: - Constants
    let customView = CommonDisplayView()
    var createdIdentifierForPDFSegue = String()
    var createdIdentifierForEditSegue = String()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        createTotalView()
        registerTableViewNibs()
        updateNavBarTitleAndHiddenStatus()
        customView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateTableView()
        updateNavBarTitleAndHiddenStatus()
        confirmAllValues()
    }
    
    func createTotalView(){
        if let bounds = parent?.view.bounds {
            customView.frame = bounds
        }
        self.view.addSubview(customView)
        customView.exportMode = .off
    }
    
    func registerTableViewNibs(){
        let nib = UINib(nibName: "CommonTableViewCell", bundle: nil)
        customView.commonTableView.register(nib, forCellReuseIdentifier: "commonTableViewCell")
    }
    
    func updateNavBarTitleAndHiddenStatus(){
        navigationController!.isNavigationBarHidden = true
        customView.commonNavBar.topItem?.title = "Personal Receipts"
        ///this allows the name of the nav to be used to identify the segue, hopefully so the segue code can be reusable
        if let navTitle = customView.commonNavBar.topItem?.title {
            createdIdentifierForPDFSegue =  "\(navTitle)toPDFViewController"
            createdIdentifierForEditSegue =  "\(navTitle)toEditViewController"
        }
    }
    
    func updateTableView(){
        customView.setupTableViewForPopulation()
    }
    
    func confirmAllValues(){
        if customView.debugMode{
            print("\(self) viewWillAppear confirming export mode is \(customView.exportMode).\n")
            print("\(self) viewWillAppear confirming selected mode is \(customView.selectedMode).\n")
            print("\(self) viewWillAppear confirming that \(customView.exportCountObserverForUIUpdates) documents are selected for export\n")
        }
    }
    
    
        //MARK: - Segue Functions
    
    
    func segueToEditViewControllerCalled() {
        performSegue(withIdentifier: "\(createdIdentifierForEditSegue)", sender: self)
    }
    func segueToPDFViewControllerCalled() {
        performSegue(withIdentifier: "\(createdIdentifierForPDFSegue)", sender: self)
    }
    
    //if segue.identifier == "toEditViewControllerFromReceipts" {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "\(createdIdentifierForEditSegue)" {
            if let indexPath = customView.commonTableView.indexPathForSelectedRow {
                let nextController = segue.destination as! EditViewController
                nextController.fromDocsViewController = true
                nextController.currentTableViewIndexPathRow = indexPath.row
                if let titleTag = ArrayHandler.sharedInstance.completeDocumentArray[indexPath.row].titleTag {
                    nextController.currentTitleTag = titleTag
                }
                if let categoryName = ArrayHandler.sharedInstance.completeDocumentArray[indexPath.row].toCategory?.name {
                    nextController.categorySubCategoryLabels[0] = categoryName
                }
                if let subCategoryName = ArrayHandler.sharedInstance.completeDocumentArray[indexPath.row].toSubCategory?.name {
                    nextController.categorySubCategoryLabels[1] = subCategoryName
                }
                if let documentDate = ArrayHandler.sharedInstance.completeDocumentArray[indexPath.row].documentDate{
                    nextController.currentDate = documentDate
                }
                if let imageData = ArrayHandler.sharedInstance.completeDocumentArray[indexPath.row].pictureData {
                    if let image = UIImage(data: imageData) {
                        nextController.currentImage = image
                    }
                }
                if let occurrence = ArrayHandler.sharedInstance.completeDocumentArray[indexPath.row].toOccurrence{
                    if let title = occurrence.title {
                        nextController.occurrenceLabels[0] = title
                    }
                    if let formattedOccurrenceDate = occurrence.occurrenceDate?.format() {
                        nextController.occurrenceLabels[1] = formattedOccurrenceDate
                    }
                }
                //                if let occurrenceDate = ArrayHandler.sharedInstance.documentArray[indexPath.row].toOccurrence.occurrenceDate{
                //                    let formattedOccurrenceDate = occurrenceDate?.format()
                //                    nextController.occurrenceLabels.insert(formattedOccurrenceDate, at: 1)
                //                }
            }
            
        }
        if segue.identifier == "\(createdIdentifierForPDFSegue)" {
            let nextController = segue.destination as! PDFViewController
            nextController.documentsToDisplay = ArrayHandler.sharedInstance.exportArray
        }
//        if segue.identifier == "\(self)toPDFViewController" {
//            let nextController = segue.destination as! PDFViewController
//            nextController.documentsToDisplay = ArrayHandler.sharedInstance.exportArray
//        }
    }
}

