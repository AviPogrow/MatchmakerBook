# 📱 MatchmakerBook

**Production iOS application used by 200+ professional matchmakers to manage candidate profiles and automate resume-based profile creation.**

⭐ 4.9 App Store Rating (40+ reviews)  
⚡ Reduces manual data entry by ~60%  
📊 Handles hundreds of candidate profiles in real-time workflows  

---

## 🚀 Overview

MatchmakerBook transforms unstructured candidate data from real-world sources into structured, searchable profiles.

Instead of manually entering data from resumes, matchmakers can:

- 📄 Scan paper resumes using Vision OCR  
- 📎 Import digital resumes (PDF/image)  
- 📇 Pull data from iOS Contacts  
- 📤 Share resumes directly from apps like WhatsApp and email  

This enables faster, more accurate matchmaking workflows at scale.

---

## 🧠 Core Workflows

### Resume → Structured Profile
Resume (camera / PDF / share sheet)  
→ OCR extraction  
→ Field parsing & normalization  
→ Prefilled review screen  
→ Saved structured profile  

### Candidate Search & Matching
Structured profiles  
→ Real-time filtering (age, height, plans)  
→ Text search (name, city, notes)  
→ Instant results  

---

## 📱 App Screens

### 🔍 Powerful Search & Filtering
Quickly narrow down candidates using multi-dimensional filters — including age, height, and life plans — with instant, real-time results.

<p align="center">
  <img src="https://raw.githubusercontent.com/AviPogrow/MatchmakerBook/main/SearchFilter.png" height="500"/>
</p>

---

### 👤 Structured Candidate Profiles
All relevant candidate information — personal details, background, and notes — organized into a clean, scannable interface.

<p align="center">
  <img src="https://raw.githubusercontent.com/AviPogrow/MatchmakerBook/main/profile.png" height="500"/>
</p>

---

### 🧠 Resume → Profile Automation (OCR Pipeline)
Convert unstructured resumes into structured profiles in seconds, reducing manual data entry by ~60%.

<p align="center">
  <img src="https://raw.githubusercontent.com/AviPogrow/MatchmakerBook/main/ocr.jpg" height="400"/>
</p>

---

## ⚙️ Key Features

### 🧠 Resume OCR Pipeline
- Vision OCR extracts text from resumes  
- NLP parsing identifies structured fields  
- User review before applying data  
- Automatic profile generation  

### 🔍 Advanced Search & Filtering
- Real-time text search (name, city, notes)  
- Structured filters (age, life plans)  
- Instant UI updates with large datasets  

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
Search & Filtering  iltering  

↓  
Matchmaker Workflow
