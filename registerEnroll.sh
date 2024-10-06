#!/bin/bash

function createRealEstateCorp() {
  echo "Enrolling the CA admin for RealEstateCorp"
  mkdir -p organizations/peerOrganizations/realestatecorp.example.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/realestatecorp.example.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:7054 --caname ca-realestatecorp --tls.certfiles "${PWD}/organizations/fabric-ca/realestatecorp/ca-cert.pem"
  { set +x; } 2>/dev/null

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

  mkdir -p "${PWD}/organizations/peerOrganizations/realestatecorp.example.com/msp/tlscacerts"
  cp "${PWD}/organizations/fabric-ca/realestatecorp/ca-cert.pem" "${PWD}/organizations/peerOrganizations/realestatecorp.example.com/msp/tlscacerts/ca.crt"

  mkdir -p "${PWD}/organizations/peerOrganizations/realestatecorp.example.com/tlsca"
  cp "${PWD}/organizations/fabric-ca/realestatecorp/ca-cert.pem" "${PWD}/organizations/peerOrganizations/realestatecorp.example.com/tlsca/tlsca.realestatecorp.example.com-cert.pem"

  mkdir -p "${PWD}/organizations/peerOrganizations/realestatecorp.example.com/ca"
  cp "${PWD}/organizations/fabric-ca/realestatecorp/ca-cert.pem" "${PWD}/organizations/peerOrganizations/realestatecorp.example.com/ca/ca.realestatecorp.example.com-cert.pem"

  echo "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-realestatecorp --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/realestatecorp/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Registering user"
  set -x
  fabric-ca-client register --caname ca-realestatecorp --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/realestatecorp/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-realestatecorp --id.name realestatecorpadmin --id.secret realestatecorpadminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/realestatecorp/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Generating the peer0 MSP"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-realestatecorp -M "${PWD}/organizations/peerOrganizations/realestatecorp.example.com/peers/peer0.realestatecorp.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/realestatecorp/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/realestatecorp.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/realestatecorp.example.com/peers/peer0.realestatecorp.example.com/msp/config.yaml"

  echo "Generating the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-realestatecorp -M "${PWD}/organizations/peerOrganizations/realestatecorp.example.com/peers/peer0.realestatecorp.example.com/tls" --enrollment.profile tls --csr.hosts peer0.realestatecorp.example.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/realestatecorp/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/realestatecorp.example.com/peers/peer0.realestatecorp.example.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/realestatecorp.example.com/peers/peer0.realestatecorp.example.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/realestatecorp.example.com/peers/peer0.realestatecorp.example.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/realestatecorp.example.com/peers/peer0.realestatecorp.example.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/realestatecorp.example.com/peers/peer0.realestatecorp.example.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/realestatecorp.example.com/peers/peer0.realestatecorp.example.com/tls/server.key"

  echo "Generating the user MSP"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:7054 --caname ca-realestatecorp -M "${PWD}/organizations/peerOrganizations/realestatecorp.example.com/users/User1@realestatecorp.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/realestatecorp/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/realestatecorp.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/realestatecorp.example.com/users/User1@realestatecorp.example.com/msp/config.yaml"

  echo "Generating the admin MSP"
  set -x
  fabric-ca-client enroll -u https://realestatecorpadmin:realestatecorpadminpw@localhost:7054 --caname ca-realestatecorp -M "${PWD}/organizations/peerOrganizations/realestatecorp.example.com/users/Admin@realestatecorp.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/realestatecorp/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/realestatecorp.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/realestatecorp.example.com/users/Admin@realestatecorp.example.com/msp/config.yaml"
}

