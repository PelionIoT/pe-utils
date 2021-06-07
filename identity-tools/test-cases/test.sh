#!/bin/bash

set -e

PROD_EDGE_CORE_STATUS="{\"account-id\":\"016aa245a97c6a01c5a5670000000000\",\"edge-version\":\"0.12.0-master-c9d27309567c415d362f25f479f5cc3fc0c1eb15-dirty\",\"endpoint-name\":\"TEST01\",\"internal-id\":\"01749a73670300000000000100185c56\",\"lwm2m-server-uri\":\"coaps://lwm2m.us-east-1.mbedcloud.com:5684?aid=016aa245a97c6a01c5a5670000000000&iep=01749a73670300000000000100185c56\",\"status\":\"connected\"}"
OS2_EDGE_CORE_STATUS="{\"account-id\":\"0171baf5cb4ea2135a6fe01900000000\",\"edge-version\":\"0.13.0-HEAD-66d1e04cb4f847c4c7f69c200d26a87aa541dc94-dirty\",\"endpoint-name\":\"TEST02\",\"internal-id\":\"0174c1aa7eba000000000001001b959a\",\"lwm2m-server-uri\":\"coaps://lwm2m-os2.mbedcloudstaging.net:5684?aid=0171baf5cb4ea2135a6fe01900000000&iep=0174c1aa7eba000000000001001b959a\",\"status\":\"connected\"}"
INT_EDGE_CORE_STATUS="{\"account-id\":\"0171baf5cb4ea2135a6fe01900000000\",\"edge-version\":\"0.13.0-HEAD-66d1e04cb4f847c4c7f69c200d26a87aa541dc94-dirty\",\"endpoint-name\":\"TEST03\",\"internal-id\":\"0174c1aa7eba000000000001001b95ba\",\"lwm2m-server-uri\":\"coaps://lwm2m-integration-lab.mbedcloudintegration.net:5684?aid=0171baf5cb4ea2135a6fe01900000000&iep=0174c1aa7eba000000000001001b95ba\",\"status\":\"connected\"}"

echo "Testing generating identity for US PROD instance..."
./../generate-identity.sh 0 . $PROD_EDGE_CORE_STATUS
s=$?
[ "$s" != 0 ] && echo "Failed to generate PROD lab identity.json" && exit 1
cat ./identity.json
# inspect the identity file
[[ -z "$(cat ./identity.json | jq '.serialNumber')" ]] && echo "US_PROD - serialNumber is empty. Failed!" && exit 1
[[ -z "$(cat ./identity.json | jq '.OU')" ]] && echo "US_PROD - OU is empty. Failed!" && exit 1
[[ -z "$(cat ./identity.json | jq '.deviceID')" ]] && echo "US_PROD - deviceID is empty. Failed!" && exit 1
[[ "$(cat ./identity.json | jq '.gatewayServicesAddress')" != "\"https://gateways.us-east-1.mbedcloud.com\"" ]] && echo "US_PROD - Incorrect gatewayServicesAddress. Failed!" && exit 1
[[ "$(cat ./identity.json | jq '.edgek8sServicesAddress')" != "\"https://edge-k8s.us-east-1.mbedcloud.com\"" ]] && echo "US_PROD - Incorrect edgek8sServicesAddress. Failed!" && exit 1
[[ "$(cat ./identity.json | jq '.containerServicesAddress')" != "\"https://containers.us-east-1.mbedcloud.com\"" ]] && echo "US_PROD - Incorrect containerServicesAddress. Failed!" && exit 1
echo "Success"
rm -rf identity*

echo ""
echo "Testing generating identity for OS2 instance..."
./../generate-identity.sh 0 . $OS2_EDGE_CORE_STATUS
s=$?
[ "$s" != 0 ] && echo "Failed to generate OS2 lab identity.json" && exit 1
cat ./identity.json
# inspect the identity file
[[ -z "$(cat ./identity.json | jq '.serialNumber')" ]] && echo "OS2 - serialNumber is empty. Failed!" && exit 1
[[ -z "$(cat ./identity.json | jq '.OU')" ]] && echo "OS2 - OU is empty. Failed!" && exit 1
[[ -z "$(cat ./identity.json | jq '.deviceID')" ]] && echo "OS2 - deviceID is empty. Failed!" && exit 1
[[ "$(cat ./identity.json | jq '.gatewayServicesAddress')" != "\"https://gateways.mbedcloudstaging.net\"" ]] && echo "OS2 - Incorrect gatewayServicesAddress. Failed!" && exit 1
[[ "$(cat ./identity.json | jq '.edgek8sServicesAddress')" != "\"https://edge-k8s.mbedcloudstaging.net\"" ]] && echo "OS2 - Incorrect edgek8sServicesAddress. Failed!" && exit 1
[[ "$(cat ./identity.json | jq '.containerServicesAddress')" != "\"https://containers.mbedcloudstaging.net\"" ]] && echo "OS2 - Incorrect containerServicesAddress. Failed!" && exit 1
echo "Success"
rm -rf identity*

echo ""
echo "Testing generating identity for INT instance..."
./../generate-identity.sh 0 . $INT_EDGE_CORE_STATUS
s=$?
[ "$s" != 0 ] && echo "Failed to generate INT lab identity.json" && exit 1
cat ./identity.json
# inspect the identity file
[[ -z "$(cat ./identity.json | jq '.serialNumber')" ]] && echo "INT - serialNumber is empty. Failed!" && exit 1
[[ -z "$(cat ./identity.json | jq '.OU')" ]] && echo "INT - OU is empty. Failed!" && exit 1
[[ -z "$(cat ./identity.json | jq '.deviceID')" ]] && echo "INT - deviceID is empty. Failed!" && exit 1
[[ "$(cat ./identity.json | jq '.gatewayServicesAddress')" != "\"https://gateways.mbedcloudintegration.net\"" ]] && echo "INT - Incorrect gatewayServicesAddress. Failed!" && exit 1
[[ "$(cat ./identity.json | jq '.edgek8sServicesAddress')" != "\"https://edge-k8s.mbedcloudintegration.net\"" ]] && echo "INT - Incorrect edgek8sServicesAddress. Failed!" && exit 1
[[ "$(cat ./identity.json | jq '.containerServicesAddress')" != "\"https://containers.mbedcloudintegration.net\"" ]] && echo "INT - Incorrect containerServicesAddress. Failed!" && exit 1
echo "Success"
rm -rf identity*