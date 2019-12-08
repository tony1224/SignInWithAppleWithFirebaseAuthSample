//
//  IsLoginUseCase.swift
//  UserAccount
//
//  Created by Morita Jun on 2019/12/07.
//  Copyright © 2019 Morita Jun. All rights reserved.
//

import RxSwift

public protocol IsLoginUseCase {
    func execute() -> Single<Bool>
}
