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
import RelatedUI

//-----------------------------------------------------------------------------------------------------------------------------------------------
class SquaredView: UIViewController {

	@IBOutlet private var collectionView: UICollectionView!

	private var buttonTitle: UIButton!

	private var search: String = ""
	private var dbitems: [DBItem] = []
	private var isLoading: Bool = false

	//-------------------------------------------------------------------------------------------------------------------------------------------
	init(_ search: String) {

		super.init(nibName: nil, bundle: nil)

		self.search = search
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	required init?(coder: NSCoder) {

		fatalError()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()

		buttonTitle = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
		buttonTitle.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
		buttonTitle.addTarget(self, action: #selector(actionRandom), for: .touchUpInside)
		navigationItem.titleView = buttonTitle

		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(actionSearch))

		collectionView.register(UINib(nibName: "SquaredCell", bundle: nil), forCellWithReuseIdentifier: "SquaredCell")

		let margin = Grid.gridMargin / 2
		collectionView.contentInset = UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin)

		loadItems()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewWillLayoutSubviews() {

		super.viewWillLayoutSubviews()

		collectionView.collectionViewLayout.invalidateLayout()
	}
}

// MARK: - Database methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension SquaredView {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func loadItems() {

		if (isLoading) { return }

		scrollToZero()
		updateLoading(true)

		dbitems.removeAll()
		collectionView.reloadData()

		DispatchQueue.global().async {
			self.searchItems()
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func searchItems() {

		let dbsearches = DBSearch.fetchAll(qdb, "prompt MATCH ?", [search+"*"])

		var objectIds: [String] = []
		for dbsearch in dbsearches {
			objectIds.append(dbsearch.objectId)
		}

		dbitems = DBItem.fetchAll(qdb, "objectId IN ?", [objectIds])
		dbitems.shuffle()

		DispatchQueue.main.async {
			self.collectionView.reloadData()
			self.updateLoading(false)
		}
	}
}

// MARK: - Helper methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension SquaredView {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func scrollToZero() {

		if (collectionView.numberOfItems(inSection: 0) != 0) {
			collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func updateLoading(_ value: Bool) {

		isLoading = value

		let text = isLoading ? "Loading..." : "\(search.capitalized) - \(dbitems.count)"

		buttonTitle.setTitle(text, for: .normal)
	}
}

// MARK: - User actions
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension SquaredView {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionRandom() {

		search = Keywords.random()

		loadItems()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionSearch() {

		let searchView = SearchView()
		searchView.delegate = self
		let navController = NavigationController(rootViewController: searchView)
		present(navController, animated: true)
	}
}

// MARK: - SearchDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension SquaredView: SearchDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func didSearchItem(_ search: String) {

		self.search = search

		loadItems()
	}
}

// MARK: - UICollectionViewDataSource
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension SquaredView: UICollectionViewDataSource {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func numberOfSections(in collectionView: UICollectionView) -> Int {

		return 1
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

		return dbitems.count
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SquaredCell", for: indexPath) as! SquaredCell

		let dbitem = dbitems[indexPath.item]
		cell.loadImage(dbitem)

		return cell
	}
}

// MARK: - UICollectionViewDelegateFlowLayout
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension SquaredView: UICollectionViewDelegateFlowLayout {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

		let widthCollection = collectionView.bounds.width - Grid.gridMargin
		let widthCell = widthCollection / Grid.columns()

		Grid.widthGridImage = widthCell - Grid.gridMargin

		return CGSize(width: widthCell, height: widthCell)
	}
}

// MARK: - UICollectionViewDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension SquaredView: UICollectionViewDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

		collectionView.deselectItem(at: indexPath, animated: true)

		let pageView = PageView(dbitems, indexPath.item)
		navigationController?.pushViewController(pageView, animated: true)
	}
}
