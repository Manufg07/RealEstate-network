#!/bin/bash

function createRealestatecorp() {
  echo "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/realestatecorp.example.com/
  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/realestatecorp.example.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:7054 --caname ca-realestatecorp --tls.certfiles "${PWD}/organizations/fabric-ca/realestatecorp/ca-cert.pem"
  { set +x; } 2>/dev/null

  # Create the config.yaml file for NodeOUs
  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-realestatecorp.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-realestatecorp.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-realestatecorp.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-realestatecorp.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/realestatecorp.example.com/msp/config.yaml"

  # Create necessary directories and copy CA certs for MSP definition
  mkdir -p "${PWD}/organizations/peerOrganizations/realestatecorp.example.com/msp/cacerts"
  cp "${PWD}/organizations/fabric-ca/realestatecorp/ca-cert.pem" "${PWD}/organizations/peerOrganizations/realestatecorp.example.com/msp/cacerts/localhost-7054-ca-realestatecorp.pem"

  mkdir -p "${PWD}/organizations/peerOrganizations/realestatecorp.example.com/msp/tlscacerts"
  cp "${PWD}/organizations/fabric-ca/realestatecorp/ca-cert.pem" "${PWD}/organizations/peerOrganizations/realestatecorp.example.com/msp/tlscacerts/ca.crt"

  mkdir -p "${PWD}/organizations/peerOrganizations/realestatecorp.example.com/tlsca"
  cp "${PWD}/organizations/fabric-ca/realestatecorp/ca-cert.pem" "${PWD}/organizations/peerOrganizations/realestatecorp.example.com/tlsca/tlsca.realestatecorp.example.com-cert.pem"

  mkdir -p "${PWD}/organizations/peerOrganizations/realestatecorp.example.com/ca"
  cp "${PWD}/organizations/fabric-ca/realestatecorp/ca-cert.pem" "${PWD}/organizations/peerOrganizations/realestatecorp.example.com/ca/ca.realestatecorp.example.com-cert.pem"

  # Continue with peer0, user, and admin registration as before...


  # Register peer0
  echo "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-realestatecorp --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/realestatecorp/ca-cert.pem"
  { set +x; } 2>/dev/null

  # Register user
  echo "Registering user"
  set -x
  fabric-ca-client register --caname ca-realestatecorp --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/realestatecorp/ca-cert.pem"
  { set +x; } 2>/dev/null

  # Register realestatecorp admin
  echo "Registering the realestatecorp admin"
  set -x
  fabric-ca-client register --caname ca-realestatecorp --id.name realestatecorpadmin --id.secret realestatecorpadminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/realestatecorp/ca-cert.pem"
  { set +x; } 2>/dev/null

  # Generate the peer0 msp
  echo "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-realestatecorp -M "${PWD}/organizations/peerOrganizations/realestatecorp.example.com/peers/peer0.realestatecorp.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/realestatecorp/ca-cert.pem"
  { set +x; } 2>/dev/null
  cp "${PWD}/organizations/peerOrganizations/realestatecorp.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/realestatecorp.example.com/peers/peer0.realestatecorp.example.com/msp/config.yaml"

  # Generate the peer0-tls certificates
  echo "Generating the peer0-tls certificates, use --csr.hosts to specify Subject Alternative Names"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-realestatecorp -M "${PWD}/organizations/peerOrganizations/realestatecorp.example.com/peers/peer0.realestatecorp.example.com/tls" --enrollment.profile tls --csr.hosts peer0.realestatecorp.example.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/realestatecorp/ca-cert.pem"
  { set +x; } 2>/dev/null

  # Copy the tls CA cert, server cert, server keystore to known filenames in the peer's tls directory
  cp "${PWD}/organizations/peerOrganizations/realestatecorp.example.com/peers/peer0.realestatecorp.example.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/realestatecorp.example.com/peers/peer0.realestatecorp.example.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/realestatecorp.example.com/peers/peer0.realestatecorp.example.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/realestatecorp.example.com/peers/peer0.realestatecorp.example.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/realestatecorp.example.com/peers/peer0.realestatecorp.example.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/realestatecorp.example.com/peers/peer0.realestatecorp.example.com/tls/server.key"

  # Generate the user msp
  echo "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:7054 --caname ca-realestatecorp -M "${PWD}/organizations/peerOrganizations/realestatecorp.example.com/users/User1@realestatecorp.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/realestatecorp/ca-cert.pem"
  { set +x; } 2>/dev/null
  cp "${PWD}/organizations/peerOrganizations/realestatecorp.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/realestatecorp.example.com/users/User1@realestatecorp.example.com/msp/config.yaml"

  # Generate the realestatecorp admin msp
  echo "Generating the realestatecorp admin msp"
  set -x
  fabric-ca-client enroll -u https://realestatecorpadmin:realestatecorpadminpw@localhost:7054 --caname ca-realestatecorp -M "${PWD}/organizations/peerOrganizations/realestatecorp.example.com/users/Admin@realestatecorp.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/realestatecorp/ca-cert.pem"
  { set +x; } 2>/dev/null
  cp "${PWD}/organizations/peerOrganizations/realestatecorp.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/realestatecorp.example.com/users/Admin@realestatecorp.example.com/msp/config.yaml"
}

