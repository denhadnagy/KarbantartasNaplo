//
//  SummaryViewController.swift
//  KarbantartasNaplo
//
//  Created by Daniel on 2018. 06. 19..
//  Copyright © 2018. Daniel. All rights reserved.
//

import UIKit
import Charts

class SummaryViewController: UIViewController {
    //MARK: - Outlets
    @IBOutlet private var infoView: UIView!
    @IBOutlet private weak var infoCircleView: CircleView!
    @IBOutlet private weak var infoDescriptionLabel: UILabel!
    @IBOutlet private weak var navigationBar: UINavigationBar!
    @IBOutlet private weak var urgentView: SeverityView!
    @IBOutlet private weak var actualView: SeverityView!
    @IBOutlet private weak var soonView: SeverityView!
    @IBOutlet private weak var okView: SeverityView!
    @IBOutlet private weak var pieChartView: PieChartView!
    @IBOutlet private weak var devicesCountLabel: UILabel!
    
    //MARK: - Properties
    private var visualEffectView: UIVisualEffectView!
    
    //MARK: - Standard functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.delegate = self
        
        infoView.alpha = 0
        infoView.layer.cornerRadius = 10
        infoView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        infoView.translatesAutoresizingMaskIntoConstraints = false
        
        urgentView.severity = Severity.urgent
        actualView.severity = Severity.actual
        soonView.severity = Severity.soon
        okView.severity = Severity.ok
        urgentView.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        actualView.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        soonView.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        okView.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        pieChartView.chartDescription?.text = nil
        pieChartView.drawHoleEnabled = false
        pieChartView.noDataText = "Nincsenek adatok"
        pieChartView.legend.font = UIFont.systemFont(ofSize: 14, weight: .thin)
        pieChartView.legend.setCustom(entries: [
            LegendEntry(label: nil, form: .circle, formSize: CGFloat.nan, formLineWidth: CGFloat.nan, formLineDashPhase: CGFloat.nan, formLineDashLengths: nil, formColor: Severity.urgent.color),
            LegendEntry(label: nil, form: .circle, formSize: CGFloat.nan, formLineWidth: CGFloat.nan, formLineDashPhase: CGFloat.nan, formLineDashLengths: nil, formColor: Severity.actual.color),
            LegendEntry(label: nil, form: .circle, formSize: CGFloat.nan, formLineWidth: CGFloat.nan, formLineDashPhase: CGFloat.nan, formLineDashLengths: nil, formColor: Severity.soon.color),
            LegendEntry(label: nil, form: .circle, formSize: CGFloat.nan, formLineWidth: CGFloat.nan, formLineDashPhase: CGFloat.nan, formLineDashLengths: nil, formColor: Severity.ok.color)
            ])
        setChartLegendPosition()
        
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let urgentCount = DataCenter.shared.devices.filter({ $0.severity == .urgent }).count
        let actualCount = DataCenter.shared.devices.filter({ $0.severity == .actual }).count
        let soonCount = DataCenter.shared.devices.filter({ $0.severity == .soon }).count
        let okCount = DataCenter.shared.devices.filter({ $0.severity == .ok }).count
        let undefinedCount = DataCenter.shared.devices.count - urgentCount - actualCount - soonCount - okCount
        
        urgentView.deviceCount = urgentCount
        actualView.deviceCount = actualCount
        soonView.deviceCount = soonCount
        okView.deviceCount = okCount
        
        if DataCenter.shared.devices.count > 0 {
            let urgentRate = Double(urgentCount) / Double(DataCenter.shared.devices.count) * 100
            let actualRate = Double(actualCount) / Double(DataCenter.shared.devices.count) * 100
            let soonRate = Double(soonCount) / Double(DataCenter.shared.devices.count) * 100
            let okRate = Double(okCount) / Double(DataCenter.shared.devices.count) * 100
            let undefinedRate = Double(undefinedCount) / Double(DataCenter.shared.devices.count) * 100
            
            pieChartView.legend.entries[0].label = "\(String(format: "%.0f", urgentRate))%"
            pieChartView.legend.entries[1].label = "\(String(format: "%.0f", actualRate))%"
            pieChartView.legend.entries[2].label = "\(String(format: "%.0f", soonRate))%"
            pieChartView.legend.entries[3].label = "\(String(format: "%.0f", okRate))%"
            
            var chartDataEntries = [PieChartDataEntry]()
            chartDataEntries.append(PieChartDataEntry(value: urgentRate))
            chartDataEntries.append(PieChartDataEntry(value: actualRate))
            chartDataEntries.append(PieChartDataEntry(value: soonRate))
            chartDataEntries.append(PieChartDataEntry(value: okRate))
            chartDataEntries.append(PieChartDataEntry(value: undefinedRate))
            
            let pieChartDataSet = PieChartDataSet(values: chartDataEntries, label: nil)
            pieChartDataSet.colors = [Severity.urgent.color, Severity.actual.color, Severity.soon.color, Severity.ok.color, Severity.undefined.color]
            pieChartDataSet.sliceSpace = 1
            pieChartDataSet.selectionShift = 5
            pieChartDataSet.drawValuesEnabled = false
            
            pieChartView.data = PieChartData(dataSet: pieChartDataSet)
            pieChartView.animate(yAxisDuration: 0.5)
        }
        
        devicesCountLabel.text = "\(DataCenter.shared.devices.count) eszköz"
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if view.subviews.contains(infoView) { closePopupView(popupView: infoView) }
    }
    
    //Function will fire (in case of rotating device) even if view has not yet loaded.
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if pieChartView != nil { setChartLegendPosition() }
    }
    
    private func setChartLegendPosition() {
        if UIDevice.current.orientation.isPortrait || UIDevice.current.orientation.isFlat {
            pieChartView.legend.orientation = .vertical
            pieChartView.legend.horizontalAlignment = .left
            pieChartView.legend.verticalAlignment = .top
        } else {
            pieChartView.legend.orientation = .horizontal
            pieChartView.legend.horizontalAlignment = .center
            pieChartView.legend.verticalAlignment = .bottom
        }
    }
    
    //MARK: - Actions
    @IBAction func severityViewTap(_ sender: UITapGestureRecognizer) {
        let severityView = sender.view as! SeverityView
        infoCircleView.color = severityView.severity.color
        infoDescriptionLabel.text = severityView.severity.description
        
        showPopupView(popupView: infoView)
    }
    
    @IBAction func infoViewCloseButtonTouchUpInside(_ sender: UIButton) {
        closePopupView(popupView: infoView)
    }
    
    //MARK: - Common functions
    private func showPopupView(popupView: UIView) {
        visualEffectView = UIVisualEffectView()
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(visualEffectView)
        visualEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        visualEffectView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor).isActive = true
        visualEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        visualEffectView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        view.addSubview(popupView)
        popupView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        popupView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        popupView.widthAnchor.constraint(equalToConstant: 240).isActive = true
        popupView.heightAnchor.constraint(equalToConstant: 160).isActive = true
        
        UIView.animate(withDuration: 0.2) {
            self.visualEffectView.effect = UIBlurEffect(style: .regular)
            popupView.transform = CGAffineTransform.identity
            popupView.alpha = 1
        }
    }
    
    private func closePopupView(popupView: UIView) {
        UIView.animate(withDuration: 0.2, animations: {
            popupView.alpha = 0
            popupView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.visualEffectView.effect = nil
        }) { completion in
            self.visualEffectView.removeFromSuperview()
            self.visualEffectView = nil
            popupView.removeFromSuperview()
        }
    }
}

//MARK: - Extensions
extension SummaryViewController: UINavigationBarDelegate {
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.topAttached
    }
}
