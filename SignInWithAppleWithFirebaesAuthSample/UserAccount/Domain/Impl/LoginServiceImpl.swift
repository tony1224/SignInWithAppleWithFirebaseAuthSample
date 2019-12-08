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

    // Unhashed nonce.
    fileprivate var currentNonce: String?
    
    @available(iOS 13.0, *)
    func login(context: UIViewController?) -> Completable {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let nonce = randomNonceString()
        currentNonce = nonce
        
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        
        // ログインに成功した後でATをSVに返す処理が必要
        if let controller = context as? ASAuthorizationControllerPresentationContextProviding {
            authorizationController.presentationContextProvider = controller
        }
        authorizationController.performRequests()
        
        return authorizationController
            .rx
            .didComplete
            .flatMap({ [weak self] (authorization, error) -> Completable in
                // TODO: ここら辺の処理はQiita投稿前にブラッシュアップ
                guard let self = self else { return .empty() }
                if error != nil {
                    return .error(error!)
                }
                guard
                    let appleIDCredential = authorization?.credential as? ASAuthorizationAppleIDCredential,
                    let nonce = self.currentNonce,
                    let appleIDToken = appleIDCredential.identityToken,
                    let idTokenString = String(data: appleIDToken, encoding: .utf8)
                else {
                    return .error(error!)
                }
                let credential = OAuthProvider.credential(
                    withProviderID: "apple.com",
                    idToken: idTokenString,
                    rawNonce: nonce
                )
                return self.storeLoginWithApple(appleIDCredential: credential)
            })
            .asCompletable()
    }
    
    @available(iOS 13.0, *)
    private func storeLoginWithApple(appleIDCredential: AuthCredential) -> Completable {
        return Completable.create { (emitter) -> Disposable in
            Auth.auth().signIn(with: appleIDCredential) { (authResult, error) in
                if error != nil {
                    return emitter(.error(error!))
                }
                return emitter(.completed)
            }
            return Disposables.create()
        }
    }
    
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
