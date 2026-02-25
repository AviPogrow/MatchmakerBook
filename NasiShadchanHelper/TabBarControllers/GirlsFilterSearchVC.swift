//
//  GirlsFilterSearchVC.swift
//  NasiShadchanHelper
//
//  Created by Avi Pogrow on 1/29/26.
//  Copyright © 2026 user. All rights reserved.
//

import UIKit
import Firebase

enum MockGirls {

    // 👇 Keep this small and human-readable
    private static let base: [ShadchanGirl] = [

        ShadchanGirl(
            girlCell: "5551234567",
            girlLastName: "Test",
            girlFirstName: "Mock One",
            city: "Brooklyn",
            dobIntervalString: "98/05/22",
            dateCreated: "26/02/08",
            dateLastUpdate: 0,
            girlHeight: "5'4\"",
            sendResumeEmail: "",
            sendResumeText: "",
            lifePlans: ["FTL - 3-5"],
            status: "available",
            datingHistory: "",
            shadchanNotesNew: "",
            notesImageURL: "",
            resumeImageURL: "",
            photoImageURL: "",
            key: "base_1"
        ),

        ShadchanGirl(
            girlCell: "5559876543",
            girlLastName: "Sample",
            girlFirstName: "Mock Two",
            city: "Queens",
            dobIntervalString: "00/08/08",
            dateCreated: "26/02/08",
            dateLastUpdate: 0,
            girlHeight: "5'7\"",
            sendResumeEmail: "",
            sendResumeText: "",
            lifePlans: ["FTL - 5", "PTL - Working"],
            status: "available",
            datingHistory: "",
            shadchanNotesNew: "",
            notesImageURL: "",
            resumeImageURL: "",
            photoImageURL: "",
            key: "base_2"
        )
    ]

    // 👇 This is what your VC uses
    static let all: [ShadchanGirl] = {
        let targetCount = 60
        var result: [ShadchanGirl] = []
        result.reserveCapacity(targetCount)

        for i in 0..<targetCount {
            let b = base[i % base.count]

            let g = ShadchanGirl(
                girlCell: b.girlCell,
                girlLastName: b.girlLastName,
                girlFirstName: "\(b.girlFirstName) \(i + 1)", // unique
                city: b.city,
                dobIntervalString: b.dobIntervalString,
                dateCreated: b.dateCreated,
                dateLastUpdate: b.dateLastUpdate,
                girlHeight: b.girlHeight,
                sendResumeEmail: b.sendResumeEmail,
                sendResumeText: b.sendResumeText,
                lifePlans: b.lifePlans,
                status: b.status,
                datingHistory: b.datingHistory,
                shadchanNotesNew: b.shadchanNotesNew,
                notesImageURL: b.notesImageURL,
                resumeImageURL: b.resumeImageURL,
                photoImageURL: b.photoImageURL,
                key: "mock_\(i + 1)"
            )

            let age = g.calculateAgeFrom(dobString: g.dobIntervalString)
            g.computedAgeString = age > 0 ? "\(Int(age.rounded()))" : ""

            result.append(g)
        }

        return result
    }()
}

enum AgeTag: CaseIterable, Hashable {
    case nineteenToTwentyThree
    case twentyFourToTwentyEight
    case twentyNinePlus

    var title: String {
        switch self {
        case .nineteenToTwentyThree:
            return "19–23"
        case .twentyFourToTwentyEight:
            return "24–28"
        case .twentyNinePlus:
            return "29+"
        }
    }
    
    var ageRange: ClosedRange<Int> {
        switch self {
        case .nineteenToTwentyThree:
            return 19...23
        case .twentyFourToTwentyEight:
            return 24...28
        case .twentyNinePlus:
            return 29...120
        }
    }
    /// Optional helper if you ever need the old behavior
    static func tag(for age: Int) -> AgeTag? {
        return AgeTag.allCases.first { $0.ageRange.contains(age) }
    }
}

enum HeightTag: CaseIterable, Hashable {
    case underFive
    case fiveZeroToFiveTwo
    case fiveTwoToFiveFive
    case fiveSixToFiveEight
    case fiveNinePlus
    
    var title: String {
        switch self {
        case .underFive:
            return "Under 5'0\""
        case .fiveZeroToFiveTwo:
            return "5'0\" - 5'2\""
        case .fiveTwoToFiveFive:
            return "5'2\" - 5'5\""
        case .fiveSixToFiveEight:
            return "5'6\" - 5'8\""
        case .fiveNinePlus:
            return "5'9+\""
        }
    }
    
    /// Keeps your original inch logic intact
    var inchRange: ClosedRange<Int> {
        switch self {
        case .underFive:
            return 0...59
        case .fiveZeroToFiveTwo:
            return 60...61
        case .fiveTwoToFiveFive:
            return 62...65
        case .fiveSixToFiveEight:
            return 66...68
        case .fiveNinePlus:
            return 69...100
        }
    }
}
enum LifePlanTag: CaseIterable, Hashable {
    case ftlOneToThree
    case ftlThreeToFive
    case ftlFive
    case ftlFiveToSeven
    case ftlSevenPlus
    case ptlSchool
    case ptlWorking
    case ftwCollegeYeshiva
    case ftwCollegeNotYeshiva

    // ✅ Canonical strings used everywhere (chips, results, Firebase, filtering)
    var title: String {
        switch self {
        case .ftlOneToThree:        return "FTL - 1-3"
        case .ftlThreeToFive:      return "FTL - 3-5"
        case .ftlFive:             return "FTL - 5"
        case .ftlFiveToSeven:      return "FTL - 5-7"
        case .ftlSevenPlus:        return "FTL - 7+"
        case .ptlSchool:           return "PTL - S"
        case .ptlWorking:          return "PTL - W"
        case .ftwCollegeYeshiva:   return "FTW/S-YS"
        case .ftwCollegeNotYeshiva:return "FTW/S-NYS"
        }
    }
}

//normalizes legacy life plan strings to the newer
// strings used in chip titles
enum LifePlanNormalizer {

    static func normalize(_ s: String) -> String {
        let trimmed = s.trimmingCharacters(in: .whitespacesAndNewlines)

        switch trimmed {
        case "PTL - School": return "PTL - S"
        case "PTL - Working": return "PTL - W"
        case "FTW/College-Yeshiva Style": return "FTW/S-YS"
        case "FTW/College-Not Yeshiva Style": return "FTW/S-NYS"
        default: return trimmed
        }
    }

    static func normalizeArray(_ arr: [String]) -> [String] {
        arr.map(normalize)
    }
}

enum TagCategory: Int, CaseIterable {
    case height, age, lifePlans

    var title: String {
        switch self {
        case .height: return "Height"
        case .age: return "Age"
        case .lifePlans: return "Life Plans"
        }
    }
    
    var accentColor: UIColor {
        switch self {
        case .height:    return .systemBlue
        case .age:       return .systemGreen
        case .lifePlans: return .systemPurple
        }
    }
}

