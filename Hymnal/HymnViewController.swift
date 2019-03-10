//
//  HymnViewController.swift
//  Hymnal
//
//  Created by Jacob Marttinen on 4/30/17.
//  Copyright © 2017 Jacob Marttinen. All rights reserved.
//

import UIKit

// MARK: - HymnViewController: UIViewController

class HymnViewController: UIViewController {
    
    // MARK: Properties
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var number : Int!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    var impactGenerator: UIImpactFeedbackGenerator? = nil
    var selectionGenerator: UISelectionFeedbackGenerator? = nil
    
    // MARK: Outlets
    
    @IBOutlet weak var hymnText: UITextView!
    @IBOutlet weak var hymnNumber: UILabel!
    
    // MARK: Actions
    
    @IBAction func backOne(_ sender: Any) {
        setNumber(to: number - 1, withFeedback: true)
    }
    
    @IBAction func forwardOne(_ sender: Any) {
        setNumber(to: number + 1, withFeedback: true)
    }
    
    @IBAction func adjustFontSize(_ sender: UIPinchGestureRecognizer) {
        if sender.state == .began || sender.state == .changed {
            multiplyFontSize(by: sender.scale)
            sender.scale = 1.0
        }
    }
    
    @IBAction func lightswitchTap(_ sender: Any) {
        switch appDelegate.theme {
        case .light:
            setTheme(to: .dark, withFeedback: true)
        case .dark:
            setTheme(to: .black, withFeedback: true)
        case .black:
            setTheme(to: .light, withFeedback: true)
        }
    }
    
    @IBAction func hymnNumberTap(_ sender: Any) {
        returnToRoot(direction: CATransitionSubtype.fromBottom)
    }
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        initialiseUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        hymnText.contentOffset = CGPoint.zero
        hymnText.scrollRangeToVisible(NSRange(location: 0, length: 0))
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    // MARK: UI+UX Functionality
    
    private func initialiseUI() {
        
        hymnText.delegate = self
        hymnText.textContainerInset = UIEdgeInsets.init(top: 0, left: 15, bottom: 15, right: 15)
    }
    
    private func updateUI() {
        
        setNumber(to: number, withFeedback: false)
        setFontSize(to: appDelegate.hymnFontSize, withFeedback: false)
        setTheme(to: appDelegate.theme, withFeedback: false)
    }
    
    private func adjustFontSize(by sizeDifference: Int) {
        setFontSize(to: appDelegate.hymnFontSize + CGFloat(sizeDifference), withFeedback: true)
    }
    
    private func multiplyFontSize(by sizeDifference: CGFloat) {
        setFontSize(to: appDelegate.hymnFontSize * (1 - ((1 - sizeDifference) / 3)), withFeedback: true)
    }
    
    private func setFontSize(to newSize: CGFloat, withFeedback: Bool) {
        if withFeedback == true {
            selectionGenerator = UISelectionFeedbackGenerator()
            selectionGenerator?.prepare()
        }
        
        var usingSize = newSize
        
        if newSize.isNaN {
            usingSize = 24
        } else if newSize < 1 {
            usingSize = 1
        } else if newSize > 500 {
            usingSize = 500
        }
        
        let newHymnText = NSMutableAttributedString(attributedString: hymnText.attributedText)
        
        newHymnText.enumerateAttribute(
            NSAttributedString.Key.font, in: NSMakeRange(0, newHymnText.length), options: []
        ) { value, range, stop in
            
            guard let currentFont = value as? UIFont else {
                selectionGenerator = nil
                return
            }
            let newFont = UIFont(descriptor: currentFont.fontDescriptor, size: usingSize)
            newHymnText.addAttributes([NSAttributedString.Key.font: newFont], range: range)
        }
        
        hymnText.attributedText = newHymnText
        
        // Feedback on whole number font sizes
        if withFeedback == true && (abs(floor(appDelegate.hymnFontSize) - floor(usingSize)) > 0) {
            selectionGenerator?.selectionChanged()
        }
        
        appDelegate.hymnFontSize = usingSize
        UserDefaults.standard.set(Double(appDelegate.hymnFontSize), forKey: "hymnFontSize")
        UserDefaults.standard.synchronize()
        
        selectionGenerator = nil
    }
    
