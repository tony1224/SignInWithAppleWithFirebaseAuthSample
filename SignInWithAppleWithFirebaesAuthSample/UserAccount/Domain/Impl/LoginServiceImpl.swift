//
//  LoginServiceImpl.swift
//  UserAccount
//
//  Created by Morita Jun on 2019/12/07.
//  Copyright © 2019 Morita Jun. All rights reserved.
//

import RxSwift
import AuthenticationServices
import FirebaseAuth
import CryptoKit

final class LoginServiceImpl: LoginService {

    private let prividerID = "apple.com"
    private var nonce: String?
    
    func login(context: UIViewController?) -> Completable {
        let authorizationController = initAuthorizationController(with: context)
                 
        return authorizationController
            .rx
            .didComplete
            .flatMap({ [weak self] (authorization, error) -> Completable in
                if let error = error {
                    return .error(error)
                }
                guard
                    let self = self,
                    let credential = self.initCredential(with: authorization)
                else {
                    throw AuthenticationError.failedToCreateCredential
                }
                return self.signIn(with: credential)
            })
            .asCompletable()
    }
    
    @available(iOS 13.0, *)
    private func signIn(with credential: AuthCredential) -> Completable {
        return Completable.create { (emitter) -> Disposable in
            
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error = error {
                    return emitter(.error(error))
                }
                return emitter(.completed)
            }

            return Disposables.create()
        }
    }
    
    // MARK: - Initializer
    
    @available(iOS 13.0, *)
    private func initAuthorizationController(with context: UIViewController?) -> ASAuthorizationController {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        nonce = randomNonceString()
        
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        if let nonce = self.nonce {
            request.nonce = sha256(nonce)
        }
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        
        if let controller = context as? ASAuthorizationControllerPresentationContextProviding {
            authorizationController.presentationContextProvider = controller
        }
        authorizationController.performRequests()
        
        return authorizationController
    }
    
    @available(iOS 13.0, *)
    private func initCredential(with authorization: ASAuthorization?) -> AuthCredential? {
        guard
            let appleIDCredential = authorization?.credential as? ASAuthorizationAppleIDCredential,
            let nonce = self.nonce,
            let appleIDToken = appleIDCredential.identityToken,
            let idTokenString = String(data: appleIDToken, encoding: .utf8)
        else {
            return nil
        }

        return OAuthProvider.credential(
            withProviderID: prividerID,
            idToken: idTokenString,
            rawNonce: nonce
        )
    }

}

extension LoginServiceImpl {

    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if length == 0 { return }
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }
    
    @available(iOS 13.0, *)
    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        return String(format: "%02x", $0)
      }.joined()

      return hashString
    }

}
