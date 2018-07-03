//
//  VlogCommentsVC.swift
//  Marble
//
//  Created by Daniel Li on 6/21/18.
//  Copyright © 2018 Marble, LLC. All rights reserved.
//

import UIKit

class VlogCommentsVC: UIViewController {

    @IBOutlet weak var commentsTable: UITableView!
    @IBOutlet weak var postCommentView: UIView!
    @IBOutlet weak var commentTextView: GrowingTextView!
    
    @IBOutlet weak var postCommentBot: NSLayoutConstraint!
    
    var postCommentBotStart: CGFloat = CGFloat(0)
    var loading: Bool = true
    var vlog: Vlog?
    
    var modalDelegate: DeckTransitioningDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        commentsTable.dataSource = self
        commentsTable.register(UINib(nibName: "CommentTVCell", bundle: nil), forCellReuseIdentifier: "CommentCell")
        commentsTable.separatorStyle = .none
        commentsTable.allowsSelection = false
        commentsTable.alwaysBounceVertical = true
        
        commentsTable.delegate = self
        commentTextView.delegate = self
        
        if isIPhoneX() {
            postCommentBotStart = postCommentBot.constant
        } else {
            postCommentBotStart = 0
        }
        
        postCommentBot.constant = postCommentBotStart
        self.view.layoutIfNeeded()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardNotification(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillChangeFrame,
                                               object: nil)
        
        commentTextView.layer.cornerRadius = 5
        commentTextView.layer.borderColor = UIColor(white: 0.7, alpha: 1.0).cgColor
        commentTextView.layer.borderWidth = 1
        commentTextView.placeholderColor = UIColor(white: 0.5, alpha: 1.0)
        commentTextView.textContainerInset = UIEdgeInsetsMake(10, 12, 10, 45)
        
        
        initActivityIndicator()
        startActivityIndicator()
        
        State.shared.getVlogComments(vlogId: vlog!.id) { (comments) in
            self.stopActivityIndicator()
            self.loading = false
            self.vlog?.comments = comments
            self.commentsTable.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if vlog?.comments.count ?? 0 > 0 {
            commentsTable.scrollToRow(at: IndexPath(row: vlog!.comments.count - 1, section: 0), at: .bottom, animated: true)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    var loadingIndicator = UIActivityIndicatorView()
    
    func initActivityIndicator() {
        loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.center = self.view.center
        loadingIndicator.backgroundColor = UIColor(red: 219/250, green: 219/250, blue: 219/250, alpha: 1.0)
        self.commentsTable.backgroundView = loadingIndicator
    }
    
    func startActivityIndicator() {
        loadingIndicator.startAnimating()
    }
    
    func stopActivityIndicator() {
        loadingIndicator.stopAnimating()
        let view = UIView(frame: self.view.frame)
        let label = UILabel(frame: CGRect(x: 0, y: 20, width: self.commentsTable.frame.width, height: 25))
        view.center = self.view.center
        label.text = "No comments...yet"
        label.alpha = 0.6
        label.textAlignment = .center
        view.addSubview(label)
        view.backgroundColor = UIColor.white
        self.commentsTable.backgroundView = view
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let endFrameY = endFrame?.origin.y ?? 0
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            if endFrameY >= UIScreen.main.bounds.size.height {
                self.postCommentBot.constant = self.postCommentBotStart
            } else {
                self.postCommentBot.constant = endFrame?.size.height ?? self.postCommentBotStart
            }
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        UIApplication.shared.statusBarStyle = .default
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func doneBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func postCommentPressed(_ sender: Any) {
        guard let commentContent = commentTextView.text else {
            return
        }
        if commentContent == "" {
            return
        }
        Networker.shared.postComment(vlogId: vlog!.id, content: commentContent) { (resp) in
            switch resp.result {
            case .success(let val):
                let contentJson = JSON(val)
                let commentJson = contentJson["comment"]
                
                let commentId = commentJson["id"].intValue
                let content = commentJson["content"].stringValue
                let timestamp = commentJson["timestamp"].int64Value
                let newComment = Comment(id: commentId, user: State.shared.me!, content: content, timestamp: timestamp)
                self.vlog?.comments.insert(newComment, at: 0)
                self.commentsTable.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                self.commentTextView.resignFirstResponder()
                self.commentTextView.text = ""
            case .failure:
                print(resp.debugDescription)
            }
        }
    }
}

extension VlogCommentsVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return loading ? 0 : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vlog!.comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentTVCell
        
        let comment = vlog!.comments[indexPath.row]
        
        let commentAttrText = NSMutableAttributedString()
        commentAttrText
            .bold(comment.user.username, font: UIFont.boldSystemFont(ofSize: UIFont.labelFontSize))
            .normal("  \(comment.content)")
        
        cell.commentLabel.attributedText = commentAttrText
        cell.setTime(timestamp: comment.timestamp)
        
        return cell
    }
    
}

extension VlogCommentsVC: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == commentsTable {
            if scrollView.contentOffset.y < 0 {
                scrollView.contentOffset = CGPoint.zero
                modalDelegate?.isDismissEnabled = true
            } else {
                modalDelegate?.isDismissEnabled = false
            }
            if commentTextView.isFirstResponder {
                commentTextView.resignFirstResponder()
            }
        }
    }
    
}

extension VlogCommentsVC: GrowingTextViewDelegate {
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
}
