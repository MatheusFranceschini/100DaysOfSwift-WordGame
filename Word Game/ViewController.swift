//
//  ViewController.swift
//  Word Game
//
//  Created by Matheus Franceschini on 02/09/24.
//

import UIKit

class ViewController: UITableViewController {
    
    var allWords = [String]()
    var usedWords = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        loadWords()
        setupNavigationBar()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "word")
        // Do any additional setup after loading the view.
    }

    func loadWords() {
        guard let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") else {
            return
        }
        
        guard let startWords = try? String(contentsOf: startWordsURL) else {
            return
        }
        
        allWords = startWords.components(separatedBy: "\n")
        startGame()
        
        if allWords.isEmpty {
            allWords = ["silkworm"]
        }
        
    }
    
    @objc func startGame() {
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(startGame))
    }
    
    @objc func promptForAnswer() {
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) {
            [weak self, weak ac] _ in
            guard let answer = ac?.textFields?[0].text else { return }
            self?.submit(answer)
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    func submit(_ answer: String) {
        let lowerAnswer = answer.lowercased()
        
        if isPossible(word: lowerAnswer) {
            if isOriginal(word: lowerAnswer) {
                if isReal(word: lowerAnswer) {
                    usedWords.insert(answer, at: 0)
                    
                    let indexPath = IndexPath(row: 0, section: 0)
                    tableView.insertRows(at: [indexPath], with: .automatic)
                    
                    return
                } else {
                    showErrorMessage(title: "Word not recognized", errorMessage: "You can't just make them up, you know!")
                }
            } else {
                showErrorMessage(title: "Word already used", errorMessage: "Be more original!")
            }
        } else {
            showErrorMessage(title: "Word not possible", errorMessage: "You can't spell that word from \(title!.lowercased())")
        }
    }
    
    func isPossible(word: String) -> Bool {
        guard var tempWord = title?.lowercased() else {
            return false
        }
        
        if word == tempWord {
            showErrorMessage(title: "Your word is our word", errorMessage: "You can't write the same word we offered")
            return false
        }
        
        for letter in word {
            if let position = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: position)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        if word.count <= 3 {
            showErrorMessage(title: "Less than 3 letters", errorMessage: "Your word is too short!")
            return false
        }
        
        return misspelledRange.location == NSNotFound
    }
    
    func showErrorMessage(title: String, errorMessage: String) {
        let ac = UIAlertController(title: title, message: errorMessage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }

}