    private func setNumber(to newNumber: Int, withFeedback: Bool) {
        if withFeedback {
            impactGenerator = UIImpactFeedbackGenerator(style: .medium)
            impactGenerator?.prepare()
        }
        
        // Make sure the hymnal exists
        guard let hymnal = Hymnal.hymnal else {
            returnToRoot(direction: CATransitionSubtype.fromBottom)
            impactGenerator = nil
            return
        }
        
        // Make sure the user isn't picking an invalid hymn number
        if newNumber > hymnal.hymns.count || newNumber <= 0 {
            impactGenerator = nil
            return
        }
        
        if withFeedback {
            impactGenerator?.impactOccurred()
        }
        
        // Set properties
        number = newNumber
        
        // Set up basic text attributes
        var textColor = Constants.UI.Armadillo
        if appDelegate.theme != .light {
            textColor = .white
        }
        
        var italicSections = [Int:Int]()
        var boldSections = [Int:Int]()
        
        // Create initial pass of hymn string
        var hymnStringRaw = ""
        var verseCount = 1
        for line in hymnal.hymns[number - 1].verses {
            
            if hymnStringRaw != "" {
                hymnStringRaw = "\(hymnStringRaw)\n\n"
            }
            
            let parsedLine = parseBoldTags(
                "\(verseCount). \(line)",
                boldSections: &boldSections,
                currentIndex: hymnStringRaw.count
            )
            hymnStringRaw = "\(hymnStringRaw)\(parsedLine)"
            verseCount = verseCount + 1
            
            if let chorus = hymnal.hymns[number - 1].chorus {
                
                hymnStringRaw = "\(hymnStringRaw)\n\nChorus: "
                italicSections[hymnStringRaw.count - 8] = 7
                
                let parsedChorus = parseBoldTags(
                    chorus,
                    boldSections: &boldSections,
                    currentIndex: hymnStringRaw.count
                )
                hymnStringRaw = "\(hymnStringRaw)\(parsedChorus)"
            } else if let refrain = hymnal.hymns[number - 1].refrain {
                
                hymnStringRaw = "\(hymnStringRaw)\n\nRefrain: "
                italicSections[hymnStringRaw.count - 9] = 8
                
                let parsedRefrain = parseBoldTags(
                    refrain,
                    boldSections: &boldSections,
                    currentIndex: hymnStringRaw.count
                )
                hymnStringRaw = "\(hymnStringRaw)\(parsedRefrain)"
            }
        }
        
        
        // Create attributed hymn string
        let hymnString = NSMutableAttributedString(
            string: hymnStringRaw,
            attributes: [
                NSAttributedString.Key.foregroundColor: textColor,
                NSAttributedString.Key.font: UIFont.init(name: "AdobeHebrew-Regular", size: appDelegate.hymnFontSize)!
            ]
        )
        for (key, value) in italicSections {
            
            hymnString.addAttribute(
                NSAttributedString.Key.font,
                value: UIFont.init(name: "AdobeHebrew-Italic", size: appDelegate.hymnFontSize)!,
                range: NSMakeRange(key, value)
            )
        }
        for (key, value) in boldSections {
            
            hymnString.addAttribute(
                NSAttributedString.Key.font,
                value: UIFont.init(name: "AdobeHebrew-Bold", size: appDelegate.hymnFontSize)!,
                range: NSMakeRange(key, value)
            )
        }
        
        // Set UI
        hymnNumber.text = " \(String(number))"
        hymnText.attributedText = hymnString
        hymnText.contentOffset = CGPoint.zero
        hymnText.scrollRangeToVisible(NSRange(location: 0, length: 0))

        // Set number on root
        if let parentVC = presentingViewController as? HomeViewController {
            parentVC.hymnNumberInput.text = "\(String(number))"
        }
        
        impactGenerator = nil
    }
    
    // This is obviously not the optimal way of parsing but it gets the job done for now
    private func parseBoldTags(_ line: String, boldSections: inout [Int:Int], currentIndex: Int) -> String {
        
        var parsedLine = ""
        
        let bOpenArray = line.components(separatedBy: "<b>")
        
        for bOpen in bOpenArray {
            
            // Find the closing tag
            let bCloseArray = bOpen.components(separatedBy: "</b>")
            
            // Only bold a section if there's at least one <b> and one </b>
            if bOpenArray.count > 1 && bCloseArray.count > 1 {
                // Find the index of the closing tag
                boldSections[parsedLine.count + currentIndex] = bCloseArray[0].count
            }
            
            // Create the rest of the string
            // Loop in case there was a messed up tag situation
            for bClose in bCloseArray {
                parsedLine = "\(parsedLine)\(bClose)"
            }
        }
        
        return parsedLine
    }
    
