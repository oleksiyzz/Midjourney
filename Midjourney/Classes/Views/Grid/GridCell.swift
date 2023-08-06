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
class GridCell: UICollectionViewCell {

	@IBOutlet var viewGrid: UIView!
	@IBOutlet var imageGrid: UIImageView!

	@IBOutlet private var viewLabel: UIView!
	@IBOutlet private var labelTitle: UILabel!
	@IBOutlet private var labelDetails: UILabel!

	private var objectId = ""

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func prepareForReuse() {

		objectId = ""

		imageGrid.image = nil
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func layoutSubviews() {

		super.layoutSubviews()

		let viewX = Grid.gridMargin
		let viewY = Grid.gridMargin

		let widthView = bounds.width - 2 * Grid.gridMargin
		let heightView = bounds.height - 2 * Grid.gridMargin

		viewGrid.frame = CGRect(x: viewX, y: viewY, width: widthView, height: heightView)

		viewGrid.layer.masksToBounds = true
		viewGrid.layer.cornerRadius = Grid.gridCorner

		let heightImage = heightView - Grid.heightGridLabel
		let heightLabel = Grid.heightGridLabel

		imageGrid.frame = CGRect(x: 0, y: 0, width: widthView, height: heightImage)
		viewLabel.frame = CGRect(x: 0, y: heightImage, width: widthView, height: heightLabel)

		var frameTitle = labelTitle.frame
		var frameDetails = labelDetails.frame

		frameTitle.size.width = widthView - 10
		frameDetails.size.width = widthView - 10

		labelTitle.frame = frameTitle
		labelDetails.frame = frameDetails
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GridCell {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func bindData(_ dbitem: DBItem) {

		labelTitle.text = dbitem.username
		labelDetails.text = dbitem.prompt
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func loadImage(_ dbitem: DBItem) {

		objectId = dbitem.objectId

		let width = bounds.width - 2 * Grid.gridMargin
		let height = width * dbitem.ratio

		let size = Size(width, height)

		Image.load(dbitem.link, size) { [weak self] image, error, later in
			guard let self = self else { return }
			if (self.objectId == dbitem.objectId) {
				if let image = image {
					self.imageGrid.image = image
				} else if later {
					self.loadLater(dbitem)
				}
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func loadLater(_ dbitem: DBItem) {

		DispatchQueue.main.async(after: 0.75) { [weak self] in
			guard let self = self else { return }
			if (self.objectId == dbitem.objectId) {
				if (self.imageGrid.image == nil) {
					self.loadImage(dbitem)
				}
			}
		}
	}
}
