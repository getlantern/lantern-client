//
//  Event.swift
//  Lantern
//
//  Based on https://blog.scottlogic.com/2015/02/05/swift-events.html
//
//  Created by Ox Cart on 9/28/20.
//  Copyright © 2020 Innovate Labs. All rights reserved.
//

import Foundation

public class Event<T> {

  public typealias EventHandler = (T) -> Void

  fileprivate var eventHandlers = [Invocable]()

  public func raise(_ data: T) {
    for handler in self.eventHandlers {
      handler.invoke(data)
    }
  }

  public func addHandler<U: AnyObject>(
    target: U,
    handler: @escaping (U) -> EventHandler
  ) -> Disposable {
    let wrapper = EventHandlerWrapper(
      target: target,
      handler: handler, event: self)
    eventHandlers.append(wrapper)
    return wrapper
  }
}

private protocol Invocable: class {
  func invoke(_ data: Any)
}

private class EventHandlerWrapper<T: AnyObject, U>: Invocable, Disposable {
  weak var target: T?
  let handler: (T) -> (U) -> Void
  let event: Event<U>

  init(target: T?, handler: @escaping (T) -> (U) -> Void, event: Event<U>) {
    self.target = target
    self.handler = handler
    self.event = event
  }

  func invoke(_ data: Any) {
    if let t = target {
      handler(t)(data as! U)
    }
  }

  func dispose() {
    event.eventHandlers =
      event.eventHandlers.filter { $0 !== self }
  }
}

public protocol Disposable {
  func dispose()
}
