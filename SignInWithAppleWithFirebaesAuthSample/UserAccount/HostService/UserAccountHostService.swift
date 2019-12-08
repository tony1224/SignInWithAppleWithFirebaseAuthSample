//
//  UserAccountHostService.swift
//  UserAccount
//
//  Created by Morita Jun on 2019/12/07.
//  Copyright © 2019 Morita Jun. All rights reserved.
//

import RxSwift
import UIKit

public protocol UserAccountHostService {
    func isLogin() -> Single<Bool>
    func login(context: UIViewController?) -> Completable
}
