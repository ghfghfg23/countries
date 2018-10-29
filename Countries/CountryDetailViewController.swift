//
//  CountryDetailsTableViewController.swift
//  Countries
//
//  Created by Andrey Ryabov on 26/10/2018.
//  Copyright © 2018 Andrey Ryabov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class CountryDetailViewController: UIViewController {
    let disposeBag = DisposeBag()
    let viewModel = CountryDetailViewModel()
    @IBOutlet var tableView: UITableView!
    var didSelect: CountryDidSelect?
    @IBOutlet var errorLabel: UILabel!
    @IBOutlet var reloadButton: UIButton!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.navigationTitleObservable.bind(to: navigationItem.rx.title).disposed(by: disposeBag)
        viewModel.sectionsObservable
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        Observable.combineLatest(
            tableView.rx.itemSelected.filter { $0.section == 1 },
            viewModel.countryObservable
        ).map { arg -> Country in
                let (indexPath, country) = arg
                let selectedBorder = country!.borders[indexPath.row]
                return selectedBorder
        }.bind(onNext: didSelect!).disposed(by: disposeBag)

        bindAsyncContentView()
        viewModel.reload()
    }

    private typealias DataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, TitleValuePair>>
    private var dataSource: DataSource {
        return DataSource(configureCell: { (dataSource, table, indexPath, item) in
            let identifier = "Cell"
            let dequeued = table.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
            guard let cell = dequeued as? MultilineTableViewCell else {
                fatalError("Check class of cell with identifier \(identifier)")
            }
            cell.titleLabel.text = item.title
            cell.valueLabel.text = item.value
            return cell
        }, titleForHeaderInSection: { dataSource, index in
            return dataSource.sectionModels[index].model
        })
    }
}

extension CountryDetailViewController: RxFailableAsyncContentView {
    var bindableErrorLabel: UILabel { return errorLabel }
    var bindableActivityIndicator: UIActivityIndicatorView { return activityIndicator }
    var bindableReloadButton: UIButton { return reloadButton }
    var contentView: UIView { return tableView }
}
