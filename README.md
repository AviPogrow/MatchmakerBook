# MatchmakerBook

An iOS app that helps professional matchmakers manage candidate profiles and import profile data from multiple real-world sources.

The app supports:
- paper resume scanning with OCR
- digital resume import through an iOS Share Extension
- importing candidate details from the Contacts app

Built with Swift, UIKit, Firebase, and iOS platform integrations such as Share Extensions, App Groups, deep linking, OCR, and Contacts.

## High-Level Workflow

Paper Resume / Digital Resume / Contacts  
↓  
OCR or Data Extraction  
↓  
Resume Parsing  
↓  
Parsed Field Review  
↓  
Prefilled Profile Form  
↓  
Save to Firebase

## Resume Intake System

Matchmakers often receive candidate information in different formats.  
This app includes a system that converts resumes and contact information into structured profile data automatically.

### Supported Import Methods

#### 1. Paper Resume Scanning

Users can scan a physical resume using the device camera.  
The system performs OCR and extracts structured fields which are used to prefill the profile creation form.

**Workflow**

Camera Scan  
↓  
Vision OCR  
↓  
Text Parsing  
↓  
Parsed Field Review  
↓  
Prefilled Profile Form  
↓  
Save to Firebase

#### 2. Digital Resume Import (Share Extension)

Users can import resumes directly from other apps such as WhatsApp, Mail, Photos, or Files using an iOS Share Extension.

**Workflow**

External App  
↓  
Share Extension  
↓  
App Group Payload  
↓  
Deep Link into Main App  
↓  
Text Extraction  
↓  
Resume Parsing  
↓  
Parsed Review Screen  
↓  
Prefilled Profile Form  
↓  
Save to Firebase

#### 3. Import from Contacts

Users can import candidate information directly from the iOS Contacts app.  
The system extracts relevant contact fields and maps them into the profile creation form.

**Workflow**

Contacts Picker  
↓  
Extract Contact Fields  
↓  
Prefill Profile Form  
↓  
Save to Firebase

## Architecture Highlights

The app uses several architectural components to manage navigation, data parsing, and profile creation workflows.
- Router-based navigation handles deep link routing from the Share Extension into the correct screen flow.
- The ResumeImportRouter coordinates the flow from deep link → profile list → profile creation. -  Resume parsing is separated from the UI layer so extracted data can be reviewed before populating the profile form.
 - Profile data is stored and synchronized using Firebase Realtime Database.
   
  ## Technology Stack

- Swift
- UIKit
- Firebase Realtime Database
- Share Extensions
- App Groups
- Deep Linking
- Vision OCR
- Contacts Framework
- Eureka Forms

  ## Project Goal

This project explores how modern iOS platform features can be combined to automate real-world workflows for professional matchmakers.

The focus of the app is reducing manual data entry by allowing candidate information to be imported from multiple sources such as paper resumes, messaging apps, and the iOS Contacts system.
  



