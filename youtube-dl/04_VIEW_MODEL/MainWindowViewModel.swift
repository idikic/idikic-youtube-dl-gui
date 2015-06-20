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
    let downloadButtonEnabled = MutableProperty<Bool>(false)

    private let binaryPath = "/usr/local/bin/youtube-dl"
    private let downloadURLValidated = MutableProperty<Bool>(false)
    private let outputPathValidated = MutableProperty<Bool>(false)

    // MARK: - Init
    init() {
        setupSignals()
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

    NSNotificationCenter.defaultCenter()
                        .rac_addObserverForName("NSTaskDidTerminateNotification", object: nil)
                        .subscribeNext { (_) -> Void in
        self.taskRunning.put(false)
    }

    active.producer
        |> filter({ isActive in isActive })
        |> start(next: { _ in
            // TODO: do something on windowDidLoad
        })

    }
}
