
import UIKit

class CustomButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureButton()
    }
    
    
    convenience init() {
        self.init(frame: .zero)
    }

    
    private func configureButton() {
        setTitleColor(UIColor.white, for: .normal) // Set text color to white
        backgroundColor = UIColor(red: 100/255, green: 61/255, blue: 136/255, alpha: 1)
        layer.borderColor = UIColor(red: 217/255, green: 176/255, blue: 255/255, alpha: 1).cgColor
        layer.shadowColor = UIColor(red: 217/255, green: 176/255, blue: 255/255, alpha: 1).cgColor

        
        setTitle("Jouer", for: .normal)
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 16) // Set font and size
        layer.cornerRadius = 20
        layer.borderWidth = 2
        layer.shadowRadius = 10
        layer.shadowOpacity = 1
        layer.shadowOffset = CGSize(width: 0, height: 0)
        
        addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)    }
    
    @objc private func buttonTapped() {
        // Add your button action here
    }
}
