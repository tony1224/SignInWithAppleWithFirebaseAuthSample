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

// currentDelegateとsetCurrentDelegateの役割を担います
@available(iOS 13.0, *)
extension ASAuthorizationController: HasDelegate {
    public typealias Delegate = ASAuthorizationControllerDelegate
}

// DelegateProxy, DelegateProxyType, ASAuthorizationControllerDelegateを継承
// DelegateをRxに対応させるために、元となるDelegateも継承が必須です
@available(iOS 13.0, *)
public class RxASAuthorizationControllerDelegateProxy: DelegateProxy<ASAuthorizationController, ASAuthorizationControllerDelegate>,
    DelegateProxyType,
    ASAuthorizationControllerDelegate {

    // 初期化処理
    public init(controller: ASAuthorizationController) {
        super.init(
            parentObject: controller,
            delegateProxy: RxASAuthorizationControllerDelegateProxy.self
        )
    }

    // 必須のstaticメソッド
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