//MARK: GirlsFilterSearchVC
class GirlsFilterSearchVC: UIViewController {
    
    private var chipsHeightConstraint: NSLayoutConstraint!
    private var chipsCollapsed = false
    private let chipsExpandedHeight: CGFloat = 160
    private let chipsCollapsedHeight: CGFloat = 44   // or 0 if you want fully hidden
    // private var filtersExpandedHeight: CGFloat = 180   // your normal expanded height (or compute)
    //private let filtersPeekHeight: CGFloat = 52        // single-row-ish ribbon while keyboard is up
    private var areChipsCollapsed = false
    private var keyboardHeight: CGFloat = 0
    private var wasFiltersExpandedBeforeKeyboard: Bool = true
    
    
    
    // Add this near your VC properties:
    private var noteSnippetById: [String: NSAttributedString] = [:]
    
    private var titleAttrById: [String: NSAttributedString] = [:]
    private lazy var emptyStateView: EmptyStateView = {
        let v = EmptyStateView()
        
        // empty state view doesn't
        // describe what to do when clear is tapped
        // it just declares a callback closure
        // but here we fill in what should happen
        // and that is the clear tapped function
        // is triggered which resets alll the tags
        // and the search field etc.
        v.onClearTapped = { [weak self] in
            self?.clearTapped()
        }
        return v
    }()
    
