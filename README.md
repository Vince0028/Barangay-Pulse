<div align="center">
  <img src="brgy_pulse/assets/logo.png" width="120" height="120" alt="BrgyPulse Logo" />
  <h1>BrgyPulse</h1>
  <p><strong>Building Smarter, Safer, and More Inclusive Communities.</strong></p>
</div>

<br>

## 📖 Project Brief

BrgyPulse is a decentralized civic reporting and emergency management app tailored for local Philippine communities (Barangays). It's designed to solve real problems on the ground, specifically focusing on everyday civic issues and offline disaster resilience.

BrgyPulse is split into two primary operational modes:
1. **Everyday Civic Mode:** Designed for routine reports such as uncollected trash, illegal parking, noise complaints, and infrastructure damage.
2. **Emergency/Disaster Mode:** A vital mode during typhoons and calamities featuring live SOS reporting, flood mapping, and an offline mesh network protocol.

---

## 👥 Team

**Team Name:** Merge Conflict

**Members:**
- Vince Nelmar Alobin
- Marwin John Gonzales
- Qelvin Nagales
- Rick Cruz


---

## 🛠️ Google Technologies Used

To build a robust and scalable solution, BrgyPulse integrates the following Google technologies:

- **Flutter:** Used as the cross-platform UI toolkit to build our high-performance mobile applications.
- **Firebase & Google Cloud:** Utilized for robust backend services, secure authentication, and cloud functions.
- **Google Maps Platform:** Provides geolocation tracking, interactive mapping for civic issues, and flood mapping capabilities.
- **Google Nearby Connections API:** Powers our critical offline mesh network protocol for peer-to-peer disaster communication.
- **Gemini API:** Used for intelligent processing and smart community insights.

---

## 🏆 SparkFest 2026

*Note: This project was exclusively developed and submitted for **SparkFest 2026** to address the hackathon's theme of building smarter, safer, and more inclusive communities.*

---

## 📚 Documentation Index

We have broken down our project into a comprehensive, easy-to-navigate documentation folder. Click on any of the links below to dive deep into how BrgyPulse works.

| Documentation | Description |
| :--- | :--- |
| **[1. Project Introduction](docs/01_introduction.md)** | Overview, Problem Statement, and Hackathon Strategy |
| **[2. Architecture & Tech Stack](docs/02_architecture.md)** | Breakdown of the Google Tech Stack (Flutter, Firebase, etc.) |
| **[3. Core Features](docs/03_features.md)** | Deep dive into the Civilian and Admin capabilities |
| **[4. Offline Mesh Chat (IoT)](docs/04_mesh_network.md)** | How we use Bluetooth & WiFi Direct for disaster mode |
| **[5. Database Schema](docs/05_database.md)** | Supabase PostgreSQL schema, RLS policies & Triggers |

---

## 🚀 Quick Setup & Installation

To run this locally, ensure you have Flutter installed.

```bash
# Clone the repository
git clone <your-repo-url>
cd barangray_pulse

# For the Civilian App
cd brgy_pulse
flutter pub get
flutter run

# For the Admin App
cd ../brgy_pulse_admin
flutter pub get
flutter run
```

---

<div align="center">
  <i>Built with ❤️ for SparkFest 2026</i>
</div>