function createPropertytrust() {
  echo "Enrolling the CA admin for the Distributor"
  mkdir -p organizations/peerOrganizations/propertytrust.example.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/propertytrust.example.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:8054 --caname ca-propertytrust --tls.certfiles "${PWD}/organizations/fabric-ca/propertytrust/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-propertytrust.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-propertytrust.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-propertytrust.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-propertytrust.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/propertytrust.example.com/msp/config.yaml"

  # Copy Distributor's CA cert to its /msp/tlscacerts directory
  mkdir -p "${PWD}/organizations/peerOrganizations/propertytrust.example.com/msp/tlscacerts"
  cp "${PWD}/organizations/fabric-ca/propertytrust/ca-cert.pem" "${PWD}/organizations/peerOrganizations/propertytrust.example.com/msp/tlscacerts/ca.crt"

  # Copy Distributor's CA cert to its /tlsca directory (for use by clients)
  mkdir -p "${PWD}/organizations/peerOrganizations/propertytrust.example.com/tlsca"
  cp "${PWD}/organizations/fabric-ca/propertytrust/ca-cert.pem" "${PWD}/organizations/peerOrganizations/propertytrust.example.com/tlsca/tlsca.propertytrust.example.com-cert.pem"

  # Copy Distributor's CA cert to its /ca directory (for use by clients)
  mkdir -p "${PWD}/organizations/peerOrganizations/propertytrust.example.com/ca"
  cp "${PWD}/organizations/fabric-ca/propertytrust/ca-cert.pem" "${PWD}/organizations/peerOrganizations/propertytrust.example.com/ca/ca.propertytrust.example.com-cert.pem"

  echo "Registering peer0 for the Distributor"
  set -x
  fabric-ca-client register --caname ca-propertytrust --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/propertytrust/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Registering user for the Distributor"
  set -x
  fabric-ca-client register --caname ca-propertytrust --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/propertytrust/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Registering the Distributor admin"
  set -x
  fabric-ca-client register --caname ca-propertytrust --id.name Distributoradmin --id.secret Distributoradminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/propertytrust/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Generating the peer0 MSP for the Distributor"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-propertytrust -M "${PWD}/organizations/peerOrganizations/propertytrust.example.com/peers/peer0.propertytrust.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/propertytrust/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/propertytrust.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/propertytrust.example.com/peers/peer0.propertytrust.example.com/msp/config.yaml"

  echo "Generating the peer0-tls certificates for the Distributor"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-propertytrust -M "${PWD}/organizations/peerOrganizations/propertytrust.example.com/peers/peer0.propertytrust.example.com/tls" --enrollment.profile tls --csr.hosts peer0.propertytrust.example.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/propertytrust/ca-cert.pem"
  { set +x; } 2>/dev/null

  # Copy tls files to proper locations
  cp "${PWD}/organizations/peerOrganizations/propertytrust.example.com/peers/peer0.propertytrust.example.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/propertytrust.example.com/peers/peer0.propertytrust.example.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/propertytrust.example.com/peers/peer0.propertytrust.example.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/propertytrust.example.com/peers/peer0.propertytrust.example.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/propertytrust.example.com/peers/peer0.propertytrust.example.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/propertytrust.example.com/peers/peer0.propertytrust.example.com/tls/server.key"

  echo "Generating the user MSP for the Distributor"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:8054 --caname ca-propertytrust -M "${PWD}/organizations/peerOrganizations/propertytrust.example.com/users/User1@propertytrust.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/propertytrust/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/propertytrust.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/propertytrust.example.com/users/User1@propertytrust.example.com/msp/config.yaml"

  echo "Generating the Distributor admin MSP"
  set -x
  fabric-ca-client enroll -u https://Distributoradmin:Distributoradminpw@localhost:8054 --caname ca-propertytrust -M "${PWD}/organizations/peerOrganizations/propertytrust.example.com/users/Admin@propertytrust.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/propertytrust/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/propertytrust.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/propertytrust.example.com/users/Admin@propertytrust.example.com/msp/config.yaml"
}

