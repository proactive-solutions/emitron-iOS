// Copyright (c) 2022 Razeware LLC
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

@testable import Emitron

import class Foundation.URLSession

final class VideosServiceMock: Service {
  init() {
    networkClient = .init(authToken: .init())
  }

  let networkClient: RWAPI
  let session = URLSession(configuration: .default)

  private(set) var videoRequestedCount = 0
  private(set) var getVideoStreamCount = 0
  private(set) var getVideoDownloadCount = 0
}

// MARK: - internal
extension VideosServiceMock {
  func reset() {
    videoRequestedCount = 0
    getVideoStreamCount = 0
    getVideoDownloadCount = 0
  }
}

// MARK: - VideosServiceProtocol
extension VideosServiceMock: VideosServiceProtocol {
  func videoStream(for id: Int) async throws -> StreamVideoRequest.Response {
    getVideoStreamCount += 1
    return AttachmentTest.Mocks.stream.0
  }

  func videoStreamDownload(for id: Int) async throws -> StreamVideoRequest.Response {
    getVideoDownloadCount += 1
    return AttachmentTest.Mocks.download.0
  }
}
