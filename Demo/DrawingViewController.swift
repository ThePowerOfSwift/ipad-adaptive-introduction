//
//  DrawingViewController.swift
//  Demo
//
//  Created by shiwei on 2020/4/27.
//  Copyright © 2020 shiwei. All rights reserved.
//

import UIKit
import PencilKit

class DrawingViewController: UIViewController {
    
    @IBOutlet weak var canvasView: PKCanvasView!
    @IBOutlet weak var pencilFingerBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var undoBarButtonitem: UIBarButtonItem!
    @IBOutlet weak var redoBarButtonItem: UIBarButtonItem!
    
    static let canvasOverscrollHeight: CGFloat = 500
    
    var dataModelController: DataModelController!
    
    var hasModifiedDrawing = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        canvasView.delegate = self
        canvasView.drawing = dataModelController.drawings[0]
        canvasView.alwaysBounceVertical = true
        canvasView.allowsFingerDrawing = false
        
        if let window = parent?.view.window, let toolPicker = PKToolPicker.shared(for: window) {
            toolPicker.setVisible(true, forFirstResponder: canvasView)
            toolPicker.addObserver(canvasView)
            toolPicker.addObserver(self)
            
            updateLayout(for: toolPicker)
            canvasView.becomeFirstResponder()
        }
        
        navigationItem.leftItemsSupplementBackButton = true
        
        parent?.view.window?.windowScene?.screenshotService?.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let canvasScale = canvasView.bounds.width / DataModel.canvasWidth
        canvasView.minimumZoomScale = canvasScale
        canvasView.maximumZoomScale = canvasScale
        canvasView.zoomScale = canvasScale
        
        // Scroll to the top.
        updateContentSizeForDrawing()
        canvasView.contentOffset = CGPoint(x: 0, y: -canvasView.adjustedContentInset.top)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Update the drawing in the data model, if it has changed.
        if hasModifiedDrawing {
            dataModelController.updateDrawing(canvasView.drawing, at: 0)
        }
        
        // Remove this view controller as the screenshot delegate.
        view.window?.windowScene?.screenshotService?.delegate = nil
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    @IBAction func toggleFingerPencilDrawing(_ sender: Any) {
        canvasView.allowsFingerDrawing.toggle()
        pencilFingerBarButtonItem.title = canvasView.allowsFingerDrawing ? "Finger" : "Pencil"
    }
    
    func setNewDrawingUndoable(_ newDrawing: PKDrawing) {
        let oldDrawing = canvasView.drawing
        undoManager?.registerUndo(withTarget: self) {
            $0.setNewDrawingUndoable(oldDrawing)
        }
        canvasView.drawing = newDrawing
    }
    
    func updateContentSizeForDrawing() {
        let drawing = canvasView.drawing
        let contentHeight: CGFloat
        
        if !drawing.bounds.isNull {
            contentHeight = max(canvasView.bounds.height, (drawing.bounds.maxY + DrawingViewController.canvasOverscrollHeight) * canvasView.zoomScale)
        } else {
            contentHeight = canvasView.bounds.height
        }
        
        canvasView.contentSize = CGSize(width: DataModel.canvasWidth * canvasView.zoomScale, height: contentHeight)
    }
    
    func updateLayout(for toolPicker: PKToolPicker) {
        let obscuredFrame = toolPicker.frameObscured(in: view)
        
        if obscuredFrame.isNull {
            canvasView.contentInset = .zero
            navigationItem.leftBarButtonItems = []
        } else {
            canvasView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: view.bounds.maxY - obscuredFrame.minY, right: 0)
            navigationItem.leftBarButtonItems = [undoBarButtonitem, redoBarButtonItem]
        }
    }

}

extension DrawingViewController: PKCanvasViewDelegate {
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        hasModifiedDrawing = true
        updateContentSizeForDrawing()
    }
}

extension DrawingViewController: PKToolPickerObserver {
    func toolPickerFramesObscuredDidChange(_ toolPicker: PKToolPicker) {
        updateLayout(for: toolPicker)
    }
    
    func toolPickerVisibilityDidChange(_ toolPicker: PKToolPicker) {
        updateLayout(for: toolPicker)
    }
}

extension DrawingViewController: UIScreenshotServiceDelegate {
    func screenshotService(_ screenshotService: UIScreenshotService, generatePDFRepresentationWithCompletion completionHandler: @escaping (Data?, Int, CGRect) -> Void) {
        let drawing = canvasView.drawing
        let visibleRect = canvasView.bounds
        
        let pdfWidth = DataModel.canvasWidth
        let pdfHeight = drawing.bounds.maxY + 100
        let canvasContentSize = canvasView.contentSize.height - DrawingViewController.canvasOverscrollHeight
        
        let xOffsetInPDF = pdfWidth - (pdfWidth * visibleRect.minX / canvasView.contentSize.width)
        let yOffsetInPDF = pdfHeight - (pdfHeight * visibleRect.maxY / canvasContentSize)
        let rectWidthInPDF = pdfWidth * visibleRect.width / canvasView.contentSize.width
        let rectHeightInPDF = pdfHeight * visibleRect.height / canvasContentSize
        
        let visibleRectInPDF = CGRect(
            x: xOffsetInPDF,
            y: yOffsetInPDF,
            width: rectWidthInPDF,
            height: rectHeightInPDF)
        
        DispatchQueue.global(qos: .background).async {
            
            // Generate a PDF.
            let bounds = CGRect(x: 0, y: 0, width: pdfWidth, height: pdfHeight)
            let mutableData = NSMutableData()
            UIGraphicsBeginPDFContextToData(mutableData, bounds, nil)
            UIGraphicsBeginPDFPage()
            
            // Generate images in the PDF, strip by strip.
            var yOrigin: CGFloat = 0
            let imageHeight: CGFloat = 1024
            while yOrigin < bounds.maxY {
                let imgBounds = CGRect(x: 0, y: yOrigin, width: DataModel.canvasWidth, height: min(imageHeight, bounds.maxY - yOrigin))
                let img = drawing.image(from: imgBounds, scale: 2)
                img.draw(in: imgBounds)
                yOrigin += imageHeight
            }
            
            UIGraphicsEndPDFContext()
            
            // Invoke the completion handler with the generated PDF data.
            completionHandler(mutableData as Data, 0, visibleRectInPDF)
        }
    }
}
