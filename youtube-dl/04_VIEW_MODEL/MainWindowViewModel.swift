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
    let outputPath = MutableProperty<NSURL>(NSURL())

    // MARK: - Output
    let taskRunning = MutableProperty<Bool>(false)
    let debugOutput = MutableProperty<String>("")

    private let binaryPath = "/usr/local/bin/youtube-dl"


    // MARK: - Init
    init() {
        setupSignals()
    }


    // MARK: - Signals
    private func setupSignals() {

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
