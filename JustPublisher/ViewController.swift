//
//  ViewController.swift
//  JustPublisher
//
//  Created by Raiden Yamato on 27.03.2023.
//
import Combine
import UIKit

struct Cars: Decodable {
    let news: [Car]
    
}
struct Car: Decodable {
    let title: String
}


class ViewController: UIViewController, UITableViewDataSource {
    
    

    let url = URL(string: "https://webapi.autodoc.ru/api/news/1/15")
    var observer: AnyCancellable?
    
    private var cars: [Car] = []

    private let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.frame = view.bounds
        observer = fetchUsers()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [unowned self] cars in
                self.cars = cars
                self.tableView.reloadData()
        })
    }

   

    
    func fetchUsers() -> AnyPublisher<[Car], Never> {
        guard let url = url else {
            return Just([]).eraseToAnyPublisher()
        }
        
      let publisher = URLSession.shared.dataTaskPublisher(for: url)
            .map {$0.data}
            .decode(type: Cars.self, decoder: JSONDecoder())
            .map{$0.news}
            .catch { _ in
                Just([])
            }.eraseToAnyPublisher()
        return publisher
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cars.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = cars[indexPath.row].title
        cell.contentConfiguration = content
        return cell
    }
    
    
}

