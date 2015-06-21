//
//  MainWindowModel.swift
//  youtube-dl
//
//  Created by Ivan Dikic on 19/06/15.
//  Copyright (c) 2015 Futurice. All rights reserved.
//

import Foundation
import ReactiveCocoa

enum Parameters: String {
    case Verbose = "-v"
}

class MainWindowViewModel {

    // MARK: - Input
    let active = MutableProperty<Bool>(false)
    let debug = MutableProperty<Bool>(true)
    let downloadURL = MutableProperty<String>("")
    let outputPath = MutableProperty<String>("")

    // MARK: - Output
    let taskRunning = MutableProperty<Bool>(false)
    let debugOutput = MutableProperty<String>("")
    var taskAction: Action<AnyObject?, Bool, NoError>!

    private let binaryPath = "/usr/local/bin/youtube-dl"
    private let downloadURLValidated = MutableProperty<Bool>(false)
    private let outputPathValidated = MutableProperty<Bool>(false)
    private let downloadButtonEnabled = MutableProperty<Bool>(false)


    // MARK: - Init
    init() {
        setupSignals()
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    // MARK: - Signals
    private func setupSignals() {

    downloadURLValidated <~ downloadURL.producer
                                |> map { isValidURL in
                                    isValidURL.lowercaseString.rangeOfString("www.youtube.com") != nil
                                }
    outputPathValidated <~ outputPath.producer
                                |> map { isValidPath in count(isValidPath) > 0 }

    downloadButtonEnabled <~ combineLatest(downloadURLValidated.producer, outputPathValidated.producer)
                                |> map { validDownloadURL, validOutputPath in
                                    validDownloadURL && validOutputPath
                                }

    taskAction = Action<AnyObject?, Bool, NoError>(enabledIf: downloadButtonEnabled) { _ in
        return SignalProducer.empty
    }

    taskAction.executing.producer
        |> start(next: { isExecuting in
            println(isExecuting)
        })

    taskAction.values
        |> observe(next: { nextValueGeneratedByAction in
            println(nextValueGeneratedByAction)
        })

    taskAction.errors
        |> observe(next: { errors in
            println(errors)
        })


    NSNotificationCenter.defaultCenter()
                        .rac_addObserverForName("NSTaskDidTerminateNotification", object: nil)
                        .subscribeNext { [weak self](_) -> Void in
        // TODO: 
        // Do something when the task is finished
    }

    active.producer
        |> filter({ isActive in isActive })
        |> start(next: { _ in
            // TODO: do something on windowDidLoad
        })

    }

}
