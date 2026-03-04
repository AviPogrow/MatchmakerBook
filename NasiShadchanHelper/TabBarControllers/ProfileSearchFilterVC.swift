

import UIKit
import Firebase

final class BoysSearchFilterVC: UIViewController {
    
    
    // MARK: - Data
    private var boysByKey: [String: NasiBoy] = [:]
    private var allResults: [BoyResult] = []
    private var filteredResults: [BoyResult] = []

    private var selectedAgeTags = Set<BoyAgeTag>()
    private var selectedHeightTags = Set<BoyHeightTag>()
    private var selectedLifePlans = Set<String>() // maps to NasiBoy.categories (optional)

    private var currentSearchText: String = ""
    private let useFirebase: Bool = true
    
    

    enum BoyAgeTag: CaseIterable, Hashable {
        case twentyOneToTwentyFour
        case twentyFiveToTwentyEight
        case twentyNinePlus

        var title: String {
            switch self {
            case .twentyOneToTwentyFour: return "21–24"
            case .twentyFiveToTwentyEight: return "25–28"
            case .twentyNinePlus: return "29+"
            }
        }

        var ageRange: ClosedRange<Int> {
            switch self {
            case .twentyOneToTwentyFour: return 21...24
            case .twentyFiveToTwentyEight: return 25...28
            case .twentyNinePlus: return 29...120
            }
        }
    }

    enum BoyHeightTag: CaseIterable, Hashable {
        case underOrEqual55
        case h56to58
        case h59to60
        case h61plus

        var title: String {
            switch self {
            case .underOrEqual55: return "5'5 and under"
            case .h56to58: return "5'6–5'8"
            case .h59to60: return "5'9–6'0"
            case .h61plus: return "6'1+"
            }
        }

        var inchRange: ClosedRange<Int> {
            switch self {
            case .underOrEqual55: return 0...65
            case .h56to58: return 66...68
            case .h59to60: return 69...72
            case .h61plus: return 73...120
            }
        }
    }


    // MARK: - UI
    private let navTitleView = GirlsFilterSearchVC.NavTitleView()

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

    private lazy var emptyStateView: EmptyStateView = {
        let v = EmptyStateView()
        v.onClearTapped = { [weak self] in self?.clearTapped() }
        return v
    }()

