//
//  PLFriendsViewController.swift
//  Pals
//
//  Created by Карпенко Михайло on 05.09.16.
//  Copyright © 2016 citirex. All rights reserved.
//

class PLFriendsViewController: PLViewController, UITableViewDataSource, UISearchBarDelegate, UITableViewDelegate {
	
	private var resultsController: UITableViewController!
	private var searchController: PLSearchController!
	var containerView = UIView()
	

	var tableView = UITableView()
	lazy var spinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    let datasource = PLFriendsDatasource(userId: PLFacade.profile!.id)

    private var selectedFriend: PLUser!
	
	
	@IBAction func searchButton(sender: AnyObject) {
		performSegueWithIdentifier("FriendSearchSegue", sender: self)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		navigationController?.setNavigationBarTransparent(false)
		configureSearchController()
		
		let nib = UINib(nibName: "PLFriendCell", bundle: nil)
		tableView.registerNib(nib, forCellReuseIdentifier: "FriendCell")
		tableView.keyboardDismissMode = .OnDrag
		tableView.separatorInset.left = 75
		
		tableView.delegate = self
		tableView.dataSource = self
		containerView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: view.bounds.width, height: view.bounds.height))
		containerView.backgroundColor = .whiteColor()
		tableView.backgroundView = containerView
		
		view.addSubview(tableView)
		view.addSubview(spinner)

		spinner.center = view.center
		spinner.color = .grayColor()
        loadDatasource()
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		navigationItem.title = "Friends"
		navigationItem.titleView?.tintColor = .vividViolet()
		navigationController?.navigationBar.tintColor = .vividViolet()
	}
	
	override func viewDidLayoutSubviews() {
		tableView.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height)
		resultsController.tableView.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height - 49)
	}
	
	func scrollViewDidScroll(scrollView: UIScrollView) {
		if scrollView.contentOffset.y < -20 {
		navigationController?.navigationBar.addBottomBorderWithColor(.miracleColor(), width: 0.5)
		} else {
		navigationController?.navigationBar.addBottomBorderWithColor(.lightGrayColor(), width: 0.5)
		}
	}
	
    func loadDatasource() {
		self.spinner.startAnimating()
        datasource.load {[unowned self] (page, error) in
            if error == nil {
				let count = self.datasource.count
				let lastLoadedCount = page.count
				if lastLoadedCount > 0 {
					var indexPaths = [NSIndexPath]()
					for i in count - lastLoadedCount..<count {
						indexPaths.append(NSIndexPath(forRow: i, inSection: 0))
					}
					self.tableView.beginUpdates()
					self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Bottom)
					self.tableView.endUpdates()
				}
				self.spinner.stopAnimating()
			} else {
				PLShowAlert("Error!", message: "Cannot download your friends.")
			}
        }
    }
	
	// MARK: - Initialize search controller
	
	private func configureSearchController() {
		let nib = UINib(nibName: "PLFriendCell", bundle: nil)
		resultsController = UITableViewController(style: .Plain)
		resultsController.tableView.registerNib(nib, forCellReuseIdentifier: "FriendCell")
		resultsController.tableView.backgroundColor = .miracleColor()
		resultsController.tableView.tableFooterView = UIView()
		resultsController.tableView.rowHeight = 100.0
		resultsController.tableView.dataSource = self
		resultsController.tableView.delegate = self
		resultsController.tableView.keyboardDismissMode = .OnDrag
		resultsController.tableView.separatorInset.left = 75
		
		searchController = PLSearchController(searchResultsController: resultsController)
		searchController.searchBar.placeholder = "Find Your Pals"
		searchController.searchBar.backgroundColor = .miracleColor()
		searchController.searchBar.barTintColor = .miracleColor()
		searchController.searchBar.backgroundImage = UIImage()
		searchController.searchBar.tintColor = .affairColor()
		searchController.searchResultsUpdater = self
		searchController.dimsBackgroundDuringPresentation = false
		searchController.searchBar.addBottomBorderWithColor(.lightGrayColor(), width: 0.5)
		let textFieldInsideSearchBar = searchController.searchBar.valueForKey("searchField") as? UITextField
		textFieldInsideSearchBar?.layer.borderWidth = 1
		textFieldInsideSearchBar?.layer.borderColor = UIColor.lightGrayColor().CGColor
		textFieldInsideSearchBar?.cornerRadius = 14
		searchController.searchBar.delegate = self
		tableView.tableHeaderView = searchController.searchBar
		definesPresentationContext = true
	}
	
	func searchBarSearchButtonClicked(searchBar: UISearchBar) {
		performSegueWithIdentifier("FriendSearchSegue", sender: self)
	}
	
	
	
	// MARK: - tableView
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
		return datasource.count
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell 	{
		
		let cell = tableView.dequeueReusableCellWithIdentifier("FriendCell", forIndexPath: indexPath) as! PLFriendCell
		
		let friend = datasource[indexPath.row]
		
			cell.friend = friend
		cell.accessoryType = .DisclosureIndicator
		
		return cell
	}
	
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
		if datasource.shouldLoadNextPage(indexPath) { loadDatasource() }
    }
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
        selectedFriend = datasource[indexPath.row]
        performSegueWithIdentifier("FriendProfileSegue", sender: self)
	}
	
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return 100
	}
	
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let identifier = segue.identifier else { return }
        switch identifier {
        case "FriendProfileSegue":
            let friendProfileViewController = segue.destinationViewController as! PLFriendProfileViewController
            friendProfileViewController.friend = selectedFriend
        case "FriendSearchSegue":
            let friendSearchViewController = segue.destinationViewController as! PLFriendsSearchViewController
            friendSearchViewController.seekerText = searchController.searchBar.text
        default:
            break
        }
    }
}

// MARK: - UISearchControllerDelegate

extension PLFriendsViewController : UISearchControllerDelegate {
	func willDismissSearchController(searchController: UISearchController) {
		let offset = tableView.contentOffset.y + tableView.contentInset.top
		if offset >= searchController.searchBar.frame.height {
			UIView.animateWithDuration(0.25) {
				searchController.searchBar.alpha = 0
			}
		}
	}
	
	func didDismissSearchController(searchController: UISearchController) {
		if searchController.searchBar.alpha == 0 {
			UIView.animateWithDuration(0.25) {
				searchController.searchBar.alpha = 1
			}
		}
	}
}

// MARK: - UISearchResultsUpdating

extension PLFriendsViewController: UISearchResultsUpdating {
	
	func updateSearchResultsForSearchController(searchController: UISearchController) {
		datasource.searching = searchController.active
		let filter = searchController.searchBar.text!
		if filter.isEmpty {
			datasource.searching = false
		} else {
			spinner.startAnimating()
			
			datasource.filter({ (user) -> Bool in
				let tmp: NSString = user.name
				let range = tmp.rangeOfString(filter, options: NSStringCompareOptions.CaseInsensitiveSearch)
				return range.location != NSNotFound
			}) { [unowned self] in
				self.resultsController.tableView.reloadData()
				self.spinner.stopAnimating()
			}

		}
	}
}