    private lazy var resultsHeaderLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14, weight: .semibold)
        l.textColor = .secondaryLabel
        l.text = "Results"
        return l
    }()
    
    private lazy var filtersToggleButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Hide Filters", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        b.addTarget(self, action: #selector(toggleFiltersTapped), for: .touchUpInside)
        return b
    }()
    
    private func setFiltersToggleTitle(_ title: String, animated: Bool) {
        guard animated else {
            filtersToggleButton.setTitle(title, for: .normal)
            return
        }

        UIView.transition(
            with: filtersToggleButton,
            duration: 0.18,
            options: [.transitionCrossDissolve, .allowUserInteraction]
        ) {
            self.filtersToggleButton.setTitle(title, for: .normal)
            self.filtersToggleButton.layoutIfNeeded()
        }
    }
    
    @objc private func toggleFiltersTapped() {
        
        setChipsCollapsed(!areChipsCollapsed, animated: true)
    
    }
    
    private lazy var resultsHeaderView: UIView = {
        let v = UIView()
        v.backgroundColor = .systemBackground
        
        v.addSubview(resultsHeaderLabel)
        resultsHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        
        v.addSubview(filtersToggleButton)
        filtersToggleButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            filtersToggleButton.trailingAnchor.constraint(equalTo: v.trailingAnchor, constant: -16),
            filtersToggleButton.centerYAnchor.constraint(equalTo: resultsHeaderLabel.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            resultsHeaderLabel.leadingAnchor.constraint(equalTo: v.leadingAnchor, constant: 16),
            resultsHeaderLabel.trailingAnchor.constraint(equalTo: v.trailingAnchor, constant: -16),
            resultsHeaderLabel.topAnchor.constraint(equalTo: v.topAnchor, constant: 6),
            resultsHeaderLabel.bottomAnchor.constraint(equalTo: v.bottomAnchor, constant: -6)
        ])
        
        return v
    }()
    
    private func updateNavTitleAnimated() {
        let subtitle = filterSummaryText() ?? "\(filteredProfiles.count) results"
        
        UIView.transition(with: navTitleView,
                          duration: 0.25,
                          options: [.transitionCrossDissolve, .allowUserInteraction],
                          animations: {
            self.navTitleView.configure(title: "Search", subtitle: subtitle)
        })
    }
    
    private var girlsByKey: [String: ShadchanGirl] = [:]
    private var allResults: [ResultProfile] = []
    private var filteredResults: [ResultProfile] = []
    private var allProfiles: [MockProfile] = []
    private var filteredProfiles: [MockProfile] = []
    
    private var selectedHeightTags = Set<HeightTag>()
    private var selectedAgeTags = Set<AgeTag>()
    private var selectedLifePlans = Set<LifePlanTag>()
    
    private func heightTag(from title: String) -> HeightTag? {
        HeightTag.allCases.first { $0.title == title }
    }
    
    private func ageTag(from title: String) -> AgeTag? {
        AgeTag.allCases.first { $0.title == title }
    }
    
    private func lifePlanTag(from title: String) -> LifePlanTag? {
        LifePlanTag.allCases.first { $0.title == title }
    }
    
    private var selectedTagIDs = Set<UUID>()
    
    struct TagItem: Hashable {
        let id = UUID()
        let category: TagCategory
        let title: String
    }
    
    
    // MARK: - UI
    private let searchBar: UISearchBar = {
        let sb = UISearchBar(frame: .zero)
        sb.searchBarStyle = .minimal
        sb.placeholder = "Search"
        sb.autocapitalizationType = .none
        sb.autocorrectionType = .no
        
        let tf = sb.searchTextField
        tf.backgroundColor = .secondarySystemBackground
        tf.layer.cornerRadius = 10
        tf.layer.masksToBounds = true
        
        return sb
    }()

   

    private lazy var chipsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 4, left: 16, bottom: 12, right: 16)
        layout.headerReferenceSize = CGSize(width: 0, height: 28)
        
        // ✅ IMPORTANT: fixed 3-column grid (no self-sizing)
        layout.estimatedItemSize = .zero
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .clear
        cv.dataSource = self
        cv.delegate = self
        cv.allowsSelection = true
        cv.allowsMultipleSelection = true
        cv.showsVerticalScrollIndicator = false
        
        cv.register(ChipCell.self, forCellWithReuseIdentifier: ChipCell.reuseID)
        cv.register(
            ChipHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: ChipHeaderView.reuseID
        )
        return cv
    }()
    
    private let resultsTableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.keyboardDismissMode = .onDrag
        tv.tableFooterView = UIView()
        return tv
    }()
    
    private let navTitleView = NavTitleView()
    
    
    private lazy var tagsByCategory: [TagCategory: [TagItem]] = [
        .height: HeightTag.allCases.map {
            TagItem(category: .height, title: $0.title)
        },
        .age: AgeTag.allCases.map {
            TagItem(category: .age, title: $0.title)
        },
        .lifePlans: LifePlanTag.allCases.map {
            TagItem(category: .lifePlans, title: $0.title)
        }
    ]
    
    private var results = (1...15).map { "Result \($0)" }
    private let useFirebase = true
    
    
    //MARk: ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
            searchBar.delegate = self
            //startKeyboardObservers()
        
        // --- UI basics ---
        view.backgroundColor = .systemBackground
        
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.titleView = searchBar

        
        
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addGirlTapped)
        )
        
        let clearButton = UIBarButtonItem(
            title: "Clear",
            style: .plain,
            target: self,
            action: #selector(clearTapped)
        )
        clearButton.isEnabled = true
        navigationItem.rightBarButtonItems = [addButton, clearButton]
      
        // --- Search bar ---
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        
        // --- Table ---
        resultsTableView.dataSource = self
        resultsTableView.delegate = self
        resultsTableView.register(ProfileResultCell.self, forCellReuseIdentifier: ProfileResultCell.reuseID)
        resultsTableView.rowHeight = UITableView.automaticDimension
        resultsTableView.estimatedRowHeight = 88
        
        //resultsTableView.separatorStyle = .none
        //resultsTableView.backgroundColor = .systemGroupedBackground
        //resultsTableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 16, right: 0)
        
        
        // --- Layout ---
        setupUI()
        
        // --- Data load (Firebase vs Mock) ---
        if useFirebase {
            loadGirls()     // uses fetchGirlsFromFirebase -> allResults -> applyFilters()
        } else {
            loadMocks()     // sets girlsByKey + allResults -> applyFilters()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard let navBar = navigationController?.navigationBar else { return }
        
        let totalRightButtons = navigationItem.rightBarButtonItems?.count ?? 0
        
        // Rough width per UIBarButtonItem
        let estimatedButtonWidth: CGFloat = 44
        
        let totalRightWidth = CGFloat(totalRightButtons) * estimatedButtonWidth
        
        let horizontalPadding: CGFloat = 16
        
        let width = navBar.bounds.width
            - totalRightWidth
            - horizontalPadding * 2
        
        searchBar.frame = CGRect(x: 0, y: 0, width: max(160, width), height: 36)
    }
    
    /*
    private func setChipsCollapsed(_ collapsed: Bool, animated: Bool = true) {
        
        // 1️⃣ Update state
        areChipsCollapsed = collapsed
        
        // 2️⃣ Update height
        chipsHeightConstraint.constant = collapsed ? chipsCollapsedHeight : chipsExpandedHeight
        
        // 3️⃣ Update button title
        filtersToggleButton.setTitle(
            collapsed ? "Show Filters" : "Hide Filters",
            for: .normal
        )

        let changes = {
            self.view.layoutIfNeeded()
        }

        if animated {
            UIView.animate(withDuration: 0.22, delay: 0, options: [.curveEaseInOut]) {
                changes()
            }
        } else {
            changes()
        }
    }
     */
   

    private func setChipsCollapsed(_ collapsed: Bool, animated: Bool = true) {
        areChipsCollapsed = collapsed

        chipsHeightConstraint.constant = collapsed ? chipsCollapsedHeight : chipsExpandedHeight

        let newTitle = collapsed ? "Show Filters" : "Hide Filters"
        setFiltersToggleTitle(newTitle, animated: animated)

        let changes = { self.view.layoutIfNeeded() }

        if animated {
            UIView.animate(withDuration: 0.22, delay: 0, options: [.curveEaseInOut]) {
                changes()
            }
        } else {
            changes()
        }
    }
    
    private func startKeyboardObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func keyboardWillShow(_ note: Notification) {
        guard let info = note.userInfo else { return }

        let endFrame = (info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? .zero
        keyboardHeight = endFrame.height

        // Remember what filters height/state was BEFORE keyboard
        wasFiltersExpandedBeforeKeyboard = chipsHeightConstraint.constant > 0

        applyKeyboardLayout(using: info, keyboardShowing: true)
    }

    @objc private func keyboardWillHide(_ note: Notification) {
        guard let info = note.userInfo else { return }
        keyboardHeight = 0
        applyKeyboardLayout(using: info, keyboardShowing: false)
    }

    private func applyKeyboardLayout(using info: [AnyHashable: Any], keyboardShowing: Bool) {
        let duration = (info[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.25
        let curveRaw = (info[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.intValue ?? 7
        let options = UIView.AnimationOptions(rawValue: UInt(curveRaw << 16))

        // 1) Collapse / restore chips
        if keyboardShowing {
        //    chipsHeightConstraint.constant = filtersPeekHeight
        //    chipsCollectionView.alpha = 1 // keep visible as “peek”
        } else {
          //  chipsHeightConstraint.constant = wasFiltersExpandedBeforeKeyboard ? filtersExpandedHeight : 0
         //   chipsCollectionView.alpha = (chipsHeightConstraint.constant == 0) ? 0 : 1
        }

        // 2) Push results above keyboard by adjusting inset
        let bottomSafe = view.safeAreaInsets.bottom
        let bottomInset = keyboardShowing ? max(0, keyboardHeight - bottomSafe) : 0

        resultsTableView.contentInset.bottom = bottomInset
        resultsTableView.scrollIndicatorInsets.bottom = bottomInset

        // Optional: keep current scroll position feeling stable
        // resultsTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)

        UIView.animate(withDuration: duration,
                       delay: 0,
                       options: [options, .beginFromCurrentState],
                       animations: {
            self.view.layoutIfNeeded()
        })
    }

    private func loadMocks() {
        print("✅ USING MOCKS")
        let girls = MockGirls.all
        print("MockGirls.count =", girls.count)

        girlsByKey = Dictionary(uniqueKeysWithValues: girls.map { ($0.key, $0) })
        allResults = girls.map { makeResult(from: $0) }

        applyFilters()
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadGirls()
    }
    
    @objc private func addGirlTapped() {
        let vc = AddEditGirlViewController()
        vc.isEditingGirl = false
        vc.selectedShadchanGirl = ShadchanGirl(
            girlCell: "",
            girlLastName: "",
            girlFirstName: "",
            city: "",
            dobIntervalString: "",
            dateCreated: "",
            dateLastUpdate: Int(Date().timeIntervalSince1970),
            girlHeight: "",
            sendResumeEmail: "",
            sendResumeText: "",
            lifePlans: [],
            status: "available",
            datingHistory: "",
            shadchanNotesNew: "",
            notesImageURL: "",
            resumeImageURL: "",
            photoImageURL: "",
            key: ""
        )

        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func loadGirls() {
        fetchGirlsFromFirebase { [weak self] girls in
            guard let self else { return }

            self.girlsByKey = Dictionary(uniqueKeysWithValues: girls.map { ($0.key, $0) })
            self.allResults = girls.map { self.makeResult(from: $0) }

            // ✅ Preserve current search text + chip selections
            self.applyFilters()
        }
    }


    private func makeResult(from g: ShadchanGirl) -> ResultProfile {
        let ageDouble = g.calculateAgeFrom(dobString: g.dobIntervalString)
        let ageInt = ageDouble > 0 ? Int(ageDouble.rounded()) : nil

        let inches = HeightParser.parseInches(from: g.girlHeight)
        let heightText: String = inches.map { "\($0 / 12)'\($0 % 12)\"" } ?? ""

        let fullName = "\(g.girlFirstName) \(g.girlLastName)"
            .replacingOccurrences(of: "  ", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return ResultProfile(
            id: g.key,
            name: fullName,
            age: ageInt,
            heightInches: inches,
            heightText: heightText,
            city: g.city,
            lifePlans: g.lifePlans,
            photoURL: g.photoImageURL.isEmpty ? nil : g.photoImageURL,
            notes: g.shadchanNotesNew
        )
    }

 private func fetchGirlsFromFirebase(completion: @escaping ([ShadchanGirl]) -> Void) {
     guard let uid = Auth.auth().currentUser?.uid else {
         DispatchQueue.main.async { completion([]) }
         return
     }

     let ref = Database.database().reference()
         .child("PrivateGirlsList")
         .child(uid)

     ref.observeSingleEvent(of: .value) { snapshot in
         var girls: [ShadchanGirl] = []
         girls.reserveCapacity(Int(snapshot.childrenCount))

         for child in snapshot.children {
             guard let snap = child as? DataSnapshot else { continue }

             let g = ShadchanGirl(snapshot: snap)

             // Normalize + de-dupe legacy categories/lifePlans
             let normalized = LifePlanNormalizer.normalizeArray(g.categories)
             g.categories = Array(NSOrderedSet(array: normalized)) as? [String] ?? normalized

             girls.append(g)
         }

         // Stable, case-insensitive sorting
         girls.sort {
             let aFirst = $0.girlFirstName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
             let bFirst = $1.girlFirstName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
             if aFirst != bFirst { return aFirst < bFirst }

             let aLast = $0.girlLastName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
             let bLast = $1.girlLastName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
             return aLast < bLast
         }

         DispatchQueue.main.async {
             completion(girls)
         }
     }
 }

 
   

    
    private func makeMockProfile(from g: ShadchanGirl) -> MockProfile {
        let ageDouble = g.calculateAgeFrom(dobString: g.dobIntervalString)
        let ageInt = ageDouble > 0 ? Int(ageDouble.rounded()) : 0
        let inches = HeightParser.parseInches(from: g.girlHeight) ?? 0

        let plans = LifePlanNormalizer.normalizeArray(g.lifePlans)

        let fullName = "\(g.girlFirstName) \(g.girlLastName)"
            .replacingOccurrences(of: "  ", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return MockProfile(
            name: fullName,
            age: ageInt,
            heightInches: inches,
            lifePlans: plans
        )
    }

    private func updateClearButtonEnabled() {
        let hasTagSelections =
            !selectedHeightTags.isEmpty ||
            !selectedAgeTags.isEmpty ||
            !selectedLifePlans.isEmpty

        let hasSearchText = !currentSearchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

        let shouldEnableClear = hasTagSelections || hasSearchText

        // Assuming your rightBarButtonItems = [Add, Clear]
        navigationItem.rightBarButtonItems?.last?.isEnabled = true  //shouldEnableClear
    }

    // this function gets invoked from the clear button
    // but also it gets invoked from the emty results view
    @objc private func clearTapped() {
        // 1) Clear tag selections
        selectedHeightTags.removeAll()
        selectedAgeTags.removeAll()
        selectedLifePlans.removeAll()

        chipsCollectionView.indexPathsForSelectedItems?.forEach {
            chipsCollectionView.deselectItem(at: $0, animated: true)
        }

        // 2) Clear search text too (recommended)
        currentSearchText = ""
        searchBar.text = ""
        searchBar.resignFirstResponder()

        // 3) Reset data
        filteredResults = allResults

        // 4) Reload + update UI
        resultsTableView.reloadData()
        updateEmptyState()
        updateResultsHeader()
        updateNavTitleAnimated()
        updateClearButtonEnabled()
    }
    
    //MARK: Filter Summary Label
    // ex: Height: 2 Age: 2 Plans: 4
    private func filterSummaryText() -> String? {
        
        // start with an empty array to hold strings
        var parts: [String] = []

        // if the selected tags is NOT empty then get the
        // count of elements and build the string
        if !selectedHeightTags.isEmpty {
            parts.append("Height: \(selectedHeightTags.count)")
        }

        if !selectedAgeTags.isEmpty {
            parts.append("Age: \(selectedAgeTags.count)")
        }

        // if this is not empty then add the count to
        // the array of strings
        if !selectedLifePlans.isEmpty {
            parts.append("Plans: \(selectedLifePlans.count)")
        }

        // now that we have an array of string join the elements
        return parts.isEmpty ? nil : parts.joined(separator: " • ")
    }

    
    final class NavTitleView: UIView {
       
        private let titleLabel: UILabel = {
            let l = UILabel()
            l.font = .systemFont(ofSize: 17, weight: .semibold)
            l.textAlignment = .center
            return l
        }()

        private let subtitleLabel: UILabel = {
            let l = UILabel()
            l.font = .systemFont(ofSize: 13)
            l.textColor = .secondaryLabel
            l.textAlignment = .center
            return l
        }()

        override init(frame: CGRect) {
            super.init(frame: frame)

            let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
            stack.axis = .vertical
            stack.alignment = .center
            stack.spacing = 0

            addSubview(stack)
            stack.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                stack.leadingAnchor.constraint(equalTo: leadingAnchor),
                stack.trailingAnchor.constraint(equalTo: trailingAnchor),
                stack.topAnchor.constraint(equalTo: topAnchor),
                stack.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        func configure(title: String, subtitle: String?) {
            titleLabel.text = title
            subtitleLabel.text = subtitle
            subtitleLabel.isHidden = subtitle == nil
        }
    }


    // GOAL: Search by text OR tags, results update live as user interacts
    private func setupUI() {
        
        view.addSubview(chipsCollectionView)
        view.addSubview(resultsTableView)
        
        //searchBar.backgroundColor = .yellow
        //chipsCollectionView.backgroundColor = .orange

        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.heightAnchor.constraint(equalToConstant: 44).isActive = true
        searchBar.layer.cornerRadius = 10
        searchBar.clipsToBounds = true
        searchBar.searchTextField.font = .systemFont(ofSize: 17)
        searchBar.showsCancelButton = false
        chipsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        resultsTableView.translatesAutoresizingMaskIntoConstraints = false

        // ✅ Create the height constraint FIRST (outside activate)
        chipsHeightConstraint = chipsCollectionView.heightAnchor.constraint(equalToConstant: chipsExpandedHeight)
        
        chipsHeightConstraint.isActive = true


        NSLayoutConstraint.activate([
            // Chips (top of content now)
            chipsCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            chipsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chipsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            chipsHeightConstraint,

            // Results
            resultsTableView.topAnchor.constraint(equalTo: chipsCollectionView.bottomAnchor, constant: 8),
            resultsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            resultsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            resultsTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    @objc private func closeTapped() {
          dismiss(animated: true)
      }
    
    private var currentSearchText: String = ""
    private func updateResultsHeader() {
        let q = currentSearchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if q.isEmpty {
            resultsHeaderLabel.text = "Results (\(filteredResults.count))"
        } else {
            resultsHeaderLabel.text = "Results (\(filteredResults.count)) • “\(q)”"
        }
    }
}

extension GirlsFilterSearchVC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        currentSearchText = searchText
        applyFilters()   // reuse your existing pipeline
    }
    

        func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
            setChipsCollapsed(true)
        }

        func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
            // expand back only if search is empty (optional rule)
            if (searchBar.text ?? "").isEmpty {
                setChipsCollapsed(false)
            }
        }

        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchBar.resignFirstResponder()
        }

        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            searchBar.text = ""
            searchBar.resignFirstResponder()
            setChipsCollapsed(false)
            applyFilters()
        }
    
   
}
// MARK: - UITableViewDataSource / Delegate

extension GirlsFilterSearchVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        resultsHeaderView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        34
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
         return   filteredResults.count
    }
      
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: ProfileResultCell.reuseID,
                                                 for: indexPath) as! ProfileResultCell
        

       
        //let r = filteredResults[indexPath.row]
        //let snippet = noteSnippetById[r.id]   // your cache from applyFilters()
        //cell.configure(result: r, row: indexPath.row, snippet: snippet)
        
        let r = filteredResults[indexPath.row]
        cell.configure(
            result: r,
            row: indexPath.row,
            title: titleAttrById[r.id],
            snippet: noteSnippetById[r.id]
        )

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let r = filteredResults[indexPath.row]
        guard let girl = girlsByKey[r.id] else { return }

        let vc = AddEditGirlViewController()
        vc.isEditingGirl = true
        vc.selectedShadchanGirl = girl
        navigationController?.pushViewController(vc, animated: true)
    }
}



// MARK: - UICollectionViewDataSource / DelegateFlowLayout

extension GirlsFilterSearchVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
   
   func numberOfSections(in collectionView: UICollectionView) -> Int {
            TagCategory.allCases.count
        }
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
           let cat = TagCategory(rawValue: section)!
           return tagsByCategory[cat]?.count ?? 0
       }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // use the custom chip cell
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ChipCell.reuseID,
            for: indexPath
        ) as! ChipCell

        // get the tagCategory for current section
        let cat = TagCategory(rawValue: indexPath.section)!
        
        //index into the current section i.e. tag categories
        // index into the current tag for current section
        let tag = tagsByCategory[cat]![indexPath.item]

        // you already track selection sets:
        let isSelected: Bool
        
        // switch statement based on what section of tag category
        switch cat {
            
        case .height:
            isSelected = selectedHeightTags.contains(where: { $0.title == tag.title })
        case .age:
            isSelected = selectedAgeTags.contains(where: { $0.title == tag.title })
        case .lifePlans:
            isSelected = selectedLifePlans.contains(where: { $0.title == tag.title })
        }

        // this will fill in the text for the tag like 5"2'
        // the accent color
        // and it uses the is selected bool to decide
        cell.configure(text: tag.title, accentColor: cat.accentColor, selected: isSelected)

        return cell
    }
    
    /*
     func collectionView(_ collectionView: UICollectionView,
                         layout collectionViewLayout: UICollectionViewLayout,
                         sizeForItemAt indexPath: IndexPath) -> CGSize {

         let cat = TagCategory(rawValue: indexPath.section)!
         let tag = tagsByCategory[cat]![indexPath.item]

         let font = UIFont.systemFont(ofSize: 15, weight: .medium)
         let textWidth = (tag.title as NSString).size(
             withAttributes: [NSAttributedString.Key.font: font]
         ).width

         let nonTextWidth: CGFloat = 48   // dot + padding + breathing room

         let insetsLR: CGFloat
         if let flow = collectionViewLayout as? UICollectionViewFlowLayout {
             insetsLR = flow.sectionInset.left + flow.sectionInset.right
         } else {
             insetsLR = 32
         }

         let maxWidth = collectionView.bounds.width - insetsLR
         let finalWidth = min(textWidth + nonTextWidth, maxWidth)

         // 👇 KEY PART
         let height: CGFloat = (cat == .lifePlans) ? 44 : 32

         return CGSize(width: finalWidth, height: height)
     }
    */
    // ✅ Fixed 3 chips per row across all categories (including lifePlans)
      func collectionView(_ collectionView: UICollectionView,
                          layout collectionViewLayout: UICollectionViewLayout,
                          sizeForItemAt indexPath: IndexPath) -> CGSize {

          guard let flow = collectionViewLayout as? UICollectionViewFlowLayout else {
              return CGSize(width: 100, height: 32)
          }

          let columns: CGFloat = 3
          let itemHeight: CGFloat = 32

          let totalSpacing =
              flow.sectionInset.left +
              flow.sectionInset.right +
              (columns - 1) * flow.minimumInteritemSpacing

          let availableWidth = collectionView.bounds.width - totalSpacing
          let itemWidth = floor(availableWidth / columns)

          return CGSize(width: itemWidth, height: itemHeight)
      }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: ChipHeaderView.reuseID,
            for: indexPath
        ) as! ChipHeaderView

        let cat = TagCategory(rawValue: indexPath.section)!
        header.configure(title: cat.title)
        return header
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: 80, height: 32)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cat = TagCategory(rawValue: indexPath.section)!
        let tag = tagsByCategory[cat]![indexPath.item]
        let title = tag.title

        switch cat {
        case .height:
            if let ht = heightTag(from: title) { selectedHeightTags.insert(ht) }
        case .age:
            if let at = ageTag(from: title) { selectedAgeTags.insert(at) }
        case .lifePlans:
            if let lt = lifePlanTag(from: title) { selectedLifePlans.insert(lt) }
        }

        applyFilters()
        updateClearButtonEnabled()
    }

 func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cat = TagCategory(rawValue: indexPath.section)!
        let tag = tagsByCategory[cat]![indexPath.item]
        let title = tag.title

        switch cat {
        case .height:
            if let ht = heightTag(from: title) { selectedHeightTags.remove(ht) }
        case .age:
            if let at = ageTag(from: title) { selectedAgeTags.remove(at) }
        case .lifePlans:
            if let lt = lifePlanTag(from: title) { selectedLifePlans.remove(lt) }
        }

        applyFilters()
        updateClearButtonEnabled()

    }
    
    private func updateEmptyState() {
        if filteredResults.isEmpty {
            resultsTableView.backgroundView = emptyStateView
            resultsTableView.separatorStyle = .none
            
        } else {
            resultsTableView.backgroundView = nil
            resultsTableView.separatorStyle = .singleLine
           
        }
    }
    
    

    private func makeNotesSnippet(notes: String, query: String, window: Int = 44) -> NSAttributedString? {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return nil }

        let queryTokens = q.lowercased()
            .split { !$0.isLetter && !$0.isNumber }
            .map(String.init)
        guard !queryTokens.isEmpty else { return nil }

        let lowerNotes = notes.lowercased()
        var best: Range<String.Index>?

        for tok in queryTokens where !tok.isEmpty {
            if let r = lowerNotes.range(of: tok) {
                if best == nil || r.lowerBound < best!.lowerBound {
                    best = r
                }
            }
        }
        guard let match = best else { return nil }

        let start = lowerNotes.index(match.lowerBound, offsetBy: -window, limitedBy: lowerNotes.startIndex) ?? lowerNotes.startIndex
        let end   = lowerNotes.index(match.upperBound, offsetBy: window, limitedBy: lowerNotes.endIndex) ?? lowerNotes.endIndex

        let sDist = lowerNotes.distance(from: lowerNotes.startIndex, to: start)
        let eDist = lowerNotes.distance(from: lowerNotes.startIndex, to: end)

        let os = notes.index(notes.startIndex, offsetBy: sDist, limitedBy: notes.endIndex) ?? notes.startIndex
        let oe = notes.index(notes.startIndex, offsetBy: eDist, limitedBy: notes.endIndex) ?? notes.endIndex

        var snippet = String(notes[os..<oe]).trimmingCharacters(in: .whitespacesAndNewlines)
        if os > notes.startIndex { snippet = "… " + snippet }
        if oe < notes.endIndex { snippet += " …" }

        // ---- Styling ----
        let baseFont = UIFont.systemFont(ofSize: 13)
        let boldFont = UIFont.systemFont(ofSize: 13, weight: .semibold)

        let attr = NSMutableAttributedString()

        // Prefix label
        let prefix = NSAttributedString(
            string: "Notes: ",
            attributes: [
                .font: UIFont.systemFont(ofSize: 12, weight: .medium),
                .foregroundColor: UIColor.tertiaryLabel
            ]
        )
        attr.append(prefix)

        // Snippet body
        let bodyStartIndex = attr.length

        let body = NSMutableAttributedString(string: snippet, attributes: [
            .font: baseFont,
            .foregroundColor: UIColor.secondaryLabel
        ])

        attr.append(body)

        // Highlight matches in snippet body
        let snippetLower = snippet.lowercased()
        for tok in queryTokens {
            var range = snippetLower.startIndex..<snippetLower.endIndex
            while let r = snippetLower.range(of: tok, range: range) {
                let nsRange = NSRange(r, in: snippetLower)
                let adjustedRange = NSRange(location: bodyStartIndex + nsRange.location,
                                            length: nsRange.length)

                attr.addAttributes([
                    .font: boldFont,
                    .foregroundColor: UIColor.label
                ], range: adjustedRange)

                range = r.upperBound..<snippetLower.endIndex
            }
        }

        return attr
    }


    private func applyFilters() {
        let searchText = currentSearchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let q = searchText.lowercased()

        titleAttrById.removeAll(keepingCapacity: true)
        noteSnippetById.removeAll(keepingCapacity: true)

        let baseTitleFont = UIFont.systemFont(ofSize: 17, weight: .regular)
        let highlightTitleFont = UIFont.systemFont(ofSize: 17, weight: .semibold)

        let baseTitleColor = UIColor.secondaryLabel
        let highlightTitleColor = UIColor.label

        let newFiltered = allResults.filter { r in

            // --- Height chips ---
            if !selectedHeightTags.isEmpty {
                guard let inches = r.heightInches else { return false }
                let matches = selectedHeightTags.contains { $0.inchRange.contains(inches) }
                if !matches { return false }
            }

            // --- Age chips ---
            if !selectedAgeTags.isEmpty {
                guard let age = r.age else { return false }
                let matches = selectedAgeTags.contains { $0.ageRange.contains(age) }
                if !matches { return false }
            }

            // --- Life plan chips ---
            if !selectedLifePlans.isEmpty {
                let selectedTitles = Set(selectedLifePlans.map { $0.title })
                let profileTitles = Set(r.lifePlans)
                if selectedTitles.isDisjoint(with: profileTitles) { return false }
            }

            // --- Search (includes notes) ---
            if !q.isEmpty {
                let searchable =
                    r.name + " " +
                    r.city + " " +
                    r.lifePlans.joined(separator: " ") + " " +
                    r.notes

                let tokens = searchable
                    .lowercased()
                    .split { !$0.isLetter && !$0.isNumber }
                    .map(String.init)

                // keep your existing behavior: the whole query must match start of SOME word
                let matches = tokens.contains { $0.hasPrefix(q) }
                if !matches { return false }

                // Build top row text (Name • Age • Height • City)
                let ageText = r.age.map(String.init) ?? ""
                let heightText = r.heightText
                let pieces = [
                    r.name,
                    ageText.isEmpty ? nil : ageText,
                    heightText.isEmpty ? nil : heightText,
                    r.city.isEmpty ? nil : r.city
                ].compactMap { $0 }

                let titleText = pieces.joined(separator: " • ")
                titleAttrById[r.id] = highlightMatches(
                    in: titleText,
                    query: q,
                    baseFont: baseTitleFont,
                    highlightFont: highlightTitleFont,
                    baseColor: baseTitleColor,
                    highlightColor: highlightTitleColor
                )

                // Notes snippet (only if match occurs in notes)
                if let snippet = makeNotesSnippet(notes: r.notes, query: q) {
                    noteSnippetById[r.id] = snippet
                }
            } else {
                // No search: still cache a softened title (optional)
                let ageText = r.age.map(String.init) ?? ""
                let heightText = r.heightText
                let pieces = [
                    r.name,
                    ageText.isEmpty ? nil : ageText,
                    heightText.isEmpty ? nil : heightText,
                    r.city.isEmpty ? nil : r.city
                ].compactMap { $0 }

                let titleText = pieces.joined(separator: " • ")
                titleAttrById[r.id] = NSAttributedString(string: titleText, attributes: [
                    .font: baseTitleFont,
                    .foregroundColor: UIColor.label  // up to you; can use secondaryLabel too
                ])
            }

            return true
        }

        filteredResults = newFiltered
        resultsTableView.reloadData()
        updateEmptyState()
        updateResultsHeader()
        updateNavTitleAnimated()
        updateClearButtonEnabled()
    }

   
    private func reselectPreviouslySelectedChips() {
         
        // iterate over all the chips sections by iterating over
        // TagCategory.allCasess.count which is 3
        for section in 0..<TagCategory.allCases.count {
            
            // for each section init a TagCategory
            let cat = TagCategory(rawValue: section)!
            
            // pass in the TagCategory to the tagsByCategory function
            // and get all the tags for that section
            guard let tags = tagsByCategory[cat] else { continue }

            // iterate over the tags
            for (item, tag) in tags.enumerated() where
             
            // get the tag.id and see if it exists in the
            // selectedTagIDs
            // if it does exist..
            selectedTagIDs.contains(tag.id) {
                  
                // create an indexPath for that item and section
                let indexPath = IndexPath(item: item, section: section)
                // tell the chipsCollectionView to select that item
                // at that indexPath
                chipsCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
            }
        }
    }
}
// MARK: - ChipCell


 final class ChipCell: UICollectionViewCell {
     static let reuseID = "ChipCell"

     private let dotView: UIView = {
         let v = UIView()
         v.translatesAutoresizingMaskIntoConstraints = false
         v.layer.cornerRadius = 4
         v.layer.masksToBounds = true
         return v
     }()

     private let label: UILabel = {
         let l = UILabel()
         l.translatesAutoresizingMaskIntoConstraints = false
         l.font = .systemFont(ofSize: 15, weight: .medium)
         l.textAlignment = .left
         l.textColor = .label

         // ✅ one line + shrink (no truncation)
         l.numberOfLines = 1
         l.lineBreakMode = .byClipping
         l.adjustsFontSizeToFitWidth = true
         l.minimumScaleFactor = 0.78

         return l
     }()

     override init(frame: CGRect) {
         super.init(frame: frame)

         contentView.backgroundColor = .secondarySystemBackground
         contentView.layer.cornerRadius = 16
         contentView.layer.masksToBounds = true

         // Selected background view (UIKit may show it automatically on selection)
         let selectedBG = UIView()
         selectedBG.backgroundColor = .tertiarySystemFill
         selectedBG.layer.cornerRadius = 16
         selectedBG.layer.masksToBounds = true
         selectedBackgroundView = selectedBG

         contentView.addSubview(dotView)
         contentView.addSubview(label)

         NSLayoutConstraint.activate([
             dotView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
             dotView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
             dotView.widthAnchor.constraint(equalToConstant: 8),
             dotView.heightAnchor.constraint(equalToConstant: 8),

             label.leadingAnchor.constraint(equalTo: dotView.trailingAnchor, constant: 8),
             label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
             label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
             label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
         ])

         // Helps the label compress horizontally (so shrink-to-fit actually happens)
         label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
         label.setContentHuggingPriority(.defaultLow, for: .horizontal)
     }

     required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

     override func prepareForReuse() {
         super.prepareForReuse()
         label.text = nil
         dotView.backgroundColor = nil
         contentView.layer.borderWidth = 0
         contentView.layer.borderColor = nil
         dotView.transform = .identity
     }

     func configure(text: String, accentColor: UIColor, selected: Bool) {
         label.text = text
         dotView.backgroundColor = accentColor
         applySelectionStyle(selected: selected)
     }

     private func applySelectionStyle(selected: Bool) {
         if selected {
             contentView.layer.borderWidth = 2
             contentView.layer.borderColor = dotView.backgroundColor?.cgColor
             contentView.backgroundColor = .tertiarySystemFill
         } else {
             contentView.layer.borderWidth = 0
             contentView.layer.borderColor = nil
             contentView.backgroundColor = .secondarySystemBackground
         }
         dotView.transform = selected ? CGAffineTransform(scaleX: 1.2, y: 1.2) : .identity
     }

     override var isSelected: Bool {
         didSet { applySelectionStyle(selected: isSelected) }
     }
 }
 

