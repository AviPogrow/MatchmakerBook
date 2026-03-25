# MatchmakerBook

**Production iOS application used by 200+ professional matchmakers to manage candidate profiles and automate resume-based profile creation.**

⭐ 4.9 App Store Rating (40+ reviews)  
⚡ Reduces manual data entry by ~60%  
📱 Built with UIKit, Swift, Firebase, Vision OCR, and Share Extensions  

---

## 📱 App Screens

### 🔍 Search & Filtering
![Search](https://github.com/AviPogrow/MatchmakerBook/blob/main/SearchFilter.png?raw=true)

### 👤 Candidate Profile
![Profile](PASTE_URL_HERE)

### 🧠 Resume OCR Pipeline
![OCR](PASTE_URL_HERE)
---

## 🚀 Overview

MatchmakerBook converts unstructured candidate information from real-world sources into structured, searchable profiles.

Supported input sources:
- 📄 Paper resumes (camera + OCR)
- 📎 Digital documents (PDF/image)
- 📇 iOS Contacts
- 📤 Share Extension (WhatsApp, email)

The system is actively used in production to manage hundreds of candidate profiles across real matchmaking workflows.

---

## ⚙️ Key Features

### 🧠 Resume OCR Pipeline
- Vision OCR extracts text from resumes  
- Natural Language parsing identifies structured fields  
- User reviews extracted data before applying  
- Profiles are automatically generated  

### 🔍 Advanced Search & Filtering
- Real-time text search (name, city, notes)  
- Structured filters (age, life plans, etc.)  
- Dynamic UI updates with large datasets  

### 📥 Multi-Source Intake System
- Manual entry  
- Contacts import (CNContact)  
- Resume scanning (Vision OCR)  
- Share extension ingestion  

### 📤 Profile Sharing System
- Send resumes + photos via:
  - SMS
  - Email
  - WhatsApp  

### 📇 Contact & Reference Management
- Store structured contact data:
  - Parents
  - Mentors
  - References  
- Direct communication from within the app  

---

## 🏗 Architecture Overview

Camera / PDF / Contacts / Share Extension  
↓  
Vision OCR  
↓  
Text Parsing Engine  
↓  
Structured Profile Model  
↓  
Firebase Realtime Database  
↓  
Search & Filtering  
↓  
Matchmaker Workflow
