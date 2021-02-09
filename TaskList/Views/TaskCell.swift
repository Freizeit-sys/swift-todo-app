//
//  TaskCell.swift
//  TaskList
//
//  Created by Admin on 2021/02/08.
//

import UIKit

protocol TaskCellDelegate: class {
    func didCheck(complete: Bool)
    func didDeleteCell(_ cell: TaskCell)
}

class TaskCell: UICollectionViewCell, UIGestureRecognizerDelegate {
    
    weak var delegate: TaskCellDelegate?
    
    var isCompleted: Bool = false {
        didSet {
            let imageName = self.isCompleted ? "check" : "uncheck"
            let image = UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate)
            completeButton.setImage(image, for: .normal)
        }
    }
    
    let completeButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .systemGray
        let image = UIImage(named: "uncheck")?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(handleComplete), for: .touchUpInside)
        return button
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Title"
        label.textColor = .black
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.numberOfLines = 3
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    //let duedate:
    
    let archiveImageShadowView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.applyMaterialShadow(elevation: 2)
        view.layer.cornerRadius = 44 / 2
        view.layer.masksToBounds = false
        return view
    }()
    
    let archiveImageView: UIImageView = {
        let iv = UIImageView()
        let image = UIImage(named: "archive")?.withRenderingMode(.alwaysTemplate)
        iv.image = image
        iv.tintColor = .systemGray
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let panGesture: UIPanGestureRecognizer = {
        let pg = UIPanGestureRecognizer()
        pg.cancelsTouchesInView = false
        return pg
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.commonInit()
        
        self.contentView.backgroundColor = .white
        self.contentView.layer.applyMaterialShadow(elevation: 4)
        self.contentView.layer.cornerRadius = 25
        self.contentView.alpha = 0.5
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let point: CGPoint = panGesture.translation(in: self)
        let width = self.contentView.frame.width
        let height  = self.contentView.frame.height
        
        // Move contentView
        if panGesture.state == .changed {
            if -point.x > 0 {
                self.contentView.frame = CGRect(x: point.x, y: 0, width: width, height: height)
            }
        }
        
        // Move contentView
        if panGesture.state == .ended {
            if width - (-point.x) < 60 {
                self.contentView.frame = CGRect(x: -(width + 32), y: 0, width: width, height: height)
            }
        }
    }
    
    private func commonInit() {
        self.addSubview(archiveImageShadowView)
        archiveImageShadowView.addSubview(archiveImageView)
        
        self.contentView.addSubview(completeButton)
        self.contentView.addSubview(titleLabel)
        self.contentView.addGestureRecognizer(panGesture)
        
        archiveImageShadowView.anchor(top: nil, left: nil, bottom: nil, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 16, width: 44, height: 44)
        archiveImageShadowView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        let insets = UIEdgeInsets(top: 10, left: 10, bottom: -10, right: -10)
        archiveImageView.fillSuperView(insets)
        
        completeButton.anchor(top: nil, left: self.contentView.leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 16, paddingBottom: 0, paddingRight: 0, width: 44, height: 44)
        completeButton.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
        
        titleLabel.anchor(top: self.contentView.topAnchor, left: completeButton.rightAnchor, bottom: self.contentView.bottomAnchor, right: self.contentView.rightAnchor, paddingTop: 24, paddingLeft: 10, paddingBottom: 24, paddingRight: 48, width: 0, height: 0)
        
        panGesture.addTarget(self, action: #selector(handlePanGesture(_:)))
        panGesture.delegate = self
    }
    
    @objc private func handleComplete() {
        self.isCompleted = !self.isCompleted
        delegate?.didCheck(complete: self.isCompleted)
    }
    
    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            ()
        case .changed:
            self.setNeedsLayout()
        case .ended:
            let point = gesture.translation(in: self)
            let width = self.contentView.frame.width
            let dx = width - (-point.x)
            
            if dx < 60 {
                UIView.animate(withDuration: 0.3) {
                    self.archiveImageShadowView.alpha = 0.0
                    self.setNeedsLayout()
                    self.layoutIfNeeded()
                } completion: { (finished) in
                    self.delegate?.didDeleteCell(self)
                }
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.setNeedsLayout()
                    self.layoutIfNeeded()
                }
            }
        default:
            ()
        }
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return abs((panGesture.velocity(in: panGesture.view)).x) > abs((panGesture.velocity(in: panGesture.view)).y)
    }
}

