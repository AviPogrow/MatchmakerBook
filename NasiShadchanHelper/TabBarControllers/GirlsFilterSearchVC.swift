//
//  GirlsFilterSearchVC.swift
//  NasiShadchanHelper
//
//  Created by Avi Pogrow on 1/29/26.
//  Copyright © 2026 user. All rights reserved.
//

import UIKit

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

    var title: String {
        switch self {
        case .ftlOneToThree:
            return "FTL - 1-3"
        case .ftlThreeToFive:
            return "FTL - 3-5"
        case .ftlFive:
            return "FTL - 5"
        case .ftlFiveToSeven:
            return "FTL - 5-7"
        case .ftlSevenPlus:
            return "FTL - 7+"
        case .ptlSchool:
            return "PTL - S"
        case .ptlWorking:
            return "PTL - W"
        case .ftwCollegeYeshiva:
            return "FTW/S-YS"
        case .ftwCollegeNotYeshiva:
            return "FTW/S-NYS"
        }
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

class GirlsFilterSearchVC: UIViewController {
    
    private lazy var emptyStateView: EmptyStateView = {
        let v = EmptyStateView()
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

    private lazy var resultsHeaderView: UIView = {
        let v = UIView()
        v.backgroundColor = .systemBackground

        v.addSubview(resultsHeaderLabel)
        resultsHeaderLabel.translatesAutoresizingMaskIntoConstraints = false

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        allProfiles = makeMockProfiles()
        filteredProfiles = allProfiles

        view.backgroundColor = .systemBackground

        navTitleView.configure(
            title: "Search",
            subtitle: "\(filteredProfiles.count) results"
        )
        navigationItem.titleView = navTitleView

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeTapped)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Clear",
            style: .plain,
            target: self,
            action: #selector(clearTapped)
        )
        navigationItem.rightBarButtonItem?.isEnabled = false

        
        searchBar.delegate = self

        resultsTableView.dataSource = self
        resultsTableView.delegate = self
        
        resultsTableView.register(ProfileResultCell.self,
                             forCellReuseIdentifier: ProfileResultCell.reuseID)

        resultsTableView.rowHeight = UITableView.automaticDimension
        resultsTableView.estimatedRowHeight = 76

        setupUI()
        
      }
    
    private func updateClearButtonEnabled() {
        let hasSelections = !selectedHeightTags.isEmpty || !selectedAgeTags.isEmpty || !selectedLifePlans.isEmpty
        navigationItem.rightBarButtonItem?.isEnabled = hasSelections
    }
    
     @objc private func clearTapped() {
         selectedHeightTags.removeAll()
         selectedAgeTags.removeAll()
         selectedLifePlans.removeAll()

         chipsCollectionView.indexPathsForSelectedItems?.forEach {
             chipsCollectionView.deselectItem(at: $0, animated: true)
         }

         // Reset data
         filteredProfiles = allProfiles

         // Reload table
         resultsTableView.reloadData()

         // 👇 Update empty state HERE
         updateEmptyState()

         // Other UI cleanup
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
        
        NSLayoutConstraint.activate([
                   // Search bar pinned to safe area top
                   searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                   searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                   searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),

                   // Chips row under search bar
                   chipsCollectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
                   chipsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                   chipsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                   chipsCollectionView.heightAnchor.constraint(equalToConstant: 220),

                   // Results fill remaining space
                   resultsTableView.topAnchor.constraint(equalTo: chipsCollectionView.bottomAnchor, constant: 8),
                   resultsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                   resultsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                   resultsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
               ])

    }

    @objc private func closeTapped() {
          dismiss(animated: true)
      }

}

extension GirlsFilterSearchVC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Placeholder behavior for now:
        if searchText.isEmpty {
            results = (1...25).map { "Result \($0)" }
        } else {
            results = (1...25).map { "Result \($0)" }.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
        resultsTableView.reloadData()
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
        filteredProfiles.count
    }
      
    
    func tableView(_ tableView: UITableView,
                             cellForRowAt indexPath: IndexPath) -> UITableViewCell {

         let cell = tableView.dequeueReusableCell(withIdentifier: ProfileResultCell.reuseID,
                                                  for: indexPath) as! ProfileResultCell

         let profile = filteredProfiles[indexPath.row] // or whatever your data array is
         cell.configure(profile: profile)

         return cell
     }

     
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // Later: open profile / detail
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
        if filteredProfiles.isEmpty {
            resultsTableView.backgroundView = emptyStateView
            resultsTableView.separatorStyle = .none
            resultsHeaderLabel.text = "Results (0)"
        } else {
            resultsTableView.backgroundView = nil
            resultsTableView.separatorStyle = .singleLine
            resultsHeaderLabel.text = "Results (\(filteredProfiles.count))"
        }
    }
    
    

     private func applyFilters() {
         

         // iterate over all the profiles
         let newFiltered = allProfiles.filter { p in
             
             if !selectedHeightTags.isEmpty {
                 let matches = selectedHeightTags.contains { $0.inchRange.contains(p.heightInches) }
                 if !matches { return false }
             }
             if !selectedAgeTags.isEmpty {
                 let matches = selectedAgeTags.contains { $0.ageRange.contains(p.age) }
                 if !matches { return false }
             }

             if !selectedLifePlans.isEmpty {
                 let selectedTitles = Set(selectedLifePlans.map { $0.title })

                 let profileTitles = Set(p.lifePlans)
                 if selectedTitles.isDisjoint(with: profileTitles) { return false }
             }

             return true
         }
         print("applyFilters fired. selectedAgeTags:", selectedAgeTags.map(\.title), "result:", newFiltered.count)

         
         // 1. Update the data
         filteredProfiles = newFiltered

         // 2. Reload the table
         resultsTableView.reloadData()

         // 3. NOW update empty state 👈 THIS IS THE LINE
         updateEmptyState()

         // 4. Other UI updates
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

    func configure(title: String) { label.text = title }
}

final class EmptyStateView: UIView {

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
    
    
     func configure(profile: MockProfile) {
         
         // Clear old chips (important for reused cells)
          chipsStack.arrangedSubviews.forEach { v in
              chipsStack.removeArrangedSubview(v)
              v.removeFromSuperview()
          }

         // ---- Title line: Name • Age • Height ----
         let ageText = String(profile.age)

         let inches = profile.heightInches
         let heightText = "\(inches / 12)'\(inches % 12)\""

         titleLabel.text = "\(profile.name) • \(ageText) • \(heightText)"

         // ---- Life plan chips (max 3 + “+N more”) ----
         let maxChips = 4
         let plans = profile.lifePlans
         let shown = Array(plans.prefix(maxChips))
         let remaining = plans.count - shown.count

         for plan in shown {
             // Uncomment when ResultChipView is ready
              chipsStack.addArrangedSubview(
                  ResultChipView(text: plan, accent: TagCategory.lifePlans.accentColor)
              )
         }

         if remaining > 0 {
              chipsStack.addArrangedSubview(
                ResultChipView(text: "+\(remaining)", accent: TagCategory.lifePlans.accentColor)
              )
         }

         // ---- Image (mock placeholder) ----
         photoView.image = UIImage(systemName: "person.crop.square")
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






