//
//  UserAccountComponent.swift
//  UserAccount
//
//  Created by Morita Jun on 2019/12/07.
//  Copyright © 2019 Morita Jun. All rights reserved.
//

import Foundation
public let userAccountComponent: UserAccountComponent = UserAccountComponentImpl.shared

public protocol UserAccountComponent {
    var userAccountHostService: UserAccountHostService { get }
}