function createPropertyTrust() {
  echo "Enrolling the CA admin for PropertyTrust"
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

  mkdir -p "${PWD}/organizations/peerOrganizations/propertytrust.example.com/msp/tlscacerts"
  cp "${PWD}/organizations/fabric-ca/propertytrust/ca-cert.pem" "${PWD}/organizations/peerOrganizations/propertytrust.example.com/msp/tlscacerts/ca.crt"

  mkdir -p "${PWD}/organizations/peerOrganizations/propertytrust.example.com/tlsca"
  cp "${PWD}/organizations/fabric-ca/propertytrust/ca-cert.pem" "${PWD}/organizations/peerOrganizations/propertytrust.example.com/tlsca/tlsca.propertytrust.example.com-cert.pem"

  mkdir -p "${PWD}/organizations/peerOrganizations/propertytrust.example.com/ca"
  cp "${PWD}/organizations/fabric-ca/propertytrust/ca-cert.pem" "${PWD}/organizations/peerOrganizations/propertytrust.example.com/ca/ca.propertytrust.example.com-cert.pem"

  echo "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-propertytrust --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/propertytrust/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Registering user"
  set -x
  fabric-ca-client register --caname ca-propertytrust --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/propertytrust/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-propertytrust --id.name propertytrustadmin --id.secret propertytrustadminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/propertytrust/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Generating the peer0 MSP"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-propertytrust -M "${PWD}/organizations/peerOrganizations/propertytrust.example.com/peers/peer0.propertytrust.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/propertytrust/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/propertytrust.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/propertytrust.example.com/peers/peer0.propertytrust.example.com/msp/config.yaml"

  echo "Generating the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-propertytrust -M "${PWD}/organizations/peerOrganizations/propertytrust.example.com/peers/peer0.propertytrust.example.com/tls" --enrollment.profile tls --csr.hosts peer0.propertytrust.example.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/propertytrust/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/propertytrust.example.com/peers/peer0.propertytrust.example.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/propertytrust.example.com/peers/peer0.propertytrust.example.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/propertytrust.example.com/peers/peer0.propertytrust.example.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/propertytrust.example.com/peers/peer0.propertytrust.example.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/propertytrust.example.com/peers/peer0.propertytrust.example.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/propertytrust.example.com/peers/peer0.propertytrust.example.com/tls/server.key"

  echo "Generating the user MSP"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:8054 --caname ca-propertytrust -M "${PWD}/organizations/peerOrganizations/propertytrust.example.com/users/User1@propertytrust.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/propertytrust/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/propertytrust.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/propertytrust.example.com/users/User1@propertytrust.example.com/msp/config.yaml"

  echo "Generating the admin MSP"
  set -x
  fabric-ca-client enroll -u https://propertytrustadmin:propertytrustadminpw@localhost:8054 --caname ca-propertytrust -M "${PWD}/organizations/peerOrganizations/propertytrust.example.com/users/Admin@propertytrust.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/propertytrust/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/propertytrust.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/propertytrust.example.com/users/Admin@propertytrust.example.com/msp/config.yaml"
}

