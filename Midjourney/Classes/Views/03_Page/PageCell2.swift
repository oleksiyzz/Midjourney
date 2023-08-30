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
class PageCell2: UITableViewCell {

	@IBOutlet var imagePage: UIImageView!

	private var objectId = ""

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func prepareForReuse() {

		objectId = ""

		imagePage.image = nil
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func layoutSubviews() {

		super.layoutSubviews()

		let widthImage = bounds.width - 2 * Grid.pageMargin
		let heightImage = bounds.height - 2 * Grid.pageMargin

		let scale = widthImage / Grid.widthGridImage

		imagePage.frame = CGRect(x: Grid.pageMargin, y: Grid.pageMargin, width: widthImage, height: heightImage)

		imagePage.layer.masksToBounds = true
		imagePage.layer.cornerRadius = Grid.gridCorner * scale
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension PageCell2 {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func loadImage(_ dbitem: DBItem) {

		objectId = dbitem.objectId

		let width = bounds.width - 2 * Grid.pageMargin
		let height = bounds.height - 2 * Grid.pageMargin

		let size = Size(width, height)

		Image.load(dbitem.link(), size) { [weak self] image, error, later in
			guard let self = self else { return }
			if (self.objectId == dbitem.objectId) {
				if let image = image {
					self.imagePage.image = image
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
				if (self.imagePage.image == nil) {
					self.loadImage(dbitem)
				}
			}
		}
	}
}
