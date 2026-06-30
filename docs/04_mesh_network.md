# 4. Offline Mesh Chat (IoT)

One of the defining features of BrgyPulse that sets it apart in SparkFest is the **Offline Mesh Network protocol**. 

## The Problem
During severe typhoons in the Philippines, cell towers are frequently destroyed or lose power, cutting off entire communities from emergency services.

## The Solution
We integrated Google's `Nearby Connections API` (via Bluetooth and Wi-Fi Direct) to create an ad-hoc mesh network.

### How It Works

1. **Discovery:** When a user goes to the Chat tab and hits "Start Emergency Chat", their phone begins broadcasting a discovery signal.
2. **Peering:** Nearby phones (within ~30 to 100 meters, depending on hardware) automatically connect to each other.
3. **Data Relaying:** 
   - A user sends an SOS message.
   - The message is stored in a local `Hive` database on their phone.
   - The phone sends the message to a connected peer.
   - That peer forwards it to the next peer, jumping from phone to phone.
   - When any phone in the chain finally reconnects to the internet (or reaches an Admin node), the queued messages are synced to the central Command Center.

### Technical Limitations
- Currently, this feature requires physical Android hardware (Bluetooth Low Energy APIs are not available on web/iOS in the same capacity).
- Maximum hops are restricted to prevent infinite network flooding (TTL = 3).

---

[⬅️ Previous: Core Features](03_features.md) | [Next: Database Schema ➡️](05_database.md)
