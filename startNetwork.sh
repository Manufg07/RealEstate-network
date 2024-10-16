#!/bin/bash

echo "------------Register the CA admin for each organization-------------"

docker compose -f docker/docker-compose-ca.yaml up -d
sleep 3
sudo chmod -R 777 organizations/

echo "------------Register and enroll the users for each organization-------------"

chmod +x registerEnroll.sh
./registerEnroll.sh
sleep 3

echo "-------------Build the infrastructure-------------"

docker compose -f docker/docker-compose-3org.yaml up -d
sleep 3

echo "-------------Generate the genesis block-------------"

export FABRIC_CFG_PATH=${PWD}/config
export CHANNEL_NAME=realestatecorp

configtxgen -profile ChannelUsingRaft -outputBlock ${PWD}/channel-artifacts/${CHANNEL_NAME}.block -channelID $CHANNEL_NAME

echo "------ Create the application channel------"

export ORDERER_CA=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
export ORDERER_ADMIN_TLS_SIGN_CERT=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.crt
export ORDERER_ADMIN_TLS_PRIVATE_KEY=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.key

osnadmin channel join --channelID $CHANNEL_NAME --config-block ${PWD}/channel-artifacts/$CHANNEL_NAME.block -o localhost:7053 --ca-file $ORDERER_CA --client-cert $ORDERER_ADMIN_TLS_SIGN_CERT --client-key $ORDERER_ADMIN_TLS_PRIVATE_KEY
sleep 2
osnadmin channel list -o localhost:7053 --ca-file $ORDERER_CA --client-cert $ORDERER_ADMIN_TLS_SIGN_CERT --client-key $ORDERER_ADMIN_TLS_PRIVATE_KEY
sleep 2

# Org1: Realestate
echo "-------------Join Org1 (Realestate) peer to the channel-------------"

export FABRIC_CFG_PATH=${PWD}/peercfg
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID=realestatecorpMSP
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/realestatecorp.example.com/peers/peer0.realestatecorp.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/realestatecorp.example.com/users/Admin@realestatecorp.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051

peer channel join -b ${PWD}/channel-artifacts/${CHANNEL_NAME}.block
sleep 3
peer channel list

# Org1 Anchor Peer Update
echo "-------------Org1 (realestatecorp) Anchor Peer Update-------------"

peer channel fetch config ${PWD}/channel-artifacts/config_block.pb -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com -c $CHANNEL_NAME --tls --cafile $ORDERER_CA
cd channel-artifacts

configtxlator proto_decode --input config_block.pb --type common.Block --output config_block.json
jq '.data.data[0].payload.data.config' config_block.json > config.json

cp config.json config_copy.json
jq '.channel_group.groups.Application.groups.realestateMSP.values += {"AnchorPeers":{"mod_policy": "Admins","value":{"anchor_peers": [{"host": "peer0.realestatecorp.example.com","port": 7051}]},"version": "0"}}' config_copy.json > modified_config.json

configtxlator proto_encode --input config.json --type common.Config --output config.pb
configtxlator proto_encode --input modified_config.json --type common.Config --output modified_config.pb
configtxlator compute_update --channel_id ${CHANNEL_NAME} --original config.pb --updated modified_config.pb --output config_update.pb

configtxlator proto_decode --input config_update.pb --type common.ConfigUpdate --output config_update.json
echo '{"payload":{"header":{"channel_header":{"channel_id":"'$CHANNEL_NAME'", "type":2}},"data":{"config_update":'$(cat config_update.json)'}}}' | jq . > config_update_in_envelope.json
configtxlator proto_encode --input config_update_in_envelope.json --type common.Envelope --output config_update_in_envelope.pb

cd ..
peer channel update -f ${PWD}/channel-artifacts/config_update_in_envelope.pb -c $CHANNEL_NAME -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile $ORDERER_CA
sleep 1

# Chaincode Packaging and Installation for Org1
echo "-------------Package and Install Chaincode for Org1-------------"

cp -r ../fabric-samples/asset-transfer-basic/chaincode-javascript ../Chaincode
peer lifecycle chaincode package basic.tar.gz --path ../Chaincode/chaincode-javascript/ --lang node --label basic_1.0

peer lifecycle chaincode install basic.tar.gz
sleep 3
peer lifecycle chaincode queryinstalled

export CC_PACKAGE_ID=$(peer lifecycle chaincode calculatepackageid basic.tar.gz)
peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID $CHANNEL_NAME --name basic --version 1.0 --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile $ORDERER_CA --waitForEvent
sleep 1

# Org2: Propertytrust
echo "-------------Join Org2 (Propertytrust) peer to the channel-------------"

export CORE_PEER_LOCALMSPID=propertytrustMSP
export CORE_PEER_ADDRESS=localhost:9051
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/propertytrust.example.com/peers/peer0.propertytrust.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/propertytrust.example.com/users/Admin@propertytrust.example.com/msp

peer channel join -b ${PWD}/channel-artifacts/$CHANNEL_NAME.block
sleep 1
peer channel list

# Org2 Anchor Peer Update
echo "-------------Org2 (propertytrust) Anchor Peer Update-------------"

peer channel fetch config ${PWD}/channel-artifacts/config_block.pb -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com -c $CHANNEL_NAME --tls --cafile $ORDERER_CA
cd channel-artifacts

configtxlator proto_decode --input config_block.pb --type common.Block --output config_block.json
jq '.data.data[0].payload.data.config' config_block.json > config.json

cp config.json config_copy.json
jq '.channel_group.groups.Application.groups.propertytrustMSP.values += {"AnchorPeers":{"mod_policy": "Admins","value":{"anchor_peers": [{"host": "peer0.propertytrust.example.com","port": 9051}]},"version": "0"}}' config_copy.json > modified_config.json

