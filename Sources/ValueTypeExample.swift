/*
 MIT License

 Copyright (c) 2019 Chrono24 GmbH

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import UIKit

// This is what we actually do. For Diffing pre iOS 13 we use Differ.

private struct Item: Identifiable, Equatable {
    var title: String
    var isRead: Bool = false

    var id: String {
        return title
    }
}

class ValueTypeViewController: UITableViewController {
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

        self.title = "Value Type Example"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Shuffle", style: .plain, target: self, action: #selector(shuffle))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Fetch", style: .plain, target: self, action: #selector(fetch))
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    private var items: [Item] {
        didSet {
            // We diff based on _record identities_ here — if we get all new
            // values from an API endpoint, the transition will work flawlessly.
            self.tableView.animate(from: oldValue, to: self.items)

            // With the cells not being able to listen for changes — they simply
            // get a snapshot of an item at one point time — we need to make
            // sure that cells which haven't been inserted or deleted are up to
            // date.
            for indexPath in self.tableView.indexPathsForVisibleRows ?? [] {
                if let cell = self.tableView.cellForRow(at: indexPath) as? ValueTypeCell {
                    let newItem = self.items[indexPath.row]

                    // If our cells store the item they currently present, we
                    // can simply assign the new item and let the cell decide
                    // whether or not it actually needs to redraw.
                    cell.item = newItem

                    // And even if they didn't and only had a configure(with:)
                    // method, we could still check if the value for the cell
                    // has changed because we have access to the old items here:
                    if let oldItem = oldValue.first(where: { $0.id == newItem.id }), newItem != oldItem {
                        cell.item = newItem
                    }
                }
            }
        }
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

        if let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? ValueTypeCell {
            cell.item = item

            return cell
        } else {
            return ValueTypeCell(item: item, reuseIdentifier: reuseIdentifier)
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)

        // Unlike in the reference type example, this operation will mutate the
        // array `self.items` as the elements in the array are value types and
        // can only be mutated by mutating their container. The `self.items`
        // property observer will be called, but no cells will be inserted,
        // deleted, or removed.
        // If the affected cell is currently visible, it will have the modified
        // item applied, otherwise it will be configured once scrolled onscreen.
        self.items[indexPath.row].isRead.toggle()

        // If we wanted to modify multiple parts of an object, we could make a
        // local copy of the array `self.items`, perform as many modifications
        // on the local copy as we want, write it back to `self.items` once we
        // are done.
    }

    @objc private func shuffle() {
        // This operation mutates the array `self.items`, giving us a chance to
        // insert, delete, or move cells.
        self.items.shuffle()
    }

    @objc private func fetch() {
        // This operation mutates the array `self.items`, giving us a chance to
        // insert, delete, or move cells. Even with us this being all new values
        // the transition will work flawlessly.
        self.items = ValueTypeViewController.fetch().shuffled()
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

// This guy doesn't need to worry about observation at all. He gets an item and
// presents it, and if a new or updated item needs to be presented, it will have
// its item setter invoked.
private class ValueTypeCell: UITableViewCell {
    init(item: Item, reuseIdentifier: String?) {
        self.item = item

        super.init(style: .value1, reuseIdentifier: reuseIdentifier)

        self.performFormattingUpdate()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    var item: Item {
        didSet { self.performFormattingUpdate() }
    }

    private func performFormattingUpdate() {
        self.textLabel!.text = self.item.title

        if self.item.isRead {
            self.detailTextLabel!.text = nil
        } else {
            self.detailTextLabel!.text = "Unread"
        }
    }
}
