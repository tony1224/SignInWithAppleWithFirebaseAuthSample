//
//  LoginViewModelDependencyImpl.swift
//  SignInWithAppleWithFirebaesAuthSample
//
//  Created by Morita Jun on 2019/12/07.
//  Copyright © 2019 Morita Jun. All rights reserved.
//

import UserAccount

struct LoginViewModelDependencyImpl: LoginViewModelDependency {
    let userAccount: UserAccountHostService
    
    init(userAccount: UserAccountHostService) {
        self.userAccount = userAccount
    }
    
}
