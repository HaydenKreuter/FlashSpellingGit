//
//  ViewTestViewController.swift
//  FlashSpelling
//
//  Created by Hayden Kreuter on 7/28/22.
//  Copyright © 2022 Hayden Kreuter. All rights reserved.
//

import UIKit
import PDFKit
import CoreData

class ViewTestViewController: UIViewController {
    var pdfData: Data!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Add PDFView to view controller.
        let pdfView = PDFView(frame: self.view.bounds)
        pdfView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(pdfView)
        
        // Fit content in PDFView.
        pdfView.autoScales = true
        
        // Load Sample.pdf file from app bundle.
        pdfView.document = PDFDocument(data: pdfData)
    }

    @IBAction func sharePressed(_ sender: UIBarButtonItem) {
        // presents activity controller to ask where to send
        let activityController = UIActivityViewController(activityItems: [pdfData!], applicationActivities: nil)
        activityController.popoverPresentationController?.barButtonItem = sender
        self.present(activityController, animated: true, completion: nil)
    }
    

    
    
    
}
