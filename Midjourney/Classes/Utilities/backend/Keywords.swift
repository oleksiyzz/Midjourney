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

//-----------------------------------------------------------------------------------------------------------------------------------------------
class Keywords {

	private let link = "https://related.chat/midjourney/words.json"

	private let path = Dir.document("words.json")

	private var words: [String: Int] = [:]

	//-------------------------------------------------------------------------------------------------------------------------------------------
	static let shared: Keywords = {
		let instance = Keywords()
		return instance
	} ()

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func setup() {

		shared.setup()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func setup() {

		load()
		if (words.isEmpty) {
			download()
		}
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension Keywords {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func load() {

		if let data = Data(path: path) {
			decode(data)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func decode(_ data: Data) {

		if let dict = try? JSONDecoder().decode([String: Int].self, from: data) {
			words = dict
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func download() {

		guard let url = URL(string: link) else { fatalError() }

		let task = URLSession.shared.dataTask(with: url) { data, _, _ in
			if let data = data {
				self.decode(data)
				data.write(path: self.path)
			}
		}

		task.resume()
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension Keywords {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func random() -> String {

		if let element = shared.words.randomElement() {
			return element.key
		}
		return ""
	}
}
