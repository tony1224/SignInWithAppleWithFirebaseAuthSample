//
//  RxASAuthorizationControllerDelegateProxy.swift
//  UserAccount
//
//  Created by Morita Jun on 2019/12/07.
//  Copyright © 2019 Morita Jun. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import AuthenticationServices

@available(iOS 13.0, *)
extension ASAuthorizationController: HasDelegate {
    public typealias Delegate = ASAuthorizationControllerDelegate
}

@available(iOS 13.0, *)
public class RxASAuthorizationControllerDelegateProxy: DelegateProxy<ASAuthorizationController, ASAuthorizationControllerDelegate>,
    DelegateProxyType,
    ASAuthorizationControllerDelegate {

    public init(controller: ASAuthorizationController) {
        super.init(
            parentObject: controller,
            delegateProxy: RxASAuthorizationControllerDelegateProxy.self
        )
    }

    public static func registerKnownImplementations() {
        self.register { (controller) -> RxASAuthorizationControllerDelegateProxy in
            RxASAuthorizationControllerDelegateProxy(controller: controller)
        }
    }

    internal lazy var didComplete = PublishSubject<(ASAuthorization?, Error?)>()

    public func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        _forwardToDelegate?.authorizationController(
            controller: controller,
            didCompleteWithAuthorization: authorization
        )
        didComplete.onNext((authorization, nil))
    }
    
    public func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        _forwardToDelegate?.authorizationController(
            controller: controller,
            didCompleteWithError: error
        )
        didComplete.onNext((nil, error))
    }

    deinit { self.didComplete.on(.completed) }

}

@available(iOS 13.0, *)
extension Reactive where Base: ASAuthorizationController {
    
    public var delegate: DelegateProxy<ASAuthorizationController, ASAuthorizationControllerDelegate> {
        return RxASAuthorizationControllerDelegateProxy.proxy(for: base)
    }
    
    public var didComplete: Observable<(ASAuthorization?, Error?)> {
        return RxASAuthorizationControllerDelegateProxy
            .proxy(for: base)
            .didComplete
            .asObservable()
    }
    
}
