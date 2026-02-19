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
    private let chipsExpandedHeight: CGFloat = 220
    private let chipsCollapsedHeight: CGFloat = 44   // or 0 if you want fully hidden

    
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
    
    @objc private func toggleFiltersTapped() {
        chipsCollapsed.toggle()

        chipsHeightConstraint.constant = chipsCollapsed ? chipsCollapsedHeight : chipsExpandedHeight
        filtersToggleButton.setTitle(chipsCollapsed ? "Show Filters" : "Hide Filters", for: .normal)

        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseInOut]) {
            self.view.layoutIfNeeded()
        }
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

  

/*
    private func makeMockProfiles() -> [MockProfile] {
        let names = ["Rivka", "Sara", "Leah", "Miriam", "Tamar", "Chana", "Esther", "Yael", "Aviva", "Dina"]
        
        let lifePlanTitles = LifePlanTag.allCases.map { $0.title }

        func randomLifePlans() -> [String] {
            let count = Int.random(in: 1...3)
            return Array(lifePlanTitles.shuffled().prefix(count))
        }

        // Heights roughly 4'10" (58) to 5'10" (70)
        func randomHeightInches() -> Int { Int.random(in: 58...70) }

        // Ages roughly 19 to 35
        func randomAge() -> Int { Int.random(in: 19...35) }

        return (1...80).map { i in
            MockProfile(
                name: "\(names.randomElement()!) \(i)",
                age: randomAge(),
                heightInches: randomHeightInches(),
                lifePlans: randomLifePlans()
            )
        }
    }

    */
    private var selectedTagIDs = Set<UUID>()
    
    struct TagItem: Hashable {
        let id = UUID()
        let category: TagCategory
        let title: String
    }
    

    // MARK: - UI
    private let searchBar: UISearchBar = {
         let sb = UISearchBar()
         sb.placeholder = "Search"
         sb.autocapitalizationType = .none
         sb.autocorrectionType = .no
         return sb
     }()
    
    private lazy var chipsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 4, left: 16, bottom: 12, right: 16)
        layout.headerReferenceSize = CGSize(width: 0, height: 28)

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.dataSource = self
        cv.delegate = self
        cv.allowsSelection = true
        cv.allowsMultipleSelection = true


        cv.register(ChipCell.self, forCellWithReuseIdentifier: ChipCell.reuseID)
        cv.register(ChipHeaderView.self,
                    forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                    withReuseIdentifier: ChipHeaderView.reuseID)

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

        // --- UI basics ---
        view.backgroundColor = .systemBackground

        navTitleView.configure(title: "Search", subtitle: nil)
        navigationItem.titleView = navTitleView
        
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
        clearButton.isEnabled = false
        
        let extractButton = UIBarButtonItem(
            title: "Extract",
            style: .plain,
            target: self,
            action: #selector(extractTapped)
        )
        
        extractButton.isEnabled = true
    

        navigationItem.rightBarButtonItems = [addButton, clearButton]

        // --- Search bar ---
        searchBar.delegate = self
        searchBar.showsCancelButton = true

        // --- Table ---
        resultsTableView.dataSource = self
        resultsTableView.delegate = self
        resultsTableView.register(ProfileResultCell.self, forCellReuseIdentifier: ProfileResultCell.reuseID)
        resultsTableView.rowHeight = UITableView.automaticDimension
        resultsTableView.estimatedRowHeight = 76
        
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
    
    @objc private func extractTapped() {
        //let vc = OCRReviewViewController()
        let vc = ResumeScanStartViewController()
        navigationController?.pushViewController(vc, animated: true)
        
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
        navigationItem.rightBarButtonItems?.last?.isEnabled = shouldEnableClear
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
        view.addSubview(searchBar)
        view.addSubview(chipsCollectionView)
        view.addSubview(resultsTableView)

        searchBar.translatesAutoresizingMaskIntoConstraints = false
        chipsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        resultsTableView.translatesAutoresizingMaskIntoConstraints = false

        // ✅ Create the height constraint FIRST (outside activate)
        chipsHeightConstraint = chipsCollectionView.heightAnchor.constraint(equalToConstant: chipsExpandedHeight)

        NSLayoutConstraint.activate([
            // Search bar
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            // Chips
            chipsCollectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            chipsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chipsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            chipsHeightConstraint, // ✅ activate the stored constraint here

            // Results
            resultsTableView.topAnchor.constraint(equalTo: chipsCollectionView.bottomAnchor, constant: 8),
            resultsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            resultsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            resultsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
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
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
         searchBar.resignFirstResponder()
     }

     func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
         currentSearchText = ""
         searchBar.text = ""
         searchBar.resignFirstResponder()
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
        //cell.backgroundColor = .clear
        //cell.contentView.backgroundColor = .clear

       
        let r = filteredResults[indexPath.row]
        cell.configure(result: r, row: indexPath.row)


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
    
     
    
     private func applyFilters() {
         let searchText = currentSearchText.trimmingCharacters(in: .whitespacesAndNewlines)
         let q = searchText.lowercased()

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

             // --- Word-start search ---
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

                 let matches = tokens.contains { $0.hasPrefix(q) }
                 if !matches { return false }
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
        l.numberOfLines = 2
        l.lineBreakMode = .byWordWrapping

        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true

        // Selected background view (UIKit will show this automatically when selected)
        let selectedBG = UIView()
        selectedBG.backgroundColor = .tertiarySystemFill
        selectedBG.layer.cornerRadius = 16
        selectedBG.layer.masksToBounds = true
        selectedBackgroundView = selectedBG

        contentView.addSubview(dotView)
        contentView.addSubview(label)

        NSLayoutConstraint.activate([
            // Dot
            dotView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            dotView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            dotView.widthAnchor.constraint(equalToConstant: 8),
            dotView.heightAnchor.constraint(equalToConstant: 8),

    
            // Label
            label.leadingAnchor.constraint(equalTo: dotView.trailingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)

        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
        dotView.backgroundColor = nil
    }
    
    // for each chip cell we need to set the text
    // the accent color of the dotView
    // the border color and thickness of the chipView
    func configure(text: String, accentColor: UIColor, selected: Bool) {
        label.text = text
        dotView.backgroundColor = accentColor
        applySelectionStyle(selected: selected)
    }

    private func applySelectionStyle(selected: Bool) {
        if selected {
            contentView.layer.borderWidth = 2
            contentView.layer.borderColor = dotView.backgroundColor?.cgColor
            contentView.backgroundColor = UIColor.tertiarySystemFill
        } else {
            contentView.layer.borderWidth = 0
            contentView.layer.borderColor = nil
            contentView.backgroundColor = UIColor.secondarySystemBackground
        }
        dotView.transform = selected ? CGAffineTransform(scaleX: 1.2, y: 1.2) : .identity

    }
    // this tells us if a collection view is selected
    // based on that bool we set the border and dot view color and size
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
/*
final class ProfileResultCell: UITableViewCell {
    static let reuseID = "ProfileResultCell"

    private let cardView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .secondarySystemBackground
        v.layer.cornerRadius = 16
        v.layer.masksToBounds = true
        return v
    }()

    private let photoView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .tertiarySystemFill
        iv.layer.cornerRadius = 10
        return iv
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = .systemFont(ofSize: 14, weight: .semibold)
        l.numberOfLines = 1
        l.lineBreakMode = .byTruncatingTail
        return l
    }()

    private let chipsStack: UIStackView = {
        let s = UIStackView()
        s.translatesAutoresizingMaskIntoConstraints = false
        s.axis = .horizontal
        s.alignment = .center
        s.spacing = 4
        return s
    }()

    private var imageTask: URLSessionDataTask?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        titleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        chipsStack.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        contentView.addSubview(cardView)

        let vStack = UIStackView(arrangedSubviews: [titleLabel, chipsStack])
        vStack.translatesAutoresizingMaskIntoConstraints = false
        vStack.axis = .vertical
        vStack.spacing = 8
        vStack.alignment = .leading

        cardView.addSubview(photoView)
        cardView.addSubview(vStack)

        // Card insets (THIS is what creates the “card spacing”)
        NSLayoutConstraint.activate([
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 6),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -6),
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),

            photoView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 6),
            photoView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            photoView.widthAnchor.constraint(equalToConstant: 52),
            photoView.heightAnchor.constraint(equalToConstant: 52),

            vStack.leadingAnchor.constraint(equalTo: photoView.trailingAnchor, constant:4),
            vStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -4),
            vStack.centerYAnchor.constraint(equalTo: photoView.centerYAnchor),

            cardView.bottomAnchor.constraint(greaterThanOrEqualTo: photoView.bottomAnchor, constant: 12),
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageTask?.cancel()
        imageTask = nil
        photoView.image = nil
        chipsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }

    func configure(result: ResultProfile, row: Int) {
        // Clear old chips
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

        // result chips (same as you had)
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

        // Placeholder cycling (design mode)
        photoView.image = DefaultImageCycler.image(forRow: row)
            ?? UIImage(systemName: "person.crop.square")
    }
}
*/

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

        let vStack = UIStackView(arrangedSubviews: [titleLabel, chipsStack])
        vStack.translatesAutoresizingMaskIntoConstraints = false
        vStack.axis = .vertical
        vStack.spacing = 8
        vStack.alignment = .leading

        contentView.addSubview(photoView)
        contentView.addSubview(vStack)
        
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
            vStack.centerYAnchor.constraint(equalTo: photoView.centerYAnchor),

            contentView.bottomAnchor.constraint(greaterThanOrEqualTo: photoView.bottomAnchor, constant: 10),
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageTask?.cancel()
        imageTask = nil
        photoView.image = nil
        chipsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
    
    func configure(result: ResultProfile, row: Int) {

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
         //photoView.image = UIImage(named: "defaultProfile")
        photoView.image = DefaultImageCycler.image(forRow: row)
                ?? UIImage(systemName: "person.crop.square")
        
        photoView.layer.borderWidth = 2
        photoView.layer.borderColor = UIColor.systemBlue.cgColor
        photoView.layer.borderColor = TagCategory.age.accentColor.cgColor
        }
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






