//
//  CountryListTableViewController.swift
//  Countries
//
//  Created by Andrey Ryabov on 26/10/2018.
//  Copyright © 2018 Andrey Ryabov. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources

class CountryListViewController: UIViewController {
    let viewModel = CountryListViewModel()
    let disposeBag = DisposeBag()
    var didSelect: CountryDidSelect?
    @IBOutlet var tableView: UITableView!
    @IBOutlet var errorLabel: UILabel!
    @IBOutlet var reloadButton: UIButton!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var searchBar: UISearchBar!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.refreshControl = UIRefreshControl(frame: .zero)
        tableView.refreshControl!.rx.controlEvent(UIControlEvents.valueChanged).asObservable()
            .sample(tableView.rx.didEndDragging)
            .map { _ in () }
            .bind(onNext: viewModel.reload).disposed(by: disposeBag)

        viewModel.isLoadingObservable
            .filter { !$0 }
            .bind(to: tableView.refreshControl!.rx.isRefreshing)
            .disposed(by: disposeBag)

        searchBar.rx.text.asObservable()
            .throttle(0.5, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .bind(to: viewModel.searchText)
            .disposed(by: disposeBag)
        searchBar.rx.searchButtonClicked.asObservable()
            .bind { [weak searchBar] () -> Void in searchBar?.resignFirstResponder() }
            .disposed(by: disposeBag)

        let configureCell = { (index: Int, model: Country, cell: MultilineTableViewCell) in
            cell.titleLabel.text = model.formattedName
            cell.valueLabel.text = "\(model.population)"
        }
        viewModel.countryListObservable
            .bind(to: tableView.rx.items(cellIdentifier: "Cell"))(configureCell)
            .disposed(by: disposeBag)

        tableView.rx.modelSelected(Country.self)
            .subscribe(onNext: { [didSelect] country in didSelect?(country) })
            .disposed(by: disposeBag)

        bindAsyncContentView()
    }
}

extension CountryListViewController: RxFailableAsyncContentView {
    var bindableErrorLabel: UILabel { return errorLabel }
    var bindableActivityIndicator: UIActivityIndicatorView { return activityIndicator }
    var bindableReloadButton: UIButton { return reloadButton }
    var contentView: UIView { return tableView }
}