// the chips collectionView has three sections
// At the top of each section of the tag chips you see
// Age - Height - Life Plans
final class ChipHeaderView: UICollectionReusableView {
    static let reuseID = "ChipHeaderView"

    private let label: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14, weight: .semibold)
        l.textColor = .secondaryLabel
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(title: String) {
        label.text = title }
}

final class EmptyStateView: UIView {

    // this is a call back closure
    // it gets triggered when the
    // clear button is tapped
    // it gets defined when we
    // set up the empty state view
    var onClearTapped: (() -> Void)?

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 17, weight: .semibold)
        l.textAlignment = .center
        l.text = "No results"
        return l
    }()

    private let messageLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14)
        l.textColor = .secondaryLabel
        l.textAlignment = .center
        l.numberOfLines = 0
        l.text = "Try removing some filters or clearing them to see more profiles."
        return l
    }()

    private let clearButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Clear Filters"
        config.cornerStyle = .medium
        return UIButton(configuration: config)
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .clear

        let stack = UIStackView(arrangedSubviews: [titleLabel, messageLabel, clearButton])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 12

        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -24)
        ])

        clearButton.addTarget(self, action: #selector(clearPressed), for: .touchUpInside)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    @objc private func clearPressed() {
        onClearTapped?()
    }
}



