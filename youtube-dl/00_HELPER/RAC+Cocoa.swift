//
//  RAC+Cocoa.swift
//  youtube-dl
//
//  Created by Ivan Dikic on 20/06/15.
//  Copyright (c) 2015 Futurice. All rights reserved.
//

import Foundation
import ReactiveCocoa

extension NSTextField {
    func rac_textSignalProducer() -> SignalProducer<String, NoError> {
        return self.rac_textSignal().toSignalProducer()
            |> map { $0! as! String }
            |> catch { _ in SignalProducer(value: "") }
    }
}

extension NSPathControl {
    func rac_textSignalProducer() -> SignalProducer<String, NoError> {
        return self.rac_valuesForKeyPath("URL.path", observer: nil).toSignalProducer()
            |> map { $0! as! String }
            |> catch {_ in SignalProducer(value: "") }
    }
}