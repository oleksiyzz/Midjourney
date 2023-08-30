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

import Foundation
import RelatedDB
import ProgressHUD

//-----------------------------------------------------------------------------------------------------------------------------------------------
var qdb: RDatabase!

//-----------------------------------------------------------------------------------------------------------------------------------------------
class Database: NSObject {

	private let path = Dir.document("database.sqlite")

	private let link = "https://related.chat/midjourney/database.sqlite"

	//-------------------------------------------------------------------------------------------------------------------------------------------
	static let shared: Database = {
		let instance = Database()
		return instance
	} ()

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func setup() {

		shared.setup()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func setup() {

		if File.exist(path) {
			initialize()
		} else {
			download()
		}
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension Database {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func initialize() {

		qdb = RDatabase(path: path)

		if (DBSearch.check(qdb)) { return }

		qdb.execute("DROP TABLE DBSearch;")
		qdb.execute("CREATE VIRTUAL TABLE DBSearch USING fts5(objectId, prompt);")
		qdb.execute("INSERT INTO DBSearch SELECT objectId, prompt FROM DBItem;")
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension Database {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func download() {

		ProgressHUD.showProgress(0.0, interaction: false)

		guard let url = URL(string: link) else { fatalError() }

		let configuration = URLSessionConfiguration.default
		let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
		let task = session.downloadTask(with: url)

		task.resume()
	}
}

// MARK: - URLSessionDownloadDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension Database: URLSessionDownloadDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {

		File.copy(location.relativePath, path, true)

		ProgressHUD.showProgress(1.0, interaction: false)

		DispatchQueue.main.async(after: 0.25) {
			ProgressHUD.showSucceed()
			self.initialize()
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {

		let progress = CGFloat(totalBytesWritten) / CGFloat(totalBytesExpectedToWrite)

		ProgressHUD.showProgress(progress, interaction: false)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {

		if let error = error {
			ProgressHUD.showFailed(error)
		}
	}
}