configtxlator proto_encode --input config.json --type common.Config --output config.pb
configtxlator proto_encode --input modified_config.json --type common.Config --output modified_config.pb
configtxlator compute_update --channel_id ${CHANNEL_NAME} --original config.pb --updated modified_config.pb --output config_update.pb

configtxlator proto_decode --input config_update.pb --type common.ConfigUpdate --output config_update.json
echo '{"payload":{"header":{"channel_header":{"channel_id":"'$CHANNEL_NAME'", "type":2}},"data":{"config_update":'$(cat config_update.json)'}}}' | jq . > config_update_in_envelope.json
configtxlator proto_encode --input config_update_in_envelope.json --type common.Envelope --output config_update_in_envelope.pb

cd ..
peer channel update -f ${PWD}/channel-artifacts/config_update_in_envelope.pb -c $CHANNEL_NAME -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile $ORDERER_CA
sleep 1

# Install and approve chaincode for Org2
peer lifecycle chaincode install basic.tar.gz
sleep 3
peer lifecycle chaincode queryinstalled
peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID $CHANNEL_NAME --name basic --version 1.0 --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile $ORDERER_CA --waitForEvent
sleep 1

# Org3: Landregistry
echo "-------------Join Org3 (Landregistry) peer to the channel-------------"

export CORE_PEER_LOCALMSPID=landregistryMSP
export CORE_PEER_ADDRESS=localhost:9052
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/landregistry.example.com/peers/peer0.landregistry.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/landregistry.example.com/users/Admin@landregistry.example.com/msp

peer channel join -b ${PWD}/channel-artifacts/$CHANNEL_NAME.block
sleep 1
peer channel list

# Org3 Anchor Peer Update
echo "-------------Org3 (landregistry) Anchor Peer Update-------------"

peer channel fetch config ${PWD}/channel-artifacts/config_block.pb -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com -c $CHANNEL_NAME --tls --cafile $ORDERER_CA
cd channel-artifacts

configtxlator proto_decode --input config_block.pb --type common.Block --output config_block.json
jq '.data.data[0].payload.data.config' config_block.json > config.json

cp config.json config_copy.json
jq '.channel_group.groups.Application.groups.landregistryMSP.values += {"AnchorPeers":{"mod_policy": "Admins","value":{"anchor_peers": [{"host": "peer0.landregistry.example.com","port": 9052}]},"version": "0"}}' config_copy.json > modified_config.json

configtxlator proto_encode --input config.json --type common.Config --output config.pb
configtxlator proto_encode --input modified_config.json --type common.Config --output modified_config.pb
configtxlator compute_update --channel_id ${CHANNEL_NAME} --original config.pb --updated modified_config.pb --output config_update.pb

configtxlator proto_decode --input config_update.pb --type common.ConfigUpdate --output config_update.json
echo '{"payload":{"header":{"channel_header":{"channel_id":"'$CHANNEL_NAME'", "type":2}},"data":{"config_update":'$(cat config_update.json)'}}}' | jq . > config_update_in_envelope.json
configtxlator proto_encode --input config_update_in_envelope.json --type common.Envelope --output config_update_in_envelope.pb

cd ..
peer channel update -f ${PWD}/channel-artifacts/config_update_in_envelope.pb -c $CHANNEL_NAME -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile $ORDERER_CA
sleep 1

# Install and approve chaincode in Org3
peer lifecycle chaincode install basic.tar.gz
sleep 3
peer lifecycle chaincode queryinstalled

peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID $CHANNEL_NAME --name basic --version 1.0 --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile $ORDERER_CA --waitForEvent
sleep 1

echo "-------------Commit the chaincode-------------"

peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID $CHANNEL_NAME --name basic --version 1.0 --sequence 1 --tls --cafile $ORDERER_CA --peerAddresses localhost:7051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/realestatecorp.example.com/peers/peer0.realestatecorp.example.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/propertytrust.example.com/peers/peer0.propertytrust.example.com/tls/ca.crt --peerAddresses localhost:9052 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/landregistry.example.com/peers/peer0.landregistry.example.com/tls/ca.crt
sleep 2

peer lifecycle chaincode querycommitted --channelID $CHANNEL_NAME --name basic --cafile $ORDERER_CA



#  export FABRIC_CFG_PATH=./peercfg
#  export CHANNEL_NAME=realestatecorp
#  export CORE_PEER_LOCALMSPID=realestatecorpMSP
#  export CORE_PEER_TLS_ENABLED=true
#  export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/realestatecorp.example.com/peers/peer0.realestatecorp.example.com/tls/ca.crt
#  export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/realestatecorp.example.com/users/Admin@realestatecorp.example.com/msp
#  export CORE_PEER_ADDRESS=localhost:7051
#  export ORDERER_CA=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
#  export ORG1_PEER_TLSROOTCERT=${PWD}/organizations/peerOrganizations/realestatecorp.example.com/peers/peer0.realestatecorp.example.com/tls/ca.crt
#  export ORG2_PEER_TLSROOTCERT=${PWD}/organizations/peerOrganizations/propertytrust.example.com/peers/peer0.propertytrust.example.com/tls/ca.crt

#  peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C realestatecorp -n basic --peerAddresses localhost:7051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/realestatecorp.example.com/peers/peer0.realestatecorp.example.com/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/propertytrust.example.com/peers/peer0.propertytrust.example.com/tls/ca.crt" -c '{"function":"InitLedger","Args":[]}'
#  peer chaincode query -C realestatecorp -n basic -c '{"function":"ReadAsset","Args":["asset5"]}'
