//
//  Identifiable.swift
//  Value-Types-at-Chrono24
//
//  Created by Christian Schnorr on 20.08.19.
//  Copyright © 2019 Christian Schnorr. All rights reserved.
//

import Swift

protocol Identifiable {
    associatedtype ID: Hashable
    var id: ID { get }
}
