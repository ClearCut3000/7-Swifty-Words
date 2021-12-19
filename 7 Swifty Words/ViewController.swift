//
//  ViewController.swift
//  7 Swifty Words
//
//  Created by Николай Никитин on 19.12.2021.
//

import UIKit

class ViewController: UIViewController {

  //MARK: - Properties
  var cluesLabel: UILabel!
  var answersLabel: UILabel!
  var currentAnswer: UITextField!
  var scoreLabel: UILabel!
  var letterButtons = [UIButton]()

  var activatedButtons = [UIButton]()
  var solutions = [String]()
  var score = 0{
    didSet {
      scoreLabel.text = "Score: \(score)"
    }
  }
  var level = 1

  //MARK: - ViewController lifecycle

  override func loadView(){
    view = UIView()
    view.backgroundColor = .lightGray

    scoreLabel = UILabel()
    scoreLabel.translatesAutoresizingMaskIntoConstraints = false
    scoreLabel.textAlignment = .right
    scoreLabel.text = "Score: 0"
    view.addSubview(scoreLabel)

    cluesLabel = UILabel()
    cluesLabel.translatesAutoresizingMaskIntoConstraints = false
    cluesLabel.font = UIFont.systemFont(ofSize: 24)
    cluesLabel.text = "CLUES"
    cluesLabel.numberOfLines = 0
    cluesLabel.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
    view.addSubview(cluesLabel)

    answersLabel = UILabel()
    answersLabel.translatesAutoresizingMaskIntoConstraints = false
    answersLabel.font = UIFont.systemFont(ofSize: 24)
    answersLabel.text = "ANSWERS"
    answersLabel.textAlignment = .right
    answersLabel.numberOfLines = 0
    answersLabel.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
    view.addSubview(answersLabel)

    currentAnswer = UITextField()
    currentAnswer.translatesAutoresizingMaskIntoConstraints = false
    currentAnswer.placeholder = "Tap letters to guess"
    currentAnswer.textAlignment = .center
    currentAnswer.font = UIFont.systemFont(ofSize: 44)
    currentAnswer.isUserInteractionEnabled = false
    view.addSubview(currentAnswer)

    let submitButton = UIButton(type: .system)
    submitButton.translatesAutoresizingMaskIntoConstraints = false
    submitButton.setTitle("SUBMIT", for: .normal)
    submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
    view.addSubview(submitButton)

    let clearButton = UIButton(type: .system)
    clearButton.translatesAutoresizingMaskIntoConstraints = false
    clearButton.setTitle("CLEAR", for: .normal)
    clearButton.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
    view.addSubview(clearButton)

    let buttonsView = UIView()
    buttonsView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(buttonsView)

    NSLayoutConstraint.activate([
      scoreLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
      scoreLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
      cluesLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor),
      cluesLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 100),
      cluesLabel.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 0.6, constant: -100),
      answersLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor),
      answersLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -100),
      answersLabel.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 0.4, constant: -100),
      answersLabel.heightAnchor.constraint(equalTo: cluesLabel.heightAnchor),
      currentAnswer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      currentAnswer.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
      currentAnswer.topAnchor.constraint(equalTo: cluesLabel.bottomAnchor, constant: 20),
      submitButton.topAnchor.constraint(equalTo: currentAnswer.bottomAnchor),
      submitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -100),
      submitButton.heightAnchor.constraint(equalToConstant: 44),
      clearButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 100),
      clearButton.centerYAnchor.constraint(equalTo: submitButton.centerYAnchor),
      clearButton.heightAnchor.constraint(equalToConstant: 44),
      buttonsView.widthAnchor.constraint(equalToConstant: 750),
      buttonsView.heightAnchor.constraint(equalToConstant: 320),
      buttonsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      buttonsView.topAnchor.constraint(equalTo: submitButton.bottomAnchor, constant: 20),
      buttonsView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -20),
    ])

    let width = 150
    let height = 80

    for row in 0..<4 {
      for column in 0..<5 {
        let letterButton = UIButton(type: .system)
        letterButton.titleLabel?.font = UIFont.systemFont(ofSize: 36)
        letterButton.setTitle("XXX", for: .normal)
        letterButton.addTarget(self, action: #selector(letterTapped), for: .touchUpInside)
        let frame = CGRect(x: column * width, y: row * height, width: width, height: height)
        letterButton.frame = frame
        buttonsView.addSubview(letterButton)
        letterButtons.append(letterButton)
      }
    }

  }

  override func viewDidLoad() {
    super.viewDidLoad()
    loadLevel()
  }

  //MARK: - Methods

  @objc func letterTapped(_ sender: UIButton){
    guard let buttonTitle = sender.titleLabel?.text else { return }
    currentAnswer.text = currentAnswer.text?.appending(buttonTitle)
    activatedButtons.append(sender)
    sender.isHidden = true
  }

  @objc func submitTapped(_ sender: UIButton){
    guard let answerText = currentAnswer.text else { return }
    if let solutionPosition = solutions.firstIndex(of: answerText) {
      activatedButtons.removeAll()
      var splitAnswers = answersLabel.text?.components(separatedBy: "\n")
      splitAnswers?[solutionPosition] = answerText
      answersLabel.text = splitAnswers?.joined(separator: "\n")
      currentAnswer.text = ""
      score += 1

      if score % 7 == 0 {
        let alert = UIAlertController(title: "Well done!", message: "Are you ready for next level?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Lets go!", style: .default, handler: levelUp))
        present(alert, animated: true)
      }
    }
  }

  private func levelUp(action: UIAlertAction){
    level += 1
    solutions.removeAll(keepingCapacity: true)
    loadLevel()
    for button in letterButtons {
      button.isHidden = false
    }
  }

  @objc func clearTapped(_ sender: UIButton){
    currentAnswer.text = ""
    for button in activatedButtons {
      button.isHidden = false
    }
    activatedButtons.removeAll()
  }

  private func loadLevel(){
    var clueString = ""
    var solutionString = ""
    var letterBits = [String]()

    if let levelFileURL = Bundle.main.url(forResource: "level\(level)", withExtension: "txt"){
      if let levelContents = try? String(contentsOf: levelFileURL){
        var lines = levelContents.components(separatedBy: "\n")
        lines .shuffle()
        for (index, line) in lines.enumerated() {
          let parts = line.components(separatedBy: ": ")
          let answer = parts[0]
          let clue = parts[1]

          clueString += "\(index + 1). \(clue)\n"

          let solutionWord = answer.replacingOccurrences(of: "|", with: "")
          solutionString += "\(solutionWord.count) letters\n"
          solutions.append(solutionWord)

          let bits = answer.components(separatedBy: "|")
          letterBits += bits

        }
      }
    }

    cluesLabel.text = clueString.trimmingCharacters(in: .whitespacesAndNewlines)
    answersLabel.text = solutionString.trimmingCharacters(in: .whitespacesAndNewlines)

    letterButtons.shuffle()

    if letterButtons.count == letterBits.count {
      for item in 0..<letterButtons.count {
        letterButtons[item].setTitle(letterBits[item], for: .normal)
      }
    }
  }
}