    private let resultsTableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.keyboardDismissMode = .onDrag
        tv.tableFooterView = UIView()
        return tv
    }()

    // MARK: - Tags backing chips UI
    private enum TagCategory: Int, CaseIterable {
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
            case .height: return .systemBlue
            case .age: return .systemGreen
            case .lifePlans: return .systemPurple
            }
        }
    }

    private struct TagItem: Hashable {
        let id = UUID()
        let category: TagCategory
        let title: String
    }

    private lazy var tagsByCategory: [TagCategory: [TagItem]] = [
        .height: BoyHeightTag.allCases.map { TagItem(category: .height, title: $0.title) },
        .age: BoyAgeTag.allCases.map { TagItem(category: .age, title: $0.title) },
        .lifePlans: [] // optional: fill if you want categories chips
    ]

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        navTitleView.configure(title: "Search Boys", subtitle: nil)
        navigationItem.titleView = navTitleView

        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addBoyTapped)
        )

        let clearButton = UIBarButtonItem(
            title: "Clear",
            style: .plain,
            target: self,
            action: #selector(clearTapped)
        )
        clearButton.isEnabled = false

        navigationItem.rightBarButtonItems = [addButton, clearButton]

        searchBar.delegate = self
        searchBar.showsCancelButton = true

        resultsTableView.dataSource = self
        resultsTableView.delegate = self
        resultsTableView.register(BoyResultCell.self, forCellReuseIdentifier: BoyResultCell.reuseID)
        resultsTableView.rowHeight = UITableView.automaticDimension
        resultsTableView.estimatedRowHeight = 76

        setupUI()

        if useFirebase {
            loadBoys()
        } else {
            // If you want mocks later, stub here
            applyFilters()
        }
    }

    // MARK: - Layout
    private func setupUI() {
        view.addSubview(searchBar)
        view.addSubview(chipsCollectionView)
        view.addSubview(resultsTableView)

        searchBar.translatesAutoresizingMaskIntoConstraints = false
        chipsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        resultsTableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            chipsCollectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            chipsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chipsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            chipsCollectionView.heightAnchor.constraint(equalToConstant: 220),

            resultsTableView.topAnchor.constraint(equalTo: chipsCollectionView.bottomAnchor, constant: 8),
            resultsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            resultsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            resultsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - Actions
    @objc private func addBoyTapped() {
        // TODO: push your Add/Edit Boy VC when you have it
        print("Add boy tapped")
    }

    private func updateClearButtonEnabled() {
        let hasTags = !selectedAgeTags.isEmpty || !selectedHeightTags.isEmpty || !selectedLifePlans.isEmpty
        let hasText = !currentSearchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        navigationItem.rightBarButtonItems?.last?.isEnabled = hasTags || hasText
    }

    @objc private func clearTapped() {
        selectedAgeTags.removeAll()
        selectedHeightTags.removeAll()
        selectedLifePlans.removeAll()

        chipsCollectionView.indexPathsForSelectedItems?.forEach {
            chipsCollectionView.deselectItem(at: $0, animated: true)
        }

        currentSearchText = ""
        searchBar.text = ""
        searchBar.resignFirstResponder()

        applyFilters()
    }

    // MARK: - Firebase load
    private func loadBoys() {
        fetchBoysFromFirebase { [weak self] boys in
            guard let self else { return }

            self.boysByKey = Dictionary(uniqueKeysWithValues: boys.map { ($0.key, $0) })
            self.allResults = boys.map { self.makeResult(from: $0) }

            self.applyFilters()
        }
    }

    private func fetchBoysFromFirebase(completion: @escaping ([NasiBoy]) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            DispatchQueue.main.async { completion([]) }
            return
        }

        let ref = Database.database().reference()
            .child("NasiBoysList")   // <-- adjust to your real node name
            .child(uid)

        ref.observeSingleEvent(of: .value) { snapshot in
            var boys: [NasiBoy] = []
            boys.reserveCapacity(Int(snapshot.childrenCount))

            for child in snapshot.children {
                guard let snap = child as? DataSnapshot else { continue }
                boys.append(NasiBoy(snapshot: snap))
            }

            boys.sort {
                let aFirst = $0.boyFirstName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                let bFirst = $1.boyFirstName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                if aFirst != bFirst { return aFirst < bFirst }

                let aLast = $0.boyLastName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                let bLast = $1.boyLastName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                return aLast < bLast
            }

            DispatchQueue.main.async { completion(boys) }
        }
    }

    // MARK: - Mapping + filtering

    private func makeResult(from b: NasiBoy) -> BoyResult {
        let fullName = "\(b.boyFirstName) \(b.boyLastName)"
            .replacingOccurrences(of: "  ", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let ageInt: Int? = {
            let dob = b.dobIntervalString.trimmingCharacters(in: .whitespacesAndNewlines)
            if !dob.isEmpty {
                let ageDouble = b.calculateAgeFrom(dobString: dob)
                let a = ageDouble > 0 ? Int(ageDouble.rounded()) : nil
                if let a { return a }
            }
            return b.ageEntered > 0 ? b.ageEntered : nil
        }()

        let inches = HeightParser.parseInches(from: b.boyHeight)
        let heightText: String = inches.map { "\($0 / 12)'\($0 % 12)\"" } ?? ""

        return BoyResult(
            id: b.key,
            name: fullName,
            age: ageInt,
            heightInches: inches,
            heightText: heightText,
            city: b.city,
            categories: b.categories,
            photoURL: b.photoImageURL.isEmpty ? nil : b.photoImageURL
        )
    }

    private func applyFilters() {
        let q = currentSearchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        filteredResults = allResults.filter { r in

            if !selectedHeightTags.isEmpty {
                guard let inches = r.heightInches else { return false }
                if !selectedHeightTags.contains(where: { $0.inchRange.contains(inches) }) { return false }
            }

            if !selectedAgeTags.isEmpty {
                guard let age = r.age else { return false }
                if !selectedAgeTags.contains(where: { $0.ageRange.contains(age) }) { return false }
            }

            if !selectedLifePlans.isEmpty {
                let profilePlans = Set(r.categories)
                if selectedLifePlans.isDisjoint(with: profilePlans) { return false }
            }

            if !q.isEmpty {
                let searchable = r.name + " " + r.city + " " + r.categories.joined(separator: " ")
                let tokens = searchable
                    .lowercased()
                    .split { !$0.isLetter && !$0.isNumber }
                    .map(String.init)

                if !tokens.contains(where: { $0.hasPrefix(q) }) { return false }
            }

            return true
        }

        resultsTableView.reloadData()
        updateEmptyState()
        updateResultsHeader()
        updateClearButtonEnabled()
    }

    private func updateResultsHeader() {
        let q = currentSearchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if q.isEmpty {
            resultsHeaderLabel.text = "Results (\(filteredResults.count))"
        } else {
            resultsHeaderLabel.text = "Results (\(filteredResults.count)) • “\(q)”"
        }
    }

    private func updateEmptyState() {
        if filteredResults.isEmpty {
            resultsTableView.backgroundView = emptyStateView
            resultsTableView.separatorStyle = .none
            resultsHeaderLabel.text = "Results (0)"
        } else {
            resultsTableView.backgroundView = nil
            resultsTableView.separatorStyle = .singleLine
        }
    }

    private func heightTag(from title: String) -> BoyHeightTag? {
        BoyHeightTag.allCases.first { $0.title == title }
    }

    private func ageTag(from title: String) -> BoyAgeTag? {
        BoyAgeTag.allCases.first { $0.title == title }
    }
}

