//
//  LoginViewModelImpl.swift
//  SignInWithAppleWithFirebaesAuthSample
//
//  Created by Morita Jun on 2019/12/07.
//  Copyright © 2019 Morita Jun. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UserAccount

final class LoginViewModelImpl: LoginViewModel, LoginViewModelOutput, LoginViewModelInput {
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Outputs
    var outputs: LoginViewModelOutput { return self }
    
    var transitionToSecond: Signal<Void> { return transitionToSecondRelay.asSignal() }
    var loadingEnabled: Driver<Bool> { return loadingEnabledRelay.asDriver() }
    var showErrorAlert: Driver<String> { return showErrorAlertRelay.asDriver() }

    private let transitionToSecondRelay = PublishRelay<Void>()
    private let loadingEnabledRelay = BehaviorRelay<Bool>(value: false)
    private let showErrorAlertRelay = BehaviorRelay<String>(value: "")
    
    // MARK: - Inputs
    var inputs: LoginViewModelInput { return self }

    // MARK: - Dependency
    private let dependencies: LoginViewModelDependency
    
    // MARK: - Setup
    
    init(dependencies: LoginViewModelDependency) {
        self.dependencies = dependencies
    }
    
    func viewDidLoad() {
        dependencies
            .userAccount
            .isLogin()
            .do(
                onSubscribed: { [loadingEnabledRelay] in
                    loadingEnabledRelay.accept(true)
                },
                onDispose: { [loadingEnabledRelay] in
                    loadingEnabledRelay.accept(false)
                }
            )
            .subscribe(
                onSuccess: { [weak self] (isLogin) in
                    if isLogin {
                        self?.transitionToSecondRelay.accept(())
                    }
                },
                onError: { [weak self] (error) in
                    self?.showErrorAlertRelay.accept(error.localizedDescription)
                }
            )
            .disposed(by: disposeBag)
    }
    
    func didTapSignInWithApple(context: UIViewController) {
        dependencies
            .userAccount
            .login(context: context)
            .do(
                onSubscribed: { [loadingEnabledRelay] in
                    loadingEnabledRelay.accept(true)
                },
                onDispose: { [loadingEnabledRelay] in
                    loadingEnabledRelay.accept(false)
                }
            )
            .subscribe(
                onCompleted: { [weak self] () in
                    self?.transitionToSecondRelay.accept(())
                },
                onError: { [weak self] (error) in
                    self?.showErrorAlertRelay.accept(error.localizedDescription)
                }
            )
            .disposed(by: disposeBag)
    }
    
}
