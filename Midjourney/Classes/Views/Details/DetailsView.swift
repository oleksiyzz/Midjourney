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
protocol DetailsDelegate: AnyObject {

	func didFinishSettings()
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
class DetailsView: UIViewController {

	weak var delegate: DetailsDelegate?

	@IBOutlet private var cellGridLabel: UITableViewCell!
	@IBOutlet private var cellColumns: UITableViewCell!
	@IBOutlet private var cellGridMargin: UITableViewCell!
	@IBOutlet private var cellPageMargin: UITableViewCell!
	@IBOutlet private var cellGridCorner: UITableViewCell!
	@IBOutlet private var cellPageCorner: UITableViewCell!

	@IBOutlet private var switchGridLabel: UISwitch!
	@IBOutlet private var segmentedColumns: UISegmentedControl!
	@IBOutlet private var segmentedGridMargin: UISegmentedControl!
	@IBOutlet private var segmentedPageMargin: UISegmentedControl!
	@IBOutlet private var segmentedGridCorner: UISegmentedControl!

	private let columnsArray: [Int] = [2, 3, 4, 5]
	private let gridMarginArray: [CGFloat] = [0.0, 2.5, 5.0]
	private let pageMarginArray: [CGFloat] = [0.0, 5.0, 10.0]
	private let gridCornerArray: [CGFloat] = [0.0, 2.5, 5.0]

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()
		title = "Details"

		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(actionDone))

		segmentedGridMargin.addTarget(self, action: #selector(actionSegmentedGridMargin), for: .valueChanged)

		loadValues()
	}
}

// MARK: - Load, Save methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension DetailsView {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func loadValues() {

		switchGridLabel.setOn((Grid.heightGridLabel > 0), animated: false)

		if let index = columnsArray.firstIndex(of: Grid.gridColumns)	{ segmentedColumns.selectedSegmentIndex = index		}
		if let index = gridMarginArray.firstIndex(of: Grid.gridMargin)	{ segmentedGridMargin.selectedSegmentIndex = index	}
		if let index = pageMarginArray.firstIndex(of: Grid.pageMargin)	{ segmentedPageMargin.selectedSegmentIndex = index	}
		if let index = gridCornerArray.firstIndex(of: Grid.gridCorner)	{ segmentedGridCorner.selectedSegmentIndex = index	}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func saveValues() {

		Grid.heightGridLabel = switchGridLabel.isOn ? 50 : 0

		Grid.gridColumns = columnsArray[segmentedColumns.selectedSegmentIndex]
		Grid.gridMargin = gridMarginArray[segmentedGridMargin.selectedSegmentIndex]
		Grid.pageMargin = pageMarginArray[segmentedPageMargin.selectedSegmentIndex]
		Grid.gridCorner = gridCornerArray[segmentedGridCorner.selectedSegmentIndex]
	}
}

// MARK: - User actions
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension DetailsView {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionDone() {

		saveValues()

		dismiss(animated: true) {
			self.delegate?.didFinishSettings()
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionSegmentedGridMargin() {

		let index = segmentedGridMargin.selectedSegmentIndex
		segmentedPageMargin.selectedSegmentIndex = index
		segmentedGridCorner.selectedSegmentIndex = index
	}
}

// MARK: - UITableViewDataSource
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension DetailsView: UITableViewDataSource {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func numberOfSections(in tableView: UITableView) -> Int {

		return 4
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		if (section == 0) { return 1 }
		if (section == 1) { return 1 }
		if (section == 2) { return 2 }
		if (section == 3) { return 2 }

		return 0
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

		if (section == 1) { return "Number of columns"	}
		if (section == 2) { return "Margin value"		}
		if (section == 3) { return "Corner radius"		}

		return nil
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		if (indexPath.section == 0) && (indexPath.row == 0) { return cellGridLabel	}
		if (indexPath.section == 1) && (indexPath.row == 0) { return cellColumns	}
		if (indexPath.section == 2) && (indexPath.row == 0) { return cellGridMargin	}
		if (indexPath.section == 2) && (indexPath.row == 1) { return cellPageMargin	}
		if (indexPath.section == 3) && (indexPath.row == 0) { return cellGridCorner	}
		if (indexPath.section == 3) && (indexPath.row == 1) { return cellPageCorner	}

		return UITableViewCell()
	}
}
