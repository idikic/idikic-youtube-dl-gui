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
    @IBOutlet weak var cancelButton: NSButton!
    @IBOutlet weak var downloadButton: NSButton!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!

    // MARK - Propertys
    var isRunning = false
    var runningTask: NSTask?

    // MARK - Lifecycle
    override func windowDidLoad() {
        super.windowDidLoad()

        // Implement this method to handle any initialization 
        // after your window controller's window has been loaded from its nib file.
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

            println("Arguments: \(arguments)\nBinary Path:\(binaryPath)")

            self.runningTask = self.createTask(binaryPath, arguments: arguments, outputPath: outputPath)
            self.runningTask!.launch()
            self.runningTask!.waitUntilExit()
        }
    }

    // MARK - Logic
    func createTask(pathToBinary: String, arguments:[String], outputPath: String?) -> NSTask {
        var task = NSTask()
        task.currentDirectoryPath = outputPath ?? "~/Downloads"
        task.launchPath = pathToBinary
        task.arguments = arguments
        return task
    }

    func updateUI() {
        if isRunning {
            downloadButton.enabled = false
            cancelButton.enabled = true
            progressIndicator.startAnimation(self)
            outputTextView.string = ""
        } else {
            downloadButton.enabled = true
            cancelButton.enabled = false
            progressIndicator.stopAnimation(self)
        }
    }

}
