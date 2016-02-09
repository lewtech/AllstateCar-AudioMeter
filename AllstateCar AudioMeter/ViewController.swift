import Foundation
import UIKit
import AVFoundation
import CoreAudio

class ViewController: UIViewController {

    @IBOutlet weak var currentLevelLbl: UILabel!
    @IBOutlet weak var currentLevelLbl1: UILabel!
    @IBOutlet weak var currentLevelLbl2: UILabel!
    @IBOutlet weak var currentLevelLbl3: UILabel!
    @IBOutlet weak var currentLevelLbl4: UILabel!



    @IBOutlet weak var statusImg: UIImageView!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var inputLevelLabel: UITextField!
    var recorder: AVAudioRecorder!
    var levelTimer = NSTimer()
    var lowPassResults: Double = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()

        //make an AudioSession, set it to PlayAndRecord and make it active
        let audioSession:AVAudioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
        } catch _ {
        }
        do {
            try audioSession.setActive(true)
        } catch _ {
        }

        //set up the URL for the audio file
        let documents: AnyObject = NSSearchPathForDirectoriesInDomains( NSSearchPathDirectory.DocumentDirectory,  NSSearchPathDomainMask.UserDomainMask, true)[0]
        let str =  documents.stringByAppendingPathComponent("recordTest.caf")
        let url = NSURL.fileURLWithPath(str as String)

        // make a dictionary to hold the recording settings so we can instantiate our AVAudioRecorder
        let recordSettings: [String : AnyObject]  = [
            AVFormatIDKey:NSNumber(unsignedInt:kAudioFormatAppleIMA4),
            AVSampleRateKey:44100.0,
            AVNumberOfChannelsKey:2,AVEncoderBitRateKey:12800,
            AVLinearPCMBitDepthKey:16,
            AVEncoderAudioQualityKey:AVAudioQuality.Max.rawValue

        ]




            try! recorder = AVAudioRecorder(URL:url, settings: recordSettings)

        //If there's an error, print it - otherwise, run prepareToRecord and meteringEnabled to turn on metering (must be run in that order)

            recorder.prepareToRecord()
            recorder.meteringEnabled = true

            //start recording


            //instantiate a timer to be called with whatever frequency we want to grab metering values
            self.levelTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("levelTimerCallback"), userInfo: nil, repeats: true)

        }



    //This selector/function is called every time our timer (levelTime) fires
    func levelTimerCallback() {
        //we have to update meters before we can get the metering values
        recorder.record()
        recorder.updateMeters()

        //print to the console if we are beyond a threshold value. Here I've used -7
        currentLevelLbl.text = "\(recorder.averagePowerForChannel(0))"
        //currentLevelLbl1.text = "\(recorder.averagePowerForChannel(1))"
        //currentLevelLbl2.text = "\(recorder.peakPowerForChannel(0))"

        if recorder.averagePowerForChannel(0) > -30 {
            print("db > -20 ", terminator: "")
            statusLbl.text = "TOO LOUD"
            statusImg.image = UIImage(named: "farTooLoud.jpeg")

        } else {
            statusLbl.text = "NORMAL"
            statusImg.image = UIImage(named: "ok.jpeg")
        }
        recorder.stop()


    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}