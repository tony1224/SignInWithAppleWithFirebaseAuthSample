//
//  LoginViewModelFactory.swift
//  SignInWithAppleWithFirebaesAuthSample
//
//  Created by Morita Jun on 2019/12/07.
//  Copyright © 2019 Morita Jun. All rights reserved.
//

import UserAccount

final class LoginViewModelFactory {
    static let shared = LoginViewModelFactory()
    
    func create() -> LoginViewModel {
        let dependencies = LoginViewModelDependencyImpl(userAccount: userAccountComponent.userAccountHostService)
        return LoginViewModelImpl(dependencies: dependencies)
    }
    
}
