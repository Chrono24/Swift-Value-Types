//
//  Observable.swift
//  Value-Types-at-Chrono24
//
//  Created by Christian Schnorr on 20.08.19.
//  Copyright © 2019 Christian Schnorr. All rights reserved.
//

import Swift

// We don't actually do this, this is just an example of how to do things with
// reference types.

protocol Observer: AnyObject {
    func update(_ sender: Observable)
}

class Observable {
    private var observers: Set<Weak> = []

    /* protected */ func notifyObservers() {
        for observer in self.observers {
            if let item = observer.item {
                item.update(self)
            }
        }
    }

    func addObserver(_ observer: Observer) {
        self.observers.insert(Weak(item: observer))
    }

    func removeObserver(_ observer: Observer) {
        self.observers.remove(Weak(item: observer))
    }
}

private struct Weak: Hashable {
    weak var item: Observer?

    func hash(into hasher: inout Hasher) {
        if let item = self.item {
            ObjectIdentifier(item).hash(into: &hasher)
        }
    }

    static func == (lhs: Weak, rhs: Weak) -> Bool {
        return lhs.item === rhs.item
    }
}