final class ImageLoader {
    static let shared = ImageLoader()
    private let cache = NSCache<NSString, UIImage>()
    private init() {}

    @discardableResult
    func load(_ urlString: String?, completion: @escaping (UIImage?) -> Void) -> URLSessionDataTask? {
        guard
            let urlString,
            let url = URL(string: urlString)
        else {
            completion(nil)
            return nil
        }

        if let cached = cache.object(forKey: urlString as NSString) {
            completion(cached)
            return nil
        }

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self, let data, let image = UIImage(data: data) else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            self.cache.setObject(image, forKey: urlString as NSString)
            DispatchQueue.main.async { completion(image) }
        }
        task.resume()
        return task
    }
}

final class ResultChipView: UIView {
    private let dot = UIView()
    private let label = UILabel()

    init(text: String, accent: UIColor) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 14
        layer.masksToBounds = true

        dot.translatesAutoresizingMaskIntoConstraints = false
        dot.backgroundColor = accent
        dot.layer.cornerRadius = 3

        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail

        addSubview(dot)
        addSubview(label)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 28),

            dot.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            dot.centerYAnchor.constraint(equalTo: centerYAnchor),
            dot.widthAnchor.constraint(equalToConstant: 6),
            dot.heightAnchor.constraint(equalToConstant: 6),

            label.leadingAnchor.constraint(equalTo: dot.trailingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

final class ProfileResultCell: UITableViewCell {
    static let reuseID = "ProfileResultCell"

    private let photoView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .tertiarySystemFill
        iv.layer.cornerRadius = 10
        return iv
    }()
    private let snippetLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = .systemFont(ofSize: 13)
        l.textColor = .secondaryLabel
        l.numberOfLines = 2
        l.lineBreakMode = .byTruncatingTail
        return l
    }()


    private let titleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = .systemFont(ofSize: 17, weight: .semibold)
        l.numberOfLines = 1
        l.lineBreakMode = .byTruncatingTail
        return l
    }()

    private let chipsStack: UIStackView = {
        let s = UIStackView()
        s.translatesAutoresizingMaskIntoConstraints = false
        s.axis = .horizontal
        s.alignment = .center
        s.spacing = 8
        return s
    }()

    private var imageTask: URLSessionDataTask?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none

        
       

        let vStack = UIStackView(arrangedSubviews: [titleLabel, chipsStack,snippetLabel])
        vStack.translatesAutoresizingMaskIntoConstraints = false
        vStack.axis = .vertical
        vStack.spacing = 8
        vStack.alignment = .leading
        
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        snippetLabel.setContentCompressionResistancePriority(.required, for: .vertical)

        contentView.addSubview(photoView)
        contentView.addSubview(vStack)
        snippetLabel.isHidden = true

        
        contentView.layer.cornerRadius = 14
        contentView.layer.masksToBounds = true
        //contentView.backgroundColor = .secondarySystemBackground

        

        NSLayoutConstraint.activate([
            photoView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            photoView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            photoView.widthAnchor.constraint(equalToConstant: 52),
            photoView.heightAnchor.constraint(equalToConstant: 52),

            vStack.leadingAnchor.constraint(equalTo: photoView.trailingAnchor, constant: 12),
            vStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            // ✅ NEW: let content drive height
            vStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            vStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),

            // ✅ Keep photo from stretching cell too short
            contentView.bottomAnchor.constraint(greaterThanOrEqualTo: photoView.bottomAnchor, constant: 10),
        ])

    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageTask?.cancel()
        imageTask = nil
        photoView.image = nil
        snippetLabel.text = nil
        snippetLabel.attributedText = nil
        snippetLabel.isHidden = true

        
        chipsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
    
    
    func configure(
        result: ResultProfile,
        row: Int,
        title: NSAttributedString?,
        snippet: NSAttributedString?
    ) {
        // Clear chips
        chipsStack.arrangedSubviews.forEach { v in
            chipsStack.removeArrangedSubview(v)
            v.removeFromSuperview()
        }

        // ---- Title (soft base + highlighted matches, provided by VC) ----
        if let title {
            titleLabel.attributedText = title
        } else {
            // Fallback (should rarely happen)
            let ageText = result.age.map(String.init) ?? ""
            let heightText = result.heightText

            let pieces = [
                result.name,
                ageText.isEmpty ? nil : ageText,
                heightText.isEmpty ? nil : heightText,
                result.city.isEmpty ? nil : result.city
            ].compactMap { $0 }

            titleLabel.text = pieces.joined(separator: " • ")
            titleLabel.textColor = .secondaryLabel
            titleLabel.font = .systemFont(ofSize: 17, weight: .regular)
        }

        // ---- Life plan chips ----
        let maxChips = 3
        let plans = result.lifePlans
        let shown = Array(plans.prefix(maxChips))
        let remaining = plans.count - shown.count

        for plan in shown {
            chipsStack.addArrangedSubview(
                ResultChipView(text: plan, accent: TagCategory.lifePlans.accentColor)
            )
        }

        if remaining > 0 {
            chipsStack.addArrangedSubview(
                ResultChipView(text: "+\(remaining) more", accent: TagCategory.lifePlans.accentColor)
            )
        }

        // ---- Notes snippet (Xcode-style) ----
        if let snippet {
            snippetLabel.attributedText = snippet
            snippetLabel.isHidden = false
        } else {
            snippetLabel.attributedText = nil
            snippetLabel.isHidden = true
        }

        // ---- Photo ----
        photoView.image = DefaultImageCycler.image(forRow: row)
            ?? UIImage(systemName: "person.crop.square")

        photoView.layer.borderWidth = 2
        photoView.layer.borderColor = TagCategory.age.accentColor.cgColor
    }

    /*
    func configure(result: ResultProfile, row: Int, snippet: NSAttributedString?) {
    
        chipsStack.arrangedSubviews.forEach { v in
             chipsStack.removeArrangedSubview(v)
             v.removeFromSuperview()
         }

         let ageText = result.age.map(String.init) ?? ""
         let heightText = result.heightText

         let pieces = [result.name,
                       ageText.isEmpty ? nil : ageText,
                       heightText.isEmpty ? nil : heightText]
             .compactMap { $0 }

         titleLabel.text = pieces.joined(separator: " • ")

         let maxChips = 3
         let plans = result.lifePlans
         let shown = Array(plans.prefix(maxChips))
         let remaining = plans.count - shown.count

         for plan in shown {
             chipsStack.addArrangedSubview(
                 ResultChipView(text: plan, accent: TagCategory.lifePlans.accentColor)
             )
         }
         if remaining > 0 {
             chipsStack.addArrangedSubview(
                 ResultChipView(text: "+\(remaining) more", accent: TagCategory.lifePlans.accentColor)
             )
         }
        if let snippet {
            snippetLabel.attributedText = snippet
            snippetLabel.isHidden = false
        } else {
            snippetLabel.attributedText = nil
            snippetLabel.isHidden = true
        }

        
        
         //photoView.image = UIImage(named: "defaultProfile")
        photoView.image = DefaultImageCycler.image(forRow: row)
                ?? UIImage(systemName: "person.crop.square")
        
        photoView.layer.borderWidth = 2
        photoView.layer.borderColor = UIColor.systemBlue.cgColor
        photoView.layer.borderColor = TagCategory.age.accentColor.cgColor
        }
     */
}
 

