//
//  MainWindowController.swift
//  youtube-dl
//
//  Created by Ivan Dikic on 06/06/15.
//  Copyright (c) 2015 Futurice. All rights reserved.
//

import Cocoa

enum Parameters: String {
    case Verbose = "-v"
}

class MainWindowController: NSWindowController {

    // MARK - Outlets
    @IBOutlet weak var downloadURLTextField: NSTextField!
    @IBOutlet weak var downloadPathControl: NSPathControl!
    @IBOutlet var outputTextView: NSTextView!
    @IBOutlet weak var cancelButton: NSButton! {
        didSet {
            cancelButton.enabled = false
        }
    }
    @IBOutlet weak var downloadButton: NSButton!
    @IBOutlet weak var progressIndicator: NSProgressIndicator! {
        didSet {
            progressIndicator.hidden = true
        }
    }

    // MARK - Propertys
    var isRunning = false
    var runningTask: NSTask?
    var debug = true

    // MARK - Lifecycle
    override func windowDidLoad() {
        super.windowDidLoad()

        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self,
                                        selector: "updateUI",
                                        name: NSTaskDidTerminateNotification,
                                        object: nil)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    // MARK - User Actions
    @IBAction func onCancelButtonPress(sender: NSButton) {
        if let runningTask = runningTask {
            runningTask.terminate()
        }
    }

    @IBAction func onDownloadButtonPress(sender: NSButton) {

        var taskQueue: dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)

        dispatch_async(taskQueue) {
            var downloadPath = self.downloadURLTextField.stringValue
            var outputPath = self.downloadPathControl.URL?.path
            var arguments = [Parameters.Verbose.rawValue, downloadPath]
            var binaryPath = "/usr/local/bin/youtube-dl"

            if self.debug {
                println("\nArguments: \(arguments)\nBinary Path:\(binaryPath)\n")
            }

            self.runningTask = self.createTask(binaryPath, arguments: arguments, outputPath: outputPath)
            self.runningTask!.launch()
            self.updateUI()
            self.runningTask!.waitUntilExit()
        }
    }

    // MARK - Logic
    func createTask(pathToBinary: String, arguments:[String], outputPath: String?) -> NSTask {
        var task = NSTask()
        task.currentDirectoryPath = outputPath ?? "~/Downloads"
        task.launchPath = pathToBinary
        task.arguments = arguments

        if debug {
            println("\nCurrent directory path: \(task.currentDirectoryPath)\n")
        }

        return task
    }

    func updateUI() {
        if !isRunning {
            downloadButton.enabled = false
            cancelButton.enabled = true
            progressIndicator.startAnimation(self)
            progressIndicator.hidden = false
            outputTextView.string = ""
        } else {
            downloadButton.enabled = true
            cancelButton.enabled = false
            progressIndicator.stopAnimation(self)
            progressIndicator.hidden = true
        }

        isRunning = !isRunning
    }

}
