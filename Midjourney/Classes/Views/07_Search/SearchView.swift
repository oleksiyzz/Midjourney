//
// Copyright (c) 2023 Related Code - https://relatedcode.com
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit

//-----------------------------------------------------------------------------------------------------------------------------------------------
protocol SearchDelegate: AnyObject {

	func didSearchItem(_ search: String)
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
class SearchView: UIViewController {

	weak var delegate: SearchDelegate?

	@IBOutlet private var searchBar: UISearchBar!
	@IBOutlet private var tableView: UITableView!

	private var suggestions: [String] = []

	private var isLoading = false
	private var isWaiting = false

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()
		title = "Search"

		let image = UIImage(systemName: "xmark")
		navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
		navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(actionDismiss))

		searchItems()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidAppear(_ animated: Bool) {

		super.viewDidAppear(animated)

		searchBar.becomeFirstResponder()
	}
}

// MARK: - Database methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension SearchView {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func searchItems() {

		if (isLoading) {
			isWaiting = true
		} else {
			isLoading = true
			let text = searchBar.text ?? ""
			DispatchQueue.global().async {
				self.searchItems(text)
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func searchItems(_ text: String) {

		let text = text.lowercased()

		let dbsearches = DBSearch.fetchAll(qdb, "prompt MATCH ?", [text+"*"], limit: 10000)

		var suggestionCounts: [String: Int] = [:]

		for dbsearch in dbsearches {
			let prompt = dbsearch.prompt.lowercased().filter { character in
				if let scalar = character.unicodeScalars.first {
					return !CharacterSet.punctuationCharacters.contains(scalar)
				}
				return true
			}

			if let upperBound = prompt.range(of: text)?.upperBound, upperBound <= prompt.endIndex {
				let remainingText = prompt[upperBound..<prompt.endIndex]
				if let nextSpace = remainingText.firstIndex(of: " ") {
					let nextWord = prompt[upperBound..<nextSpace]
					let suggestion = "\(text)\(nextWord)"
					suggestionCounts[suggestion, default: 0] += 1
				}
			}
		}

		suggestions = suggestionCounts.sorted { $0.value > $1.value }.map { $0.key }

		DispatchQueue.main.async { [self] in
			tableView.reloadData()
			loadingFinished()
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func loadingFinished() {

		isLoading = false
		if (isWaiting) {
			isWaiting = false
			searchItems()
		}
	}
}

// MARK: - User actions
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension SearchView {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionDismiss() {

		dismiss(animated: true)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func actionSearch() {

		let text = searchBar.text ?? ""

		if !text.isEmpty {
			actionSearch(text)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func actionSearch(_ text: String) {

		delegate?.didSearchItem(text)

		dismiss(animated: true)
	}
}

// MARK: - UITableViewDataSource
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension SearchView: UITableViewDataSource {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func numberOfSections(in tableView: UITableView) -> Int {

		return suggestions.count
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		return 1
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "cell")
		if (cell == nil) { cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell") }

		if (indexPath.section < suggestions.count) {
			let suggestion = suggestions[indexPath.section]

			cell.textLabel?.text = suggestion
			cell.detailTextLabel?.text = suggestion
			cell.detailTextLabel?.textColor = .gray
		}

		return cell
	}
}

// MARK: - UITableViewDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension SearchView: UITableViewDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		tableView.deselectRow(at: indexPath, animated: true)

		let suggestion = suggestions[indexPath.section]

		actionSearch(suggestion)
	}
}
// MARK: - UISearchBarDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension SearchView: UISearchBarDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

		searchItems()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {

		searchBar.setShowsCancelButton(true, animated: true)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {

		searchBar.setShowsCancelButton(false, animated: true)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {

		searchBar.text = ""
		searchBar.resignFirstResponder()

		searchItems()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

		searchBar.resignFirstResponder()

		actionSearch()
	}
}
