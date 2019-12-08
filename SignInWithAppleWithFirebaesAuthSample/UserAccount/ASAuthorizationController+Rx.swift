//
//  ASAuthorizationController+Rx.swift
//  UserAccount
//
//  Created by Morita Jun on 2019/12/07.
//  Copyright © 2019 Morita Jun. All rights reserved.
//

import RxSwift
import RxCocoa
import AuthenticationServices

@available(iOS 13.0, *)
extension Reactive where Base: ASAuthorizationController {
    
    // デリゲートのラッパー用意
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