function createLandRegistry() {
  echo "Enrolling the CA admin for LandRegistry"
  mkdir -p organizations/peerOrganizations/landregistry.example.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/landregistry.example.com/

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

  mkdir -p "${PWD}/organizations/peerOrganizations/landregistry.example.com/msp/tlscacerts"
  cp "${PWD}/organizations/fabric-ca/landregistry/ca-cert.pem" "${PWD}/organizations/peerOrganizations/landregistry.example.com/msp/tlscacerts/ca.crt"

  mkdir -p "${PWD}/organizations/peerOrganizations/landregistry.example.com/tlsca"
  cp "${PWD}/organizations/fabric-ca/landregistry/ca-cert.pem" "${PWD}/organizations/peerOrganizations/landregistry.example.com/tlsca/tlsca.landregistry.example.com-cert.pem"

  mkdir -p "${PWD}/organizations/peerOrganizations/landregistry.example.com/ca"
  cp "${PWD}/organizations/fabric-ca/landregistry/ca-cert.pem" "${PWD}/organizations/peerOrganizations/landregistry.example.com/ca/ca.landregistry.example.com-cert.pem"

  echo "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-landregistry --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/landregistry/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Registering user"
  set -x
  fabric-ca-client register --caname ca-landregistry --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/landregistry/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-landregistry --id.name landregistryadmin --id.secret landregistryadminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/landregistry/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Generating the peer0 MSP"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:9054 --caname ca-landregistry -M "${PWD}/organizations/peerOrganizations/landregistry.example.com/peers/peer0.landregistry.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/landregistry/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/landregistry.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/landregistry.example.com/peers/peer0.landregistry.example.com/msp/config.yaml"

  echo "Generating the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:9054 --caname ca-landregistry -M "${PWD}/organizations/peerOrganizations/landregistry.example.com/peers/peer0.landregistry.example.com/tls" --enrollment.profile tls --csr.hosts peer0.landregistry.example.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/landregistry/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/landregistry.example.com/peers/peer0.landregistry.example.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/landregistry.example.com/peers/peer0.landregistry.example.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/landregistry.example.com/peers/peer0.landregistry.example.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/landregistry.example.com/peers/peer0.landregistry.example.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/landregistry.example.com/peers/peer0.landregistry.example.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/landregistry.example.com/peers/peer0.landregistry.example.com/tls/server.key"

  echo "Generating the user MSP"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:9054 --caname ca-landregistry -M "${PWD}/organizations/peerOrganizations/landregistry.example.com/users/User1@landregistry.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/landregistry/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/landregistry.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/landregistry.example.com/users/User1@landregistry.example.com/msp/config.yaml"

  echo "Generating the admin MSP"
  set -x
  fabric-ca-client enroll -u https://landregistryadmin:landregistryadminpw@localhost:9054 --caname ca-landregistry -M "${PWD}/organizations/peerOrganizations/landregistry.example.com/users/Admin@landregistry.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/landregistry/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/landregistry.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/landregistry.example.com/users/Admin@landregistry.example.com/msp/config.yaml"
}

function createOrderer() {
  echo "Enrolling the CA admin for the Orderer"
  mkdir -p organizations/ordererOrganizations/example.com

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/ordererOrganizations/example.com

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:10054 --caname ca-orderer --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-10054-ca-orderer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-10054-ca-orderer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-10054-ca-orderer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-10054-ca-orderer.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/ordererOrganizations/example.com/msp/config.yaml"

  mkdir -p "${PWD}/organizations/ordererOrganizations/example.com/msp/tlscacerts"
  cp "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem" "${PWD}/organizations/ordererOrganizations/example.com/msp/tlscacerts/ca.crt"

  mkdir -p "${PWD}/organizations/ordererOrganizations/example.com/tlsca"
  cp "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem" "${PWD}/organizations/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem"

  mkdir -p "${PWD}/organizations/ordererOrganizations/example.com/ca"
  cp "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem" "${PWD}/organizations/ordererOrganizations/example.com/ca/ca.example.com-cert.pem"

  echo "Registering the orderer"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name orderer --id.secret ordererpw --id.type orderer --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Registering the orderer admin"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name ordererAdmin --id.secret ordererAdminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Generating the orderer MSP"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:10054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp" --csr.hosts orderer.example.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/ordererOrganizations/example.com/msp/config.yaml" "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/config.yaml"

  echo "Generating the orderer TLS certificates"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:10054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls" --enrollment.profile tls --csr.hosts orderer.example.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
 { set +x; } 2>/dev/null

  cp "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/"* "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt"
  cp "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/signcerts/"* "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.crt"
  cp "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/keystore/"* "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.key"

  echo "Generating the admin MSP"
  set -x
  fabric-ca-client enroll -u https://ordererAdmin:ordererAdminpw@localhost:10054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/example.com/users/Admin@example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/ordererOrganizations/example.com/msp/config.yaml" "${PWD}/organizations/ordererOrganizations/example.com/users/Admin@example.com/msp/config.yaml"
}

createRealEstateCorp
createPropertyTrust
createLandRegistry
createOrderer