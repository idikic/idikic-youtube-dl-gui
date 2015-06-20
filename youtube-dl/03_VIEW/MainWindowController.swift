//
//  MainWindowController.swift
//  youtube-dl
//
//  Created by Ivan Dikic on 06/06/15.
//  Copyright (c) 2015 Futurice. All rights reserved.
//

import Cocoa
import ReactiveCocoa

class MainWindowController: NSWindowController {


    // MARK - Outlets
    @IBOutlet weak var downloadURLTextField: NSTextField!
    @IBOutlet weak var downloadPathControl: NSPathControl!
    @IBOutlet var outputTextView: NSTextView!
    @IBOutlet weak var cancelButton: NSButton!
    @IBOutlet weak var downloadButton: NSButton!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!


    // MARK - Propertys
    let viewModel = MainWindowViewModel()
    let (isActiveSignal, isActiveSink) = Signal<Bool, NoError>.pipe()


    // MARK - Lifecycle
    override func windowDidLoad() {
        super.windowDidLoad()
        sendNext(isActiveSink, true)
        bindViewModel()
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }


    // MARK - Binding
    func bindViewModel() {

        viewModel.active <~ isActiveSignal
        viewModel.downloadURL <~ downloadURLTextField.rac_textSignalProducer()
        viewModel.outputPath <~ downloadPathControl.rac_textSignalProducer()

        viewModel.downloadButtonEnabled.producer
            |> start(next: { [weak self]enabled in self?.downloadButton.enabled = enabled })
        
        viewModel.taskRunning.producer
            |> start(next: { isTaskRunning in
                if !isTaskRunning {
                    self.downloadButton.enabled = false
                    self.cancelButton.enabled = true
                    self.progressIndicator.startAnimation(self)
                    self.progressIndicator.hidden = false
                    self.outputTextView.string = ""
                } else {
                    self.downloadButton.enabled = true
                    self.cancelButton.enabled = false
                    self.progressIndicator.stopAnimation(self)
                    self.progressIndicator.hidden = true
                }
            })
    }


    // MARK - User Actions
    @IBAction func onCancelButtonPress(sender: NSButton) {
    }

    @IBAction func onDownloadButtonPress(sender: NSButton) {
    }

    @IBAction func onPathControlPress(sender: NSPathControl) {
        if let outputPath = sender.URL?.path {
            viewModel.outputPath.put(outputPath)
        }
    }
}
