// Copyright (c) 2022 Kodeco Inc

//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
// distribute, sublicense, create a derivative work, and/or sell copies of the
// Software in any work that is designed, intended, or marketed for pedagogical or
// instructional purposes related to programming, coding, application development,
// or information technology.  Permission for such use, copying, modification,
// merger, publication, distribution, sublicensing, creation of derivative works,
// or sale is expressly withheld.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

struct FilterGroup: Hashable {
  var type: FilterGroupType
  var filters: [Filter]
  var numApplied: Int {
    filters.filter(\.isOn).count
  }
  
  init(type: FilterGroupType, filters: [Filter] = []) {
    self.type = type
    self.filters = filters
  }
  
  /// Update the filters in this group from a set of filters loaded from the data store
  /// - Parameter savedFilters: A Set of filters, often stored in UserSettings
  mutating func updateFilters(from savedFilters: Set<Filter>) {
    // We only care about filters that are from the same group
    let relevantFilters = savedFilters.filter { $0.groupType == type }
    // Let's go through those saved filters and load the relevant data
    relevantFilters.forEach { filter in
      // If we don't have a stored filter that matched the update, do not ignore it 
      // since we may not have loaded the complete filter list from domain/content repository  
      guard let storedFilter = filters.first(where: { $0 == filter }) else {
        // Add saved filters that were previously turned on even if they are
        // not loaded from domain/content repository.
        if filter.groupType == type && filter.isOn {
          filters.append(filter)
        }
        
        return
      }
      // The only attribute we care about is whether or not the filter is currently applied
      storedFilter.isOn = filter.isOn
    }
  }
}

enum FilterGroupType: String, Hashable, CaseIterable, Codable {
  case platforms = "Platforms"
  case categories = "Categories"
  case contentTypes = "Content Type"
  case difficulties = "Difficulty"
  case search = "Search"
  case none = "" // For filters whose values aren't an array, for example the search query
  
  var name: String { rawValue }
  
  var allowsMultipleValues: Bool {
    switch self {
    case .search, .none:
      return false
    default:
      return true
    }
  }
}
