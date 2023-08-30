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
class GridView: UIViewController {

	@IBOutlet private var collectionView: UICollectionView!

	private var selectedPath = IndexPath(item: 0, section: 0)
	private let delegateHolder = NavigationControllerDelegate()

	private var gridLayout: GridLayout!
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

		navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(actionSearch))

		collectionView.register(UINib(nibName: "GridCell", bundle: nil), forCellWithReuseIdentifier: "GridCell")

		gridLayout = GridLayout()
		gridLayout.delegate = self
		collectionView.collectionViewLayout = gridLayout

		let margin = Grid.gridMargin / 2
		collectionView.contentInset = UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin)

		loadItems()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidAppear(_ animated: Bool) {

		super.viewDidAppear(animated)

		navigationController?.delegate = nil
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewWillLayoutSubviews() {

		super.viewWillLayoutSubviews()

		collectionView.collectionViewLayout.invalidateLayout()
	}
}

// MARK: - Database methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GridView {

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
extension GridView {

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
extension GridView {

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
extension GridView: SearchDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func didSearchItem(_ search: String) {

		self.search = search

		loadItems()
	}
}

// MARK: - Updating methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GridView {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func updateSelected(_ selected: Int) {

		selectedPath = IndexPath(item: selected, section: 0)
		collectionView.scrollToItem(at: selectedPath, at: .top, animated: false)

		collectionView.setNeedsLayout()
		collectionView.layoutIfNeeded()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func updateTransition(custom: Bool) {

		navigationController?.delegate = custom ? delegateHolder : nil
	}
}

// MARK: - GridViewProtocol
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GridView: GridViewProtocol {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func imageSize() -> CGSize {

		let dbitem = dbitems[selectedPath.item]

		let widthCollection = gridLayout.widthCollection
		let widthCell = widthCollection / Grid.columns()
		let widthImage = widthCell - Grid.gridMargin
		let heightImage = widthImage * dbitem.ratio

		return CGSize(width: widthImage, height: heightImage)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func imageView() -> UIImageView {

		if let cell = collectionView.cellForItem(at: selectedPath) as? GridCell {
			if let imageGrid = cell.imageGrid {
				let imageView = UIImageView(frame: imageGrid.frame)
				imageView.image = imageGrid.image
				imageView.layer.masksToBounds = true
				imageView.layer.cornerRadius = Grid.gridCorner
				imageView.backgroundColor = imageGrid.backgroundColor
				return imageView
			}
		}

		return UIImageView()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func imagePosition() -> CGPoint {

		if let cell = collectionView.cellForItem(at: selectedPath) as? GridCell {
			return cell.convert(cell.imageGrid.frame.origin, to: view)
		}

		return CGPoint.zero
	}
}

// MARK: - GridLayoutDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GridView: GridLayoutDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func collectionView(_ collectionView: UICollectionView, heightForCellAtIndexPath indexPath: IndexPath) -> CGFloat {

		let dbitem = dbitems[indexPath.item]

		let widthCollection = gridLayout.widthCollection
		let widthCell = widthCollection / Grid.columns()
		let widthImage = widthCell - Grid.gridMargin
		let heightImage = widthImage * dbitem.ratio
		let heightCell = heightImage + Grid.gridMargin

		Grid.widthGridImage = widthImage

		return heightCell
	}
}

// MARK: - UICollectionViewDataSource
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GridView: UICollectionViewDataSource {

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

		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GridCell", for: indexPath) as! GridCell

		let dbitem = dbitems[indexPath.item]
		cell.loadImage(dbitem)

		return cell
	}
}

// MARK: - UICollectionViewDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GridView: UICollectionViewDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

		collectionView.deselectItem(at: indexPath, animated: true)

		selectedPath = indexPath

		let pageView = PageView(dbitems, indexPath.item, self)
		navigationController?.delegate = delegateHolder
		navigationController?.pushViewController(pageView, animated: true)
	}
}
