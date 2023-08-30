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

	@IBOutlet var imageGrid: UIImageView!

	private var objectId = ""

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func prepareForReuse() {

		objectId = ""

		imageGrid.image = nil
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func layoutSubviews() {

		super.layoutSubviews()

		let x = Grid.gridMargin / 2
		let y = Grid.gridMargin / 2

		let width = bounds.width - Grid.gridMargin
		let height = bounds.height - Grid.gridMargin

		imageGrid.frame = CGRect(x: x, y: y, width: width, height: height)

		imageGrid.layer.masksToBounds = true
		imageGrid.layer.cornerRadius = Grid.gridCorner
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GridCell {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func loadImage(_ dbitem: DBItem) {

		objectId = dbitem.objectId

		let width = bounds.width - Grid.gridMargin
		let height = width * dbitem.ratio

		let size = Size(width, height)

		Image.load(dbitem.link(), size) { [weak self] image, error, later in
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