// MARK: - UISearchBarDelegate
extension BoysSearchFilterVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        currentSearchText = searchText
        applyFilters()
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
extension BoysSearchFilterVC: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int { 1 }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        resultsHeaderView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        34
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredResults.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: BoyResultCell.reuseID,
            for: indexPath
        ) as! BoyResultCell

        cell.configure(result: filteredResults[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let r = filteredResults[indexPath.row]
        guard let boy = boysByKey[r.id] else { return }

        // TODO: push Add/Edit boy VC
        print("Selected boy:", boy.boyFirstName, boy.boyLastName)
    }
}

// MARK: - UICollectionViewDataSource / DelegateFlowLayout
extension BoysSearchFilterVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // If you later add life plans chips, return TagCategory.allCases.count
        // For now: height + age only
        2
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let cat = TagCategory(rawValue: section)! // 0 height, 1 age
        return tagsByCategory[cat]?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ChipCell.reuseID,
            for: indexPath
        ) as! ChipCell

        let cat = TagCategory(rawValue: indexPath.section)!
        let tag = tagsByCategory[cat]![indexPath.item]

        let isSelected: Bool
        switch cat {
        case .height:
            isSelected = selectedHeightTags.contains(where: { $0.title == tag.title })
        case .age:
            isSelected = selectedAgeTags.contains(where: { $0.title == tag.title })
        case .lifePlans:
            isSelected = false
        }

        cell.configure(text: tag.title, accentColor: cat.accentColor, selected: isSelected)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let cat = TagCategory(rawValue: indexPath.section)!
        let tag = tagsByCategory[cat]![indexPath.item]

        let font = UIFont.systemFont(ofSize: 15, weight: .medium)
        let textWidth = (tag.title as NSString).size(withAttributes: [
            .font: font
        ]).width

        let nonTextWidth: CGFloat = 48

        let insetsLR: CGFloat
        if let flow = collectionViewLayout as? UICollectionViewFlowLayout {
            insetsLR = flow.sectionInset.left + flow.sectionInset.right
        } else {
            insetsLR = 32
        }

        let maxWidth = collectionView.bounds.width - insetsLR
        let finalWidth = min(textWidth + nonTextWidth, maxWidth)

        return CGSize(width: finalWidth, height: 32)
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {

        guard kind == UICollectionView.elementKindSectionHeader else { return UICollectionReusableView() }

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
        let title = tagsByCategory[cat]![indexPath.item].title

        switch cat {
        case .height:
            if let ht = heightTag(from: title) { selectedHeightTags.insert(ht) }
        case .age:
            if let at = ageTag(from: title) { selectedAgeTags.insert(at) }
        case .lifePlans:
            break
        }

        applyFilters()
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cat = TagCategory(rawValue: indexPath.section)!
        let title = tagsByCategory[cat]![indexPath.item].title

        switch cat {
        case .height:
            if let ht = heightTag(from: title) { selectedHeightTags.remove(ht) }
        case .age:
            if let at = ageTag(from: title) { selectedAgeTags.remove(at) }
        case .lifePlans:
            break
        }

        applyFilters()
    }
}

// MARK: - Result Model + Cell

struct BoyResult: Identifiable, Hashable {
    let id: String
    let name: String
    let age: Int?
    let heightInches: Int?
    let heightText: String
    let city: String
    let categories: [String]
    let photoURL: String?
}

final class BoyResultCell: UITableViewCell {
    static let reuseID = "BoyResultCell"

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = .systemFont(ofSize: 17, weight: .semibold)
        l.numberOfLines = 1
        l.lineBreakMode = .byTruncatingTail
        return l
    }()

    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = .systemFont(ofSize: 14)
        l.textColor = .secondaryLabel
        l.numberOfLines = 2
        return l
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .default

        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),

            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(result: BoyResult) {
        let ageText = result.age.map(String.init) ?? ""
        let pieces = [result.name,
                      ageText.isEmpty ? nil : ageText,
                      result.heightText.isEmpty ? nil : result.heightText]
            .compactMap { $0 }
        titleLabel.text = pieces.joined(separator: " • ")

        // Keep this simple for now; you can add chip views like girls later
        subtitleLabel.text = result.city
    }
}

