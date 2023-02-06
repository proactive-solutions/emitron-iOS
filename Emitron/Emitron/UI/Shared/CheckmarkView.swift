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

import SwiftUI

// TODO: Refactor layout properties here
struct CheckmarkView {
  init(isOn: Bool, onChange: @escaping (Bool) -> Void) {
    self.isOn = isOn
    self.onChange = onChange
  }

  private let isOn: Bool
  private let onChange: (Bool) -> Void

  private let outerSide: CGFloat = 24
  private let innerSide: CGFloat = 20
  private let outerRadius: CGFloat = 9
}

// MARK: - View
extension CheckmarkView: View {
  var body: some View {
    Button {
      onChange(!isOn)
    } label: {
      if isOn {
        ZStack(alignment: .center) {
          Rectangle()
            .frame(maxWidth: outerSide, maxHeight: outerSide)
            .foregroundColor(.checkmarkBackground)

          Image.checkmark
            .resizable()
            .frame(maxWidth: innerSide - 1, maxHeight: innerSide + 1)
            .foregroundColor(.checkmarkColor)
        }
        .cornerRadius(outerRadius)
      } else {
        ZStack {
          RoundedRectangle(cornerRadius: outerRadius)
            .stroke(Color.checkmarkBorder, lineWidth: 2)
            .frame(maxWidth: outerSide, maxHeight: outerSide)
        }
      }
    }
  }
}

struct CheckmarkView_Previews: PreviewProvider {
  static var previews: some View {
    CheckmarkView(isOn: true) { change in
      print("Changed to: \(change)")
    }
  }
}
