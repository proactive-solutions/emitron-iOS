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
import StoreKit

struct MainView: View {
  @EnvironmentObject private var sessionController: SessionController
  @EnvironmentObject private var dataManager: DataManager
  @EnvironmentObject private var messageBus: MessageBus
  @EnvironmentObject private var settingsManager: SettingsManager
  
  // A bit of a hack variable to ensure we can refresh when we want to
  @State private var refresh = false

  private let tabViewModel = TabViewModel()
  private let notification = NotificationCenter.default.publisher(for: .requestReview)

  var body: some View {
    ZStack {
      contentView
        .background(Color.background)
        .overlay(MessageBarView(messageBus: messageBus), alignment: .bottom)
        .onReceive(notification) { _ in
          Task {
            try await Task.sleep(nanoseconds: 2_000_000_000)
            makeReviewRequest()
          }
        }
        .onReceive(sessionController.$permissionState) { state in
          Task {
            // This is a bit of a hack. It forces reloading this view, even though
            // it shouldn't be necessary. However, it appears to maybe work?
            try await Task.sleep(nanoseconds: 2_000_000_000)
            print(":::STATE:::: \(state)")
            refresh.toggle()
          }
        }
    }
  }
}

// MARK: - private
private extension MainView {
  @ViewBuilder var contentView: some View {
    if !sessionController.isLoggedIn {
      LoginView()
      // This conditional is a mess. But it forces this view to be reliant on
      // the refresh state var, which is triggered whenever the permission state
      // changes. This is necesary because, sometimes, this view doesn't update
      // when permission state changes. And I don't know why.
    } else if refresh || !refresh {
      switch sessionController.permissionState {
      case .loaded:
        tabBarView
      case .notLoaded, .loading:
        PermissionsLoadingView()
      case .error:
        ErrorView(
          buttonTitle: "Back to login screen",
          buttonAction: sessionController.logOut
        )
      }
    }
  }
  
  @ViewBuilder var tabBarView: some View {
    switch sessionController.sessionState {
    case .online:
      TabView(
        libraryView: {
          LibraryView(
            filters: dataManager.filters,
            libraryRepository: dataManager.libraryRepository
          )
        },
        myTutorialsView: {
          MyTutorialsView(
            state: .inProgress,
            inProgressRepository: dataManager.inProgressRepository,
            completedRepository: dataManager.completedRepository,
            bookmarkRepository: dataManager.bookmarkRepository,
            domainRepository: dataManager.domainRepository
          )
        },
        downloadsView: downloadsView,
        settingsView: settingsView
      )
      .environmentObject(tabViewModel)
    case .offline:
      TabView(
        libraryView: OfflineView.init,
        myTutorialsView: OfflineView.init,
        downloadsView: downloadsView,
        settingsView: settingsView
      )
        .environmentObject(tabViewModel)
    case .unknown:
      LoadingView()
    }
  }

  func downloadsView() -> DownloadsView {
    .init(
      contentScreen: .downloads(permitted: sessionController.user?.canDownload ?? false),
      downloadRepository: dataManager.downloadRepository
    )
  }

  func settingsView() -> SettingsView {
    .init(settingsManager: settingsManager)
  }

  func makeReviewRequest() {
   if let scene = (UIApplication.shared.connectedScenes.first { $0.activationState == .foregroundActive } as? UIWindowScene) {
     SKStoreReviewController.requestReview(in: scene)
   }
 }
}
