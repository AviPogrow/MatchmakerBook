# MatchmakerBook

MatchmakerBook is an iOS application used by professional matchmakers to manage candidate profiles and automate profile creation from resumes.

The system converts candidate information from multiple real-world sources into structured, searchable profiles, reducing manual data entry for matchmakers.

The app is currently used by professional matchmakers and manages hundreds of candidate profiles in production.

Supported input sources include paper resumes, digital documents, and the iOS Contacts system.

The app is built using Swift, UIKit, Firebase, and several iOS platform integrations including Share Extensions, Vision OCR, App Groups, and deep linking.

---

# Real-World Usage

MatchmakerBook is used in real matchmaking workflows to manage candidate information and streamline the process of sharing profiles with clients.

Common tasks supported by the system include:

• Importing candidate information from resumes or contacts
• Structuring candidate profiles for search and filtering
• Managing references and discussion contacts
• Sharing candidate resumes and photos with clients
• Quickly locating candidates using search and filters

The system currently manages hundreds of candidate profiles used in active matchmaking workflows.

---

# System Architecture

```
INPUT SOURCES
│
├── Camera Scanner
├── PDF / Image Resume
├── iOS Contacts Import
└── Share Extension
        │
        ▼
Vision OCR
        │
        ▼
Text Parsing Engine
        │
        ▼
Structured Profile Model
        │
        ▼
Firebase Realtime Database
        │
        ▼
Search & Filtering Engine
        │
        ▼
Matchmaker Workflow (Share Resume / Contact / Messaging)
```

---

# Resume OCR Pipeline

The system automatically converts resumes into structured candidate profiles.

Pipeline:

1. Resume image or document is captured
2. Apple Vision OCR extracts raw text
3. Text parsing identifies structured attributes
4. User reviews extracted data
5. Structured profile is saved to Firebase

Attributes extracted include:

• Name
• Phone number
• City
• Height
• Date of birth
• Education
• Additional notes

### Screenshot

Resume OCR review screen where extracted fields can be toggled before applying to a profile.

![OCR Review](screenshots/ocr_review.png)

---

# Candidate Profiles

Profiles store structured candidate information used by matchmakers during the matchmaking process.

Profile data includes:

• Name
• Age
• Height
• City
• Education / Seminary
• Family background
• Notes
• Photo

Profiles are generated automatically from parsed resume data and can be edited manually.

### Screenshot

![Candidate Profile](screenshots/profile_view.png)

---

# Search and Filtering

Matchmakers can quickly locate candidates using a hybrid query system combining text search with structured filters.

Supported queries include:

• Name search
• City search
• Notes search
• Age filters
• Life plan categories

The UI dynamically updates results as search and filters change.

### Screenshot

![Search Filters](screenshots/search_filters.png)

### Screenshot

Example of text search combined with structured filters.

![Text Search](screenshots/text_search.png)

---

# Sharing Candidate Profiles

Profiles can be shared directly with clients through messaging channels.

Matchmakers can send:

• Resume
• Candidate photo
• Resume + photo

Supported sharing methods include:

• SMS
• Email
• WhatsApp

This enables fast distribution of candidate profiles during matchmaking conversations.

### Screenshot

![Share Resume](screenshots/share_resume.png)

---

# Contact and Reference Management

Candidate profiles include structured contact information for discussion and references.

Contacts can include:

• Parents
• Mentors
• References
• Candidate contact information

Users can directly call, text, email, or message these contacts from the app.

### Screenshot

![Contacts](screenshots/contact_management.png)

---

# App Store Reception

MatchmakerBook currently maintains a **4.9 rating on the App Store with 40+ reviews**.

Users highlight the app's ability to organize candidate information and streamline matchmaking workflows.

### Screenshot

![App Store Reviews](screenshots/appstore_reviews.png)

---

# Technology Stack

• Swift
• UIKit
• Firebase Realtime Database
• Apple Vision OCR
• Share Extensions
• App Groups
• Deep Linking

---

# Key Features

• Resume OCR parsing
• Structured candidate database
• Search and filtering engine
• Messaging and sharing workflow
• Contact and reference management

---

# Summary

MatchmakerBook is a production iOS system designed to help professional matchmakers manage candidate data and streamline matchmaking workflows.

By combining OCR-based resume ingestion, structured profile management, and powerful search capabilities, the system transforms unstructured resume data into a searchable matchmaking database.


### Add / Edit Profile Form
*(Add screenshot here)*
