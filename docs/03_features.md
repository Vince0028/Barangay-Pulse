# 3. Core Features

BrgyPulse is actually two integrated applications in one system:

## The Civilian App (`brgy_pulse`)

The citizen-facing application built for everyday residents of the Barangay.

*   **Interactive Maps:** Citizens can view an overhead map of their barangay and drop pins directly at the site of an incident.
*   **Civic Reporting UI:** A beautifully designed bottom-sheet flow allows citizens to:
    *   Categorize an issue (Flood, Crime, Pothole, Trash, etc.)
    *   Upload photos or provide a description.
    *   Set priority levels (Low, Medium, Emergency SOS).
*   **Offline Chat:** A dedicated tab that searches for nearby devices to send messages to the command center even without cellular data.

## The Admin Dashboard (`brgy_pulse_admin`)

The Command Center portal built for local government officials and emergency responders.

*   **Command Map View:** A bird's-eye view tracking all incoming reports and active SOS pings.
*   **Status Management:** Admins can triage issues, assigning statuses like "Pending", "In Progress", and "Resolved".
*   **Official Account Management:** Built-in ability for super-admins to generate trusted accounts for emergency dispatchers.
*   **Offline Relay Node:** The admin app can act as a central hub on the Mesh network, actively listening for incoming offline SOS pings from the community.

---

[⬅️ Previous: Architecture](02_architecture.md) | [Next: Offline Mesh Network ➡️](04_mesh_network.md)
