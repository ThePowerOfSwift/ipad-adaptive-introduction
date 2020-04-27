//
//  PdfViewController.swift
//  Demo
//
//  Created by shiwei on 2020/4/27.
//  Copyright © 2020 shiwei. All rights reserved.
//

import UIKit
import PDFKit

class PdfViewController: UIViewController {

    @IBOutlet weak var pdfView: PDFView!
    @IBOutlet weak var thumbnailView: PDFThumbnailView!
    
    private var shouldUpdatePDFScrollPosition = true
    private let pdfDrawer = PDFDrawer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPDFView()
        
        let pdfDrawingGestureRecognizer = DrawingGestureRecognizer()
        pdfView.addGestureRecognizer(pdfDrawingGestureRecognizer)
        pdfDrawingGestureRecognizer.drawingDelegate = pdfDrawer
        pdfDrawer.pdfView = pdfView
        
        let fileURL = Bundle.main.url(forResource: "241_introducing_pdfkit_on_ios", withExtension: "pdf")!
        let pdfDocument = PDFDocument(url: fileURL)
        pdfView.document = pdfDocument
    }
    
    private func setupPDFView() {
        pdfView.displayDirection = .vertical
        pdfView.usePageViewController(true)
        pdfView.pageBreakMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        pdfView.autoScales = true
        pdfView.backgroundColor = view.backgroundColor!
        
        thumbnailView.pdfView = pdfView
        thumbnailView.thumbnailSize = CGSize(width: 100, height: 100)
        thumbnailView.layoutMode = .vertical
        thumbnailView.backgroundColor = view.backgroundColor
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if shouldUpdatePDFScrollPosition {
            fixPDFViewScrollPosition()
        }
        
    }
    
    private func fixPDFViewScrollPosition() {
        if let page = pdfView.document?.page(at: 0) {
            pdfView.go(to: PDFDestination(page: page, at: CGPoint(x: 0, y: page.bounds(for: pdfView.displayBox).size.height)))
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        shouldUpdatePDFScrollPosition = false
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        pdfView.autoScales = true
    }

}
