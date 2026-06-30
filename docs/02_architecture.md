# 2. Architecture & Tech Stack

## Technology Stack

To satisfy the SparkFest 2026 rule of utilizing Google Technologies, BrgyPulse relies heavily on a robust, scalable stack.

| Domain | Technology | Description |
| :--- | :--- | :--- |
| **Frontend UI/UX** | **Flutter** (Google) | Cross-platform UI toolkit providing native performance. |
| **Backend / Auth** | **Supabase** / **Firebase** | PostgreSQL + Edge Functions. Includes real-time sockets. |
| **Mapping & Location**| **Google Maps Platform** | Flutter Google Maps SDK, geolocation tracking. |
| **Local Storage** | **Hive** | Lightweight, blazing-fast NoSQL database for caching offline reports. |
| **Offline Networking**| **Nearby Connections API**| Google's peer-to-peer framework utilizing Bluetooth and Wi-Fi Direct. |

## System Flow

1. **User Auth:** Users log in securely via Supabase Auth.
2. **Online State:** When connected to the internet, reports and chat messages are streamed directly to the central PostgreSQL database.
3. **Offline State:** When internet drops, the app switches to **Hive** local storage. The `MeshController` activates Bluetooth/Nearby APIs to broadcast messages peer-to-peer to other nearby devices until it finds a connection.

---

[⬅️ Previous: Introduction](01_introduction.md) | [Next: Core Features ➡️](03_features.md)