function createLandregistry() {
  echo "Enrolling the CA admin for the landregistry"
  mkdir -p organizations/peerOrganizations/landregistry.example.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/landregistry.example.com/

  # Enroll the landregistry CA admin using the correct port and CA details
  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:9054 --caname ca-landregistry --tls.certfiles "${PWD}/organizations/fabric-ca/landregistry/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-landregistry.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-landregistry.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-landregistry.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-landregistry.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/landregistry.example.com/msp/config.yaml"

  # Copy the landregistry CA cert to its /msp/tlscacerts directory
  mkdir -p "${PWD}/organizations/peerOrganizations/landregistry.example.com/msp/tlscacerts"
  cp "${PWD}/organizations/fabric-ca/landregistry/ca-cert.pem" "${PWD}/organizations/peerOrganizations/landregistry.example.com/msp/tlscacerts/ca.crt"

  # Copy landregistry CA cert to its /tlsca directory (for clients)
  mkdir -p "${PWD}/organizations/peerOrganizations/landregistry.example.com/tlsca"
  cp "${PWD}/organizations/fabric-ca/landregistry/ca-cert.pem" "${PWD}/organizations/peerOrganizations/landregistry.example.com/tlsca/tlsca.landregistry.example.com-cert.pem"

  # Copy landregistry CA cert to its /ca directory (for clients)
  mkdir -p "${PWD}/organizations/peerOrganizations/landregistry.example.com/ca"
  cp "${PWD}/organizations/fabric-ca/landregistry/ca-cert.pem" "${PWD}/organizations/peerOrganizations/landregistry.example.com/ca/ca.landregistry.example.com-cert.pem"

  echo "Registering peer0 for the landregistry"
  set -x
  fabric-ca-client register --caname ca-landregistry --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/landregistry/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Registering user for the landregistry"
  set -x
  fabric-ca-client register --caname ca-landregistry --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/landregistry/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Registering the landregistry admin"
  set -x
  fabric-ca-client register --caname ca-landregistry --id.name landregistryadmin --id.secret landregistryadminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/landregistry/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Generating the peer0 MSP for the landregistry"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:9054 --caname ca-landregistry -M "${PWD}/organizations/peerOrganizations/landregistry.example.com/peers/peer0.landregistry.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/landregistry/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/landregistry.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/landregistry.example.com/peers/peer0.landregistry.example.com/msp/config.yaml"

  echo "Generating the peer0-tls certificates for the landregistry"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:9054 --caname ca-landregistry -M "${PWD}/organizations/peerOrganizations/landregistry.example.com/peers/peer0.landregistry.example.com/tls" --enrollment.profile tls --csr.hosts peer0.landregistry.example.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/landregistry/ca-cert.pem"
  { set +x; } 2>/dev/null

  # Copy TLS certificates for peer0 to correct locations
  cp "${PWD}/organizations/peerOrganizations/landregistry.example.com/peers/peer0.landregistry.example.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/landregistry.example.com/peers/peer0.landregistry.example.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/landregistry.example.com/peers/peer0.landregistry.example.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/landregistry.example.com/peers/peer0.landregistry.example.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/landregistry.example.com/peers/peer0.landregistry.example.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/landregistry.example.com/peers/peer0.landregistry.example.com/tls/server.key"

  echo "Generating the user MSP for the landregistry"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:9054 --caname ca-landregistry -M "${PWD}/organizations/peerOrganizations/landregistry.example.com/users/User1@landregistry.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/landregistry/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/landregistry.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/landregistry.example.com/users/User1@landregistry.example.com/msp/config.yaml"

  echo "Generating the landregistry admin MSP"
  set -x
  fabric-ca-client enroll -u https://landregistryadmin:landregistryadminpw@localhost:9054 --caname ca-landregistry -M "${PWD}/organizations/peerOrganizations/landregistry.example.com/users/Admin@landregistry.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/landregistry/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/landregistry.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/landregistry.example.com/users/Admin@landregistry.example.com/msp/config.yaml"
}

function createOrderer() {
  echo "Enrolling the CA admin for Orderer"
  mkdir -p organizations/ordererOrganizations/example.com

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/ordererOrganizations/example.com

  # Enroll the CA admin for the orderer using the correct port (9064)
  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:9064 --caname ca-orderer --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-9064-ca-orderer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-9064-ca-orderer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-9064-ca-orderer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-9064-ca-orderer.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/ordererOrganizations/example.com/msp/config.yaml"

  # Copy CA certs for the Orderer
  mkdir -p "${PWD}/organizations/ordererOrganizations/example.com/msp/tlscacerts"
  cp "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem" "${PWD}/organizations/ordererOrganizations/example.com/msp/tlscacerts/tlsca.example.com-cert.pem"

  # Copy CA certs to /tlsca directory for Orderer org
  mkdir -p "${PWD}/organizations/ordererOrganizations/example.com/tlsca"
  cp "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem" "${PWD}/organizations/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem"

  echo "Registering orderer"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name orderer --id.secret ordererpw --id.type orderer --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Registering the orderer admin"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name ordererAdmin --id.secret ordererAdminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Generating the orderer msp"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9064 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/ordererOrganizations/example.com/msp/config.yaml" "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/config.yaml"

  echo "Generating the orderer-tls certificates, use --csr.hosts to specify Subject Alternative Names"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9064 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls" --enrollment.profile tls --csr.hosts orderer.example.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  # Copy the TLS CA cert, server cert, server keystore
  cp "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/"* "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt"
  cp "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/signcerts/"* "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.crt"
  cp "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/keystore/"* "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.key"

  # Copy the TLS CA cert to the orderer's MSP directory for MSP definition
  mkdir -p "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts"
  cp "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/"* "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem"

  echo "Generating the admin msp"
  set -x
  fabric-ca-client enroll -u https://ordererAdmin:ordererAdminpw@localhost:9064 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/example.com/users/Admin@example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/ordererOrganizations/example.com/msp/config.yaml" "${PWD}/organizations/ordererOrganizations/example.com/users/Admin@example.com/msp/config.yaml"
}


createRealestatecorp
createPropertytrust
createLandregistry
createOrderer