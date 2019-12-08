//
//  ViewController.swift
//  SignInWithAppleWithFirebaesAuthSample
//
//  Created by Morita Jun on 2019/12/07.
//  Copyright © 2019 Morita Jun. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import AuthenticationServices

class ViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var loadingIndicatorView: UIActivityIndicatorView!

    private var viewModel: LoginViewModel?
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel = LoginViewModelFactory.shared.create()
        viewModel?.inputs.viewDidLoad()
        
        setupSignInWithApple()
        subscribeTransitionToSecond()
        subscribeLoadingEnabled()
        subscrubeShowErrorAlert()
    }
    
    // MARK: - Setup
    @available(iOS 13.0, *)
    private func setupSignInWithApple() {
        let signInWithAppleButton = ASAuthorizationAppleIDButton(
            authorizationButtonType: .signIn,
            authorizationButtonStyle: .black
        )
        signInWithAppleButton.addTarget(
            self,
            action: #selector(didTapSignInWithApple),
            for: .touchUpInside
        )
        stackView.addArrangedSubview(signInWithAppleButton)
    }
    
    // MARK: - Action
    
    @objc func didTapSignInWithApple() {
        viewModel?.inputs.didTapSignInWithApple(context: self)
    }
    
    // MARK: - Subscribe
    
    private func subscribeTransitionToSecond() {
        viewModel?
            .outputs
            .transitionToSecond
            .emit(onNext: { [weak self] () in
                
                // 次の画面へ遷移
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let second = storyboard.instantiateViewController(withIdentifier: "Second")
                self?.navigationController?.pushViewController(second, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    private func subscribeLoadingEnabled() {
        viewModel?
            .outputs
            .loadingEnabled
            .drive(loadingIndicatorView.rx.isAnimating)
            .disposed(by: disposeBag)
        
        viewModel?
            .outputs
            .loadingEnabled
            .map { !$0 }
            .drive(loadingIndicatorView.rx.isHidden)
            .disposed(by: disposeBag)
    }
    
    private func subscrubeShowErrorAlert() {
        viewModel?
            .outputs
            .showErrorAlert
            .drive(
                onNext: { [weak self] (errorMessage) in
                    if errorMessage.isEmpty { return }
                    
                    let alert = UIAlertController(
                        title: "エラーです。",
                        message: errorMessage,
                        preferredStyle: .alert
                    )
                    let okAction = UIAlertAction(
                        title: "OK",
                        style: .default,
                        handler: nil
                    )
                    alert.addAction(okAction)
                    self?.present(alert, animated: true, completion: nil)
                }
            )
            .disposed(by: disposeBag)
    }

}

extension ViewController: ASAuthorizationControllerPresentationContextProviding {
    @available(iOS 13.0, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
