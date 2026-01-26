import UIKit

// MARK: - Protocol

protocol CreateTaskViewProtocol: AnyObject {
    func configureForEditing(title: String, description: String?)
}

// MARK: - CreateTaskViewController

final class CreateTaskViewController: UIViewController {
    
    var presenter: CreateTaskPresenterProtocol?
    
    private lazy var ui: UI = {
        let ui = createUI()
        layout(ui)
        return ui
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        presenter?.viewDidLoad()
        _ = ui
    }
}

// MARK: - Public Methods

extension CreateTaskViewController {
    
    func checkAndSaveIfNeeded() {
        guard let title = ui.titleTextField.text else {
            presenter?.didTapCancelButton()
            return
        }
        
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !trimmedTitle.isEmpty {
            
            let descriptionText: String?
            if ui.descriptionTextView.text == "Описание задачи" || ui.descriptionTextView.text.isEmpty {
                descriptionText = nil
            } else {
                descriptionText = ui.descriptionTextView.text
            }
            
            print("Сохранение задачи: '\(trimmedTitle)'")
            presenter?.didTapSaveButton(
                title: trimmedTitle,
                description: descriptionText
            )
        } else {
            print("Заголовок пустой, возвращаемся без сохранения")
            presenter?.didTapCancelButton()
        }
    }
}

// MARK: - Private Methods

private extension CreateTaskViewController {
    
    func setupKeyboardHandling() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Готово", style: .done, target: self, action: #selector(dismissKeyboard))
        toolbar.items = [flexSpace, doneButton]
        
        ui.titleTextField.inputAccessoryView = toolbar
        ui.descriptionTextView.inputAccessoryView = toolbar
    }
    
    @objc private func backButtonTapped() {
        checkAndSaveIfNeeded()
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - UITextViewDelegate

extension CreateTaskViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .ypStroke && textView.text == "Описание задачи" {
            textView.text = ""
            textView.textColor = .ypWhite
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Описание задачи"
            textView.textColor = .ypStroke
        }
    }
}

// MARK: - UITextFieldDelegate

extension CreateTaskViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == ui.titleTextField {
            ui.descriptionTextView.becomeFirstResponder()
        }
        return true
    }
}

// MARK: - CreateTaskViewProtocol

extension CreateTaskViewController: CreateTaskViewProtocol {
    
    func configureForEditing(title: String, description: String?) {
        ui.titleTextField.text = title
        
        if let description = description, !description.isEmpty {
            ui.descriptionTextView.text = description
            ui.descriptionTextView.textColor = .ypWhite
        } else {
            ui.descriptionTextView.text = "Описание задачи"
            ui.descriptionTextView.textColor = .ypStroke
        }
    }
}

// MARK: - UI Setup

extension CreateTaskViewController {
    
    struct UI {
        let backButton: UIButton
        let titleTextField: UITextField
        let dateLabel: UILabel
        let descriptionTextView: UITextView
    }
    
    private func createUI() -> UI {
        view.backgroundColor = .ypBlack
        
        let backButton = UIButton()
        if let backImage = UIImage(named: "back") {
            backButton.setImage(backImage, for: .normal)
            backButton.tintColor = .ypYellow
            backButton.imageView?.contentMode = .scaleAspectFit
            
            backButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 8)
            
            backButton.setTitle("Назад", for: .normal)
            backButton.setTitleColor(.ypYellow, for: .normal)
            backButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
            
            backButton.semanticContentAttribute = .forceLeftToRight
        } else {
            backButton.setTitle("Назад", for: .normal)
            backButton.setTitleColor(.ypYellow, for: .normal)
            backButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
            print("Изображение 'back' не найдено в ассетах")
        }
        
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.contentHorizontalAlignment = .left
        view.addSubview(backButton)
        
        let titleTextField = UITextField()
        titleTextField.placeholder = "Название задачи"
        titleTextField.font = .systemFont(ofSize: 24, weight: .bold)
        titleTextField.textColor = .ypWhite
        titleTextField.backgroundColor = .clear
        titleTextField.borderStyle = .none
        titleTextField.returnKeyType = .done
        titleTextField.delegate = self
        
        let placeholderAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.ypStroke,
            .font: UIFont.systemFont(ofSize: 24, weight: .bold)
        ]
        titleTextField.attributedPlaceholder = NSAttributedString(
            string: "Название задачи",
            attributes: placeholderAttributes
        )
        
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleTextField)
        
        let dateLabel = UILabel()
        dateLabel.font = .systemFont(ofSize: 14, weight: .regular)
        dateLabel.textColor = .ypStroke
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yy"
        dateLabel.text = dateFormatter.string(from: Date())
        
        view.addSubview(dateLabel)
        
        let descriptionTextView = UITextView()
        descriptionTextView.font = .systemFont(ofSize: 17, weight: .regular)
        descriptionTextView.backgroundColor = .clear
        descriptionTextView.isScrollEnabled = true
        descriptionTextView.text = "Описание задачи"
        descriptionTextView.textColor = .ypStroke
        
        descriptionTextView.delegate = self
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionTextView)
        
        return .init(
            backButton: backButton,
            titleTextField: titleTextField,
            dateLabel: dateLabel,
            descriptionTextView: descriptionTextView
        )
        setupKeyboardHandling()
    }
    
    func layout(_ ui: UI) {
        NSLayoutConstraint.activate([
            ui.backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            ui.backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            ui.backButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 100),
            ui.backButton.heightAnchor.constraint(equalToConstant: 44),
            
            ui.titleTextField.topAnchor.constraint(equalTo: ui.backButton.bottomAnchor, constant: 32),
            ui.titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            ui.titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            ui.dateLabel.topAnchor.constraint(equalTo: ui.titleTextField.bottomAnchor, constant: 8),
            ui.dateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            ui.dateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            ui.descriptionTextView.topAnchor.constraint(equalTo: ui.dateLabel.bottomAnchor, constant: 20),
            ui.descriptionTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            ui.descriptionTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            ui.descriptionTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
}
