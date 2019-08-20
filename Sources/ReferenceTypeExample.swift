//
//  ReferenceTypeExample.swift
//  Value-Types-at-Chrono24
//
//  Created by Christian Schnorr on 20.08.19.
//  Copyright © 2019 Christian Schnorr. All rights reserved.
//

import UIKit

// We don't actually do this, this is just an example of how to do things with
// reference types.

// If this had nested (mutable) reference types, we'd need to observe these too.
private class Item: Observable, Identifiable {
    init(title: String, isRead: Bool = false) {
        self.title = title
        self.isRead = isRead
    }

    var id: ObjectIdentifier {
        return ObjectIdentifier(self)
    }

    var title: String {
        didSet { self.notifyObservers() }
    }

    var isRead: Bool {
        didSet { self.notifyObservers() }
    }
}

class ReferenceTypeViewController: UITableViewController {
    init() {
        self.items = [
            Item(title: "Lorem"),
            Item(title: "Ipsum"),
            Item(title: "Dolor"),
            Item(title: "Sit"),
            Item(title: "Amet"),
            Item(title: "Consectetur"),
            Item(title: "Adipiscing"),
            Item(title: "Elit")
        ]

        super.init(nibName: nil, bundle: nil)

        self.title = "Reference Type Example"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Shuffle", style: .plain, target: self, action: #selector(shuffle))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Fetch", style: .plain, target: self, action: #selector(fetch))
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    private var items: [Item] {
        didSet {
            // We diff based on object identities. Sucks for us if we get all
            // new object identities because we fetch new data from the API
            // endpoint...
            self.tableView.animate(from: oldValue, to: items)

            // We do not need to deal with changes to individual items here.
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = "ID"
        let item = self.items[indexPath.row]

        if let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? ReferenceTypeCell {
            cell.item = item

            return cell
        } else {
            return ReferenceTypeCell(item: item, reuseIdentifier: reuseIdentifier)
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)

        // This operation does not mutate the array `self.items`; only a random
        // element will have its flag toggled and will notify its observers.
        self.items[indexPath.row].isRead.toggle()

        // If we wanted to modify multiple parts of an object, the observers
        // would be notified for each modification individually, causing the
        // respective cell to redraw multiple times if onscreen.
    }

    @objc private func shuffle() {
        // This operation mutates the array `self.items`, giving us a chance to
        // insert, delete, or move cells.
        self.items.shuffle()
    }

    @objc private func fetch() {
        // This operation mutates the array `self.items`, giving us a chance to
        // insert, delete, or move cells. Since these are all new objects and
        // diff based on object identity, we can't make the connection between
        // old and new objects and get a boring transition.
        self.items = ReferenceTypeViewController.fetch().shuffled()
    }

    private static func fetch() -> [Item] {
        return [
            Item(title: "Lorem"),
            Item(title: "Ipsum"),
            Item(title: "Dolor"),
            Item(title: "Sit"),
            Item(title: "Amet"),
            Item(title: "Consectetur"),
            Item(title: "Adipiscing"),
            Item(title: "Elit")
        ]
    }
}

private class ReferenceTypeCell: UITableViewCell, Observer {
    init(item: Item, reuseIdentifier: String?) {
        self.item = item

        super.init(style: .value1, reuseIdentifier: reuseIdentifier)

        self.item.addObserver(self)
        self.performFormattingUpdate()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    var item: Item {
        didSet {
            // We must not forget to stop observing the previous item and start
            // observing the new item.
            oldValue.removeObserver(self)
            self.item.addObserver(self)

            self.performFormattingUpdate()
        }
    }

    private func performFormattingUpdate() {
        self.textLabel!.text = self.item.title

        if self.item.isRead {
            self.detailTextLabel!.text = nil
        } else {
            self.detailTextLabel!.text = "Unread"
        }
    }

    func update(_ sender: Observable) {
        // We don't really know what changed. We just update entire cell.
        self.performFormattingUpdate()
    }
}
