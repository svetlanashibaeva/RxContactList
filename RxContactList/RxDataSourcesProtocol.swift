//
//  RxDataSourcesProtocol.swift
//  RxContactList
//
//  Created by Света Шибаева on 30.01.2023.
//

import Foundation
import RxDataSources

protocol RxDataSourcesProtocol {
    typealias Section = SectionModel<String, BaseCellModelProtocol>
    
    func reloadDataSource() -> RxTableViewSectionedReloadDataSource<Section>
}

extension RxDataSourcesProtocol {
    
    func reloadDataSource() -> RxTableViewSectionedReloadDataSource<Section> {
        return RxTableViewSectionedReloadDataSource<Section> { _, tableView, indexPath, element in
            let cell = tableView.dequeueReusableCell(withIdentifier: element.reuseId)!
            element.configureCell(cell)
            return cell
        }
    }
}
