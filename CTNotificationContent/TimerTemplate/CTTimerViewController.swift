import UIKit

class CTTimerViewController: UIViewController {
    @IBOutlet weak var countdownLabel: UILabel!
    @IBOutlet weak var timerMessageLabel: UILabel!
    var seconds = 3603
    var timer = Timer()
    var timermessage = "Done the timer"
    var basictimercountdown: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        seconds = Int(basictimercountdown) ?? 10
        seconds -= 1
        
        countdownLabel.textColor = .white
        countdownLabel.text = basictimercountdown
        timerMessageLabel.textColor = .white
        timerMessageLabel.text = "snooze remaining"

        
        // Do any additional setup after loading the view.
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    @objc func updateTimer () {
    
        let hr = seconds / 3600
        let min = seconds / 60 % 60
        let sec = seconds % 60
    
        if seconds > 0 {
            if hr < 1 {
                self.countdownLabel.text = String(format: "%02i:%02i", min, sec)
            }
            else {
                self.countdownLabel.text = String(format: "%02i:%02i:%02i", hr, min, sec)
            }
            seconds -= 1
        } else {
            timer.invalidate()
    
            self.countdownLabel.text! = self.timermessage
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    public init() {
        super.init(nibName: "CTTimerViewController", bundle: Bundle(for: CTTimerViewController.self))
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
