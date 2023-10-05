//
//  LoadingIndicatorManager.swift
//  Runner
//
//  Created by jigar fumakiya on 12/09/23.
//

import Foundation
import UIKit

class LoadingIndicatorManager {
  private var loadingIndicator: UIActivityIndicatorView?
  private weak var parentView: UIView?

  init(parentView: UIView) {
    self.parentView = parentView
    setupLoadingIndicator()
  }

  private func setupLoadingIndicator() {
    loadingIndicator = UIActivityIndicatorView(style: .gray)
    guard let loadingIndicator = loadingIndicator, let parentView = parentView else {
      return
    }
    loadingIndicator.center = parentView.center
    loadingIndicator.hidesWhenStopped = true
    parentView.addSubview(loadingIndicator)
  }

  func show() {
    loadingIndicator?.startAnimating()
  }

  func hide() {
    loadingIndicator?.stopAnimating()
    loadingIndicator?.removeFromSuperview()
    loadingIndicator = nil
  }
}
