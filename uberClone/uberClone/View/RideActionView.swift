//
//  RideActionView.swift
//  uberClone
//
//  Created by Михаил Щербаков on 21.04.2022.
//

import UIKit
import MapKit

protocol RideActionViewDelegate: class {
    func uploadTrip(_ view: RideActionView)
    func cancelTrip()
    func pickupPassenger()
    func dropOffPassenger()
}

enum RideActrionViewConfiguration {
    case requestRide, tripAccepted, driverArrived, pickupPassenger, tripInProgress, endTrip
    
    init() {
        self = .requestRide
    }
}

enum ButtonAction: CustomStringConvertible {
    case requestRide, cancel, getdirections, pickup, dropOff
    
    var description: String {
        switch self {
        case .requestRide:
            return "ПОДТВЕДИТЬ UBERX"
        case .cancel:
            return "ОТМЕНИТЬ"
        case .getdirections:
            return "НАПРАВИТЬСЯ"
        case .pickup:
            return "ВЗЯТЬ ПАССАЖИРА"
        case .dropOff:
            return "ВЫСАДИТЬ ПАССАЖИРА"
        }
    }
    
    init() {
        self = .requestRide
    }
}


class RideActionView: UIView {

    //MARK: Properties
    
    var destination: MKPlacemark? {
        didSet{
            titleLabel.text = destination?.name
            addressLabel.text = destination?.address
        }
    }
    
    
    var buttonActiom = ButtonAction()
    weak var delegate: RideActionViewDelegate?
    var user: User?
    
    var config = RideActrionViewConfiguration() {
        didSet {
            configureUI(withConfig: config)
        }
    }
    
    private let titleLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.text = "Test title"
        label.textAlignment = .center
        return label
    }()
    
    private let addressLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = "Test address"
        label.textAlignment = .center
         return label
    }()
    
    private lazy var infoView: UIView = {
      let view = UIView()
        view.backgroundColor = .black
        
        view.addSubview(infoViewLabel)
        infoViewLabel.centerX(inView: view)
        infoViewLabel.centerY(inView: view)
        
        return view
    }()
    
    private let infoViewLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 30)
        label.textColor = .white
        label.text = "X"
        return label
    }()
    
    private let uberXLabel: UILabel = {
        let label = UILabel()
         label.font = UIFont.systemFont(ofSize: 18)
         label.text = "Uber X"
         label.textAlignment = .center
         return label
    }()
    
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .black
        button.setTitle("Подтведить UBERX", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(actionButtonPressed), for: .touchUpInside)
        return button
    }()
    
    
    //MARK: Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        addShadow()
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, addressLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.distribution = .fillEqually
        addSubview(stack)
        stack.centerX(inView: self)
        stack.anchor(top: topAnchor, paddingTop: 12)
        
        addSubview(infoView)
        infoView.centerX(inView: self)
        infoView.anchor(top: stack.bottomAnchor, paddingTop: 16)
        infoView.setDimensions(height: 60, width: 60)
        infoView.layer.cornerRadius = 60/2
        
        addSubview(uberXLabel)
        uberXLabel.anchor(top: infoView.bottomAnchor, paddingTop: 8)
        uberXLabel.centerX(inView: self)
        
        let separatorView = UIView()
        separatorView.backgroundColor = .lightGray
        addSubview(separatorView)
        separatorView.anchor(top: uberXLabel.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 4, height: 0.75)
        
        addSubview(actionButton)
        actionButton.anchor(top: separatorView.bottomAnchor, left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor,
                            right: rightAnchor, paddingBottom: 12, paddingLeft: 12, paddingRight: 12, height: 50)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Selectors

    @objc func actionButtonPressed() {
        switch buttonActiom {
        case .requestRide:
            delegate?.uploadTrip(self)
        case .cancel:
            delegate?.cancelTrip()
        case .getdirections:
            print("Debug: get directions")
        case .pickup:
            delegate?.pickupPassenger()
        case .dropOff:
            delegate?.dropOffPassenger()
        }
    }
    
    //MARK: Helpers
    
    private func configureUI(withConfig config: RideActrionViewConfiguration) {
        switch config {
        case .requestRide:
            buttonActiom = .requestRide
            actionButton.setTitle(buttonActiom.description, for: .normal)
        case .tripAccepted:
            guard let user = user else { return }
            
            if user.accountType == .passenger {
                titleLabel.text = "В пути до пассажира"
                buttonActiom = .getdirections
                actionButton.setTitle(buttonActiom.description, for: .normal)
            } else {
                buttonActiom = .cancel
                actionButton.setTitle(buttonActiom.description, for: .normal)
                titleLabel.text = "Водитель в пути"
            }
            
            infoViewLabel.text = String(user.fullname.first ?? "X")
            uberXLabel.text = user.fullname

        case .pickupPassenger:
            titleLabel.text = "Прибыли к месту назначения"
            buttonActiom = .pickup
            actionButton.setTitle(buttonActiom.description, for: .normal)
        case .tripInProgress:
            guard let user = user else { return }
            if user.accountType == .driver {
                actionButton.setTitle("В пути", for: .normal)
                actionButton.isEnabled = false
            } else {
                buttonActiom = .getdirections
                actionButton.setTitle(buttonActiom.description, for: .normal)
            }
            
            titleLabel.text = "В пути"
        case .endTrip:
            guard let user = user else { return }
            
            if user.accountType == .driver {
                actionButton.setTitle("Прибыли к месту назначения", for: .normal)
                actionButton.isEnabled = false
            } else {
                buttonActiom = .dropOff
                actionButton.setTitle(buttonActiom.description, for: .normal)
            }

        case .driverArrived:
            guard let user = user else { return }
            
            if user.accountType == .driver {
                titleLabel.text = "Водитель прибыл"
                addressLabel.text = "Пожалуйста, выходите"
            }
            
            titleLabel.text = "Вы приехали"
        }
    }
    
}
