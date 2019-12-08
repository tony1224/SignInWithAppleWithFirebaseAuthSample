//
//  UserAccountHostServiceImpl.swift
//  UserAccount
//
//  Created by Morita Jun on 2019/12/07.
//  Copyright © 2019 Morita Jun. All rights reserved.
//

import RxSwift

public struct UserAccountHostServiceImpl: UserAccountHostService {

    private let isLoginUseCase: IsLoginUseCase
    private let loginService: LoginService

    init(
        isLoginUseCase: IsLoginUseCase,
        loginService: LoginService
    ) {
        self.isLoginUseCase = isLoginUseCase
        self.loginService = loginService
    }
    
    public func isLogin() -> Single<Bool> {
        return isLoginUseCase.execute()
    }
    
    public func login(context: UIViewController?) -> Completable {
        return loginService.login(context: context)
    }
    
}
