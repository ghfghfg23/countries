//
//  Coordinator.swift
//  Countries
//
//  Created by Andrey Ryabov on 26/10/2018.
//  Copyright © 2018 Andrey Ryabov. All rights reserved.
//

import UIKit

typealias CountryDidSelect = (Country) -> Void

class Coordinator {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let navigationController: UINavigationController
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func begin() {
        self.navigationController.setViewControllers([makeCountryListViewController()], animated: false)
    }

    func push(_ viewController: UIViewController) {
        navigationController.pushViewController(viewController, animated: true)
    }

    func showCountryDetails(_ country: Country) {
        push(makeCountryDetailViewController(for: country))
    }

    func makeCountryListViewController() -> CountryListViewController {
        let vc: CountryListViewController = storyboard.instantiate(identifier: "CountryListTableViewController")
        vc.didSelect = showCountryDetails
        return vc
    }

    func makeCountryDetailViewController(for country: Country) -> CountryDetailViewController {
        let vc: CountryDetailViewController = storyboard.instantiate(identifier: "CountryDetailTableViewController")
        vc.viewModel.countryCode = country.alpha2Code
        vc.didSelect = showCountryDetails
        return vc
    }
}

extension UIStoryboard {
    func instantiate<T>(identifier: String) -> T where T: UIViewController {
        guard let vc = instantiateViewController(withIdentifier: identifier) as? T else {
            fatalError("View controller with identifier \(identifier) should have class \(String(describing: T.self))")
        }
        return vc
    }
}
