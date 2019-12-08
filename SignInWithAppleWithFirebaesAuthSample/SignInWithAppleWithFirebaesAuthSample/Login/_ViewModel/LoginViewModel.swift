//
//  LoginViewModel.swift
//  SignInWithAppleWithFirebaesAuthSample
//
//  Created by Morita Jun on 2019/12/07.
//  Copyright © 2019 Morita Jun. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UserAccount

protocol LoginViewModelInput {
    func viewDidLoad()
    func didTapSignInWithApple(context: UIViewController)
}

protocol LoginViewModelOutput {
    var loadingEnabled: Driver<Bool> { get }
    var transitionToSecond: Signal<Void> { get }
    var showErrorAlert: Driver<String> { get }
}

protocol LoginViewModelDependency {
    var userAccount: UserAccountHostService { get }
}

protocol LoginViewModel {
    var inputs: LoginViewModelInput { get }
    var outputs: LoginViewModelOutput { get }
    init(dependencies: LoginViewModelDependency)
}


