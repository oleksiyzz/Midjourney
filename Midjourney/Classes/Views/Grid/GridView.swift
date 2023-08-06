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

	private var dbitems: [DBItem] = []

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()
		title = "Midjourney"

		navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)

		let imageDetails = UIImage(systemName: "gearshape")
		navigationItem.rightBarButtonItem = UIBarButtonItem(image: imageDetails, style: .plain, target: self, action: #selector(actionDetails))

		collectionView.register(UINib(nibName: "GridCell", bundle: nil), forCellWithReuseIdentifier: "GridCell")
		collectionView.collectionViewLayout = GridLayout()

		if let layout = collectionView.collectionViewLayout as? GridLayout {
			layout.delegate = self
		}

		dbitems = DBItem.fetchAll(qdb)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLayoutSubviews() {

		super.viewDidLayoutSubviews()
		collectionView.collectionViewLayout.invalidateLayout()
	}
}

// MARK: - User actions
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GridView {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionDetails() {

		let detailsView = DetailsView()
		detailsView.delegate = self
		let navController = NavigationController(rootViewController: detailsView)
		navigationController?.present(navController, animated: true, completion: nil)
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

// MARK: - DetailsDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GridView: DetailsDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func didFinishSettings() {

		collectionView.collectionViewLayout.invalidateLayout()
		collectionView.setNeedsLayout()
		collectionView.layoutIfNeeded()
		collectionView.reloadData()
	}
}

// MARK: - GridViewProtocol
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GridView: GridViewProtocol {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func imageSize() -> CGSize {

		let dbitem = dbitems[selectedPath.item]

		let widthCell = collectionView.bounds.width / Grid.columns()
		let widthImage = widthCell - 2 * Grid.gridMargin
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
			return cell.convert(cell.viewGrid.frame.origin, to: view)
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

		let widthCell = collectionView.bounds.width / Grid.columns()
		let widthImage = widthCell - 2 * Grid.gridMargin
		let heightImage = widthImage * dbitem.ratio
		let heightCell = heightImage + 2 * Grid.gridMargin + Grid.heightGridLabel

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
		cell.bindData(dbitem)
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
