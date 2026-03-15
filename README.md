# MatchmakerBook

MatchmakerBook is an iOS application used by professional matchmakers to manage candidate profiles and automate profile creation from resumes.

The system converts candidate information from multiple real-world sources into structured, searchable profiles.

Supported input sources include **paper resumes, digital documents, and the iOS Contacts system**.

The app is built using **Swift, UIKit, Firebase**, and several iOS platform integrations including **Share Extensions, Vision OCR, App Groups, and deep linking**.

---

## Platform Overview

```text
                          Matchmaker Platform

Resume Intake
Paper Resume / Digital Resume / Contacts
                 ↓
           Data Extraction
        (Vision OCR / Parsing)
                 ↓
        Structured Profile Data
                 ↓
            Firebase
                 ↓
        Search & Profile UI


Client Profile Pipeline
Web Portal → Google Sheets → Firebase → Read-Only Client Profiles
```

---

## Core Workflows

### Resume Import Workflow

```text
Camera Scan / Share Extension / Contacts
                ↓
        OCR or Data Extraction
                ↓
           Resume Parsing
                ↓
       Prefilled Profile Form
                ↓
           Save to Firebase
```

### Client Profile Pipeline

```text
Web Portal Entry
        ↓
Google Sheets Review
        ↓
Firebase Sync
        ↓
Read-Only Client Profiles
        ↓
Quick Actions (Text / Email / Call References)
```

---

## Key Engineering Challenges

- Extracting structured data from **unstructured resumes using Vision OCR**
- Supporting **multiple data ingestion pipelines** with a consistent profile model
- Integrating an **iOS Share Extension** using **App Groups and deep linking**
- Designing workflows that allow **parsed data review before persistence**

---

## Technology Stack

Swift  
UIKit  
Firebase Realtime Database  
Vision OCR  
Share Extensions  
App Groups  
Deep Linking  
Contacts Framework  
Eureka Forms  

---

## Architecture Documentation

Detailed architecture explanations are available in the project **Wiki**.

---

## Screenshots

### Girls Profile List
*(Add screenshot here)*

### Resume Parsing Review
*(Add screenshot here)*

### Add / Edit Profile Form
*(Add screenshot here)*
