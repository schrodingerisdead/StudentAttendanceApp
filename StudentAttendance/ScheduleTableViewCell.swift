//
//  ScheduleTableViewCell.swift
//  StudentAttendance
//
//  Created by Magdalena Oreshkova on 12/20/23.
//

import UIKit

protocol ScheduleTableViewCellDelegate: AnyObject {
    func didTapAttendButton(in cell: ScheduleTableViewCell)
}
class ScheduleTableViewCell: UITableViewCell {

   // @IBOutlet weak var SubjectName: UILabel!
    @IBOutlet weak var SubjectName: UILabel!
   // @IBOutlet weak var SubjectDateAndTime: UILabel!
    @IBOutlet weak var SubjectDateAndTime: UILabel!
  //  @IBOutlet weak var Attend: UIButton!

    @IBOutlet weak var Attend: UIButton!
    
    weak var delegate: ScheduleTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func AttendClicked(_ sender: Any) {
        delegate?.didTapAttendButton(in: self)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