    private func setTheme(to theme: Constants.Themes, withFeedback: Bool) {
        if withFeedback {
            impactGenerator = UIImpactFeedbackGenerator(style: .heavy)
            impactGenerator?.prepare()
        }
        
        appDelegate.theme = theme
        UserDefaults.standard.set(appDelegate.theme.rawValue, forKey: "theme")
        UserDefaults.standard.synchronize()
        
        if withFeedback {
            impactGenerator?.impactOccurred()
        }
        
        let newHymnText = NSMutableAttributedString(attributedString: hymnText.attributedText)
        
        switch appDelegate.theme {
        case .light:
            view.backgroundColor = .white
            
            hymnNumber.textColor = Constants.UI.Armadillo
            hymnNumber.backgroundColor = .white
            
            hymnText.backgroundColor = .white
            
            newHymnText.enumerateAttribute(
                NSAttributedString.Key.foregroundColor,
                in: NSMakeRange(0, newHymnText.length),
                options: []
            ) { value, range, stop in
                
                newHymnText.addAttributes(
                    [
                        NSAttributedString.Key.foregroundColor: Constants.UI.Armadillo
                    ],
                    range: range
                )
            }
        case .dark:
            view.backgroundColor = Constants.UI.Armadillo
            
            hymnNumber.textColor = .white
            hymnNumber.backgroundColor = Constants.UI.Armadillo
            
            hymnText.backgroundColor = Constants.UI.Armadillo
            
            newHymnText.enumerateAttribute(
                NSAttributedString.Key.foregroundColor,
                in: NSMakeRange(0, newHymnText.length),
                options: []
            ) { value, range, stop in
                
                newHymnText.addAttributes(
                    [
                        NSAttributedString.Key.foregroundColor: UIColor.white
                    ],
                    range: range
                )
            }
        case .black:
            view.backgroundColor = .black
            
            hymnNumber.textColor = .white
            hymnNumber.backgroundColor = .black
            
            hymnText.backgroundColor = .black
            
            newHymnText.enumerateAttribute(
                NSAttributedString.Key.foregroundColor,
                in: NSMakeRange(0, newHymnText.length),
                options: []
            ) { value, range, stop in
                
                newHymnText.addAttributes(
                    [
                        NSAttributedString.Key.foregroundColor: UIColor.white
                    ],
                    range: range
                )
            }
        }
        
        hymnText.attributedText = newHymnText
        
        impactGenerator = nil
    }
    
    // MARK: Supplementary Functions
    
    private func returnToRoot(direction: CATransitionSubtype) {
        impactGenerator = UIImpactFeedbackGenerator(style: .medium)
        impactGenerator?.prepare()
        impactGenerator?.impactOccurred()
        impactGenerator = nil
        
        let transition: CATransition = CATransition()
        transition.duration = 0.25
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.reveal
        transition.subtype = direction
        self.view.window!.layer.add(transition, forKey: nil)
        
        dismiss(animated: false, completion: nil)
    }
}

// MARK: - HymnViewController: UITextFieldDelegate

extension HymnViewController: UITextViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < (scrollView.verticalOffsetForTop - 100) {
            returnToRoot(direction: CATransitionSubtype.fromBottom)
        } else if scrollView.contentOffset.y > (scrollView.verticalOffsetForBottom + 200) {
            returnToRoot(direction: CATransitionSubtype.fromTop)
        }
    }
}

// MARK: - UIScrollView

extension UIScrollView {
    
    var isAtTop: Bool {
        return contentOffset.y <= verticalOffsetForTop
    }
    
    var isAtBottom: Bool {
        return contentOffset.y >= verticalOffsetForBottom
    }
    
    var verticalOffsetForTop: CGFloat {
        let topInset = contentInset.top
        return -topInset
    }
    
    var verticalOffsetForBottom: CGFloat {
        let scrollViewHeight = bounds.height
        let scrollContentSizeHeight = contentSize.height
        let bottomInset = contentInset.bottom
        let scrollViewBottomOffset = scrollContentSizeHeight + bottomInset - scrollViewHeight
        return scrollViewBottomOffset
    }
}
