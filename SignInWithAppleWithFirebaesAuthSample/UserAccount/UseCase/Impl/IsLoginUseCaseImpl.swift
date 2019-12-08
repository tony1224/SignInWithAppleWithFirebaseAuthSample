//
//  IsLoginUseCaseImpl.swift
//  UserAccount
//
//  Created by Morita Jun on 2019/12/07.
//  Copyright © 2019 Morita Jun. All rights reserved.
//

import RxSwift
import Firebase

class IsLoginUseCaseImpl: IsLoginUseCase {
    
    func execute() -> Single<Bool> {
        return Single.create { (observer) -> Disposable in
            let currentUser = Auth.auth().currentUser
            if let user = currentUser {
                user.getIDToken() { idToken, error in
                    if let _ = idToken, error == nil {
                        observer(.success(true))
                    } else {
                        observer(.success(false))
                    }
                }
            } else {
                observer(.success(false))
            }
            return Disposables.create()
        }
    }

}
