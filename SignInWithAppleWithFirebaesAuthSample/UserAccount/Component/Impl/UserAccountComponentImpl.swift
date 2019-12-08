//
//  UserAccountComponentImpl.swift
//  UserAccount
//
//  Created by Morita Jun on 2019/12/07.
//  Copyright © 2019 Morita Jun. All rights reserved.
//

import Foundation
import Firebase

public struct UserAccountComponentImpl: UserAccountComponent {
    
    public static let shared = UserAccountComponentImpl()
    public let userAccountHostService: UserAccountHostService
    
    init() {
        if FirebaseApp.app() == nil {
            // 共有インスンタス設定
            FirebaseApp.configure()
        }

        let isLoginUseCase = IsLoginUseCaseImpl()
        let loginService = LoginServiceImpl()

        userAccountHostService = UserAccountHostServiceImpl(
            isLoginUseCase: isLoginUseCase,
            loginService: loginService
        )
    }
    
}
