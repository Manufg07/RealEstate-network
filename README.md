# 🏡 RealEstate Network on Hyperledger Fabric

The **RealEstate Network** is a decentralized blockchain network built on **Hyperledger Fabric** that facilitates property transactions securely across multiple organizations. It includes **three organizations**: `RealEstateCorp`, `PropertyTrust`, and `LandRegistry`, and an **orderer** service that manages transaction ordering.

## 🎉 Current Status
- **RealEstate Network is built and operational**.
- It consists of:
  - **3 Organizations**: RealEstateCorp, PropertyTrust, LandRegistry.
  - **1 Orderer**: for managing transaction ordering and consensus.
  - **3 Peers**: One for each organization.
  - **CouchDB**: For state data persistence.
  
All components are running via Docker containers, and the network is fully functional with chaincode deployed to handle property transactions.

---

## 📋 Table of Contents

- [Network Architecture](#network-architecture)
- [How to Interact with the Network](#how-to-interact-with-the-network)
- [Network Status](#network-status)
- [Steps for Chaincode Interaction](#steps-for-chaincode-interaction)
- [Troubleshooting](#troubleshooting)
- [Future Improvements](#future-improvements)

---

## 🏗️ Network Architecture

### Organizations
- **RealEstateCorp**: Manages the listing and sale of properties.
- **PropertyTrust**: Trust-based organization ensuring property ownership records.
- **LandRegistry**: Official land ownership and legal registry.

### Components
- **Orderer**: `orderer.example.com` - Ensures that transactions are correctly ordered across the network.
- **Peers**: Each organization operates a peer:
  - `peer0.realestatecorp.example.com`
  - `peer0.propertytrust.example.com`
  - `peer0.landregistry.example.com`
- **CouchDB**: Each peer has its own CouchDB instance for state data storage.
- **Channels**: 
  - `realestatechannel` – Main channel where all transactions are processed.
  
The peers, orderer, and CouchDBs are deployed as Docker containers to ensure portability and ease of setup.

---

## 📡 Network Status

### Docker Containers
- **Orderer** is running on port `7050` for client communications and port `7053` for administrative purposes.
- **Peers** are running on the following ports:
  - RealEstateCorp: `7051`
  - PropertyTrust: `9051`
  - LandRegistry: `10051`
  
### TLS Security
All communication is secured with **TLS**, ensuring data integrity and confidentiality across the network.

---

## 🔧 How to Interact with the Network

Once the network is up, you can use the **Fabric CLI** or **SDKs** (Node.js, Go) to interact with the deployed chaincode and manage property transactions.

### 1. Querying the Network
To check the status of the network and existing properties:

```bash
peer chaincode query -C realestatechannel -n realestatecc -c '{"Args":["QueryAllProperties"]}'
