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
    private let viewModel = MainWindowViewModel()
    private let (isActiveSignal, isActiveSink) = Signal<Bool, NoError>.pipe()
    private lazy var downloadButtonEnabled: DynamicProperty = {
        return DynamicProperty(object: self.downloadButton, keyPath: "enabled")
    }()

    // MARK - Lifecycle
    override func windowDidLoad() {
        super.windowDidLoad()
        sendNext(isActiveSink, true)
        bindViewModel()
    }


    // MARK - Binding
    private func bindViewModel() {

        viewModel.active <~ isActiveSignal
        viewModel.downloadURL <~ downloadURLTextField.rac_textSignalProducer()
        viewModel.outputPath <~ downloadPathControl.rac_textSignalProducer()

        downloadButton.target = CocoaAction(viewModel.taskAction)
        downloadButton.action = CocoaAction.selector

        downloadButtonEnabled <~ viewModel.taskAction.enabled.producer |> map { $0 as AnyObject }

        viewModel.taskRunning.producer
            |> start(next: { isTaskRunning in
                if !isTaskRunning {
                    self.cancelButton.enabled = true
                    self.progressIndicator.startAnimation(self)
                    self.progressIndicator.hidden = false
                    self.outputTextView.string = ""
                } else {
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