enum DefaultImageCycler {
    static let count = 12

    static func imageName(forRow row: Int) -> String {
        let index = (row % count) + 1
        return "defaultProfile\(index)"
    }

    static func image(forRow row: Int) -> UIImage? {
        UIImage(named: imageName(forRow: row))
    }
}



//MARK Result Profile
struct MockProfile {
    let id: UUID = UUID()
    let name: String
    let age: Int
    let heightInches: Int
    let lifePlans: [String]
}
struct Profile: Identifiable {
    let id: String
    let name: String
    let age: Int?
    let heightInches: Int?
    let lifePlans: [String]
    let photoURL: String?   // https://...
}
struct ResultProfile: Identifiable, Hashable {
    let id: String
    let name: String
    let age: Int?
    let heightInches: Int?
    let heightText: String
    let city: String
    let lifePlans: [String]
    let photoURL: String?
    let notes: String
    
}

enum HeightParser {
    static func parseInches(from text: String) -> Int? {
        // expects formats like: 5'3, 5'3", 5’3, 5 ft 3, etc. (basic handling)
        let cleaned = text
            .replacingOccurrences(of: "’", with: "'")
            .replacingOccurrences(of: "\"", with: "")
            .lowercased()

        // Try simple "5'10" format
        let parts = cleaned.split(separator: "'").map { String($0).trimmingCharacters(in: .whitespaces) }
        guard parts.count >= 2, let feet = Int(parts[0]) else { return nil }

        // Pull leading digits from inches part
        let inchDigits = parts[1].prefix { $0.isNumber }
        guard let inches = Int(inchDigits) else { return feet * 12 } // allow "5'" edge case

        return feet * 12 + inches
    }
}
private func highlightMatches(
    in text: String,
    query: String,
    baseFont: UIFont,
    highlightFont: UIFont,
    baseColor: UIColor,
    highlightColor: UIColor
) -> NSAttributedString {

    let attr = NSMutableAttributedString(string: text, attributes: [
        .font: baseFont,
        .foregroundColor: baseColor
    ])

    let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !q.isEmpty else { return attr }

    let tokens = q.lowercased()
        .split { !$0.isLetter && !$0.isNumber }
        .map(String.init)
        .filter { !$0.isEmpty }

    guard !tokens.isEmpty else { return attr }

    let lower = text.lowercased()

    for tok in tokens {
        var searchRange = lower.startIndex..<lower.endIndex
        while let r = lower.range(of: tok, range: searchRange) {
            let ns = NSRange(r, in: lower)
            attr.addAttributes([
                .font: highlightFont,
                .foregroundColor: highlightColor
            ], range: ns)
            searchRange = r.upperBound..<lower.endIndex
        }
    }

    return attr
}






