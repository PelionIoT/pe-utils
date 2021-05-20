#!/bin/bash

# Copyright (c) 2019, Arm Limited and affiliates.
# SPDX-License-Identifier: Apache-2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e

export DEVID_CLI_DIR=$(cd $(dirname $0) && pwd)
. "$DEVID_CLI_DIR/common.sh"

cli_help() {
  cli_name=${0##*/}
  echo "
  $cli_name - create pelion-edge developer identity
  Version: $(cat $DEVID_CLI_DIR/VERSION)
  Usage: $cli_name [options]

  Options:

    -h                            output usage information
    -v                            verbose logging
    -V                            output the version number
    -d                            generate identity using default values
    -m <lab_instance>             one of the following mbed-cloud lab instance (default: 'mbedcloud') -
                                  [ mbedcloudintegration,
                                    mbedcloudstaging,
                                    mbedcloud ]
    -c <lwm2m_coap_url>           lwm2m coap server address (default: 'coaps://lwm2m.us-east-1.mbedcloud.com')
    -g <gw_server_url>            gateway services api address (default: 'https://gateways.us-east-1.mbedcloud.com')
    -s <api_server_url>           api server address (default: 'https://api.us-east-1.mbedcloud.com')
    -k <k8s_server_url>.          edge kubernetes server address (default: 'https://edge-k8s.us-east-1.mbedcloud.com')
    -e <serial_number>            [optional] gateway serial number (default: autogenerate a random serial number)
    -n <account_id>               account identifier (mandatory)
    -o <output_directory>         output directory of identity.json (default: './')
    -i <device_id>                edge-core's internal-id (mandatory)
    -w <hw_type>                  hardware version of the gateway, refer configurations section in
                                  $DEVID_CLI_DIR/radioProfile.template.json#L228 (default: 'cat /proc/device-tree/model')
    -r <radio_config>             radio configuration of the gateway, refer configurations section in
                                  $DEVID_CLI_DIR/radioProfile.template.json#L228 (default: '00')
    -l <led_config>               status led configuration of the gateway (default: '01')
    -z <prod_region>              production cloud region

  Examples:

    Typical usage, use the default values to generate an identity file. This will create random uuids for deviceID and accountID.

        $cli_name -d

    Generate a default identity file but with integration lab cloud addresses

        $cli_name -d -m mbedcloudintegration

    Generate a default identity file but relace the hardware version and radio configuration to specified value

        $cli_name -d -w delledge3000 -r 01
"
}

[ ! -n "$1" ] && cli_help && exit 1
[ "$1" == "-v" ] && [ ! -n "$2" ] && cli_help && exit 1

OPTIND=1

HW_VERSION="unknown"
[ -f /proc/device-tree/model ] && HW_VERSION=$(sed 's/ /_/g' <<< $(tr -d '\0' </proc/device-tree/model))

while getopts 'hvVdm:c:g:s:k:e:n:o:i:w:r:l:z:' opt; do
    case "$opt" in
        h|-help)
            cli_help
            exit 0
            ;;
        v)
            VERBOSE=1
            ;;
        V)
            echo "$(cat $DEVID_CLI_DIR/VERSION)"
            exit 0
            ;;
        d)
            USE_DEFAULT=1
            CLOUD_LAB="mbedcloud"
            CLOUD_LAB_REGION="us-east-1"
            RADIO_CONFIG="00"
            LED_CONFIG="01"
            OUTPUT_DIR="./"
            LwM2M_URL="coaps://lwm2m.us-east-1.mbedcloud.com"
            API_URL="https://api.us-east-1.mbedcloud.com"
            GW_URL="https://gateways.us-east-1.mbedcloud.com"
            k8s_URL="https://edge-k8s.us-east-1.mbedcloud.com"
            containers_URL="https://containers.us-east-1.mbedcloud.com"
            ;;
        m)
            CLOUD_LAB="$OPTARG"
            case "$CLOUD_LAB" in
                mbedcloudintegration)
                    LwM2M_URL="coaps://lwm2m-integration-lab.mbedcloudintegration.net"
                    API_URL="https://lab-api.mbedcloudintegration.net"
                    GW_URL="https://gateways.mbedcloudintegration.net"
                    k8s_URL="https://edge-k8s.mbedcloudintegration.net"
                    containers_URL="https://containers.mbedcloudintegration.net"
                    ;;
                mbedcloudstaging)
                    LwM2M_URL="coaps://lwm2m-os2.mbedcloudstaging.net"
                    API_URL="https://api-os2.mbedcloudstaging.net"
                    GW_URL="https://gateways.mbedcloudstaging.net"
                    k8s_URL="https://edge-k8s.mbedcloudstaging.net"
                    containers_URL="https://containers.mbedcloudstaging.net"
                    ;;
                mbedcloud)
                    LwM2M_URL="coaps://lwm2m.$PROD_REGION.mbedcloud.com"
                    API_URL="https://api.$PROD_REGION.mbedcloud.com"
                    GW_URL="https://gateways.$PROD_REGION.mbedcloud.com"
                    k8s_URL="https://edge-k8s.$PROD_REGION.mbedcloud.com"
                    containers_URL="https://containers.$PROD_REGION.mbedcloud.com"
                    ;;
                *)
                    cli_error "Unknown mbed-cloud lab instance - $CLOUD_LAB. Check help for expected values."
                    exit 1
                    ;;
            esac
            ;;
        c)
            LwM2M_URL="$OPTARG"
            ;;
        g)
            GW_URL="$OPTARG"
            ;;
        s)
            API_URL="$OPTARG"
            ;;
        k)
            k8s_URL="$OPTARG"
            ;;
        e)
            SERIAL_NUMBER="$OPTARG"
            ;;
        n)
            ACCOUNT_ID="$OPTARG"
            ;;
        o)
            OUTPUT_DIR="$OPTARG"
            ;;
        i)
            DEVICE_ID="$OPTARG"
            ;;
        w)
            HW_VERSION="$OPTARG"
            ;;
        r)
            RADIO_CONFIG="$OPTARG"
            ;;
        l)
            LED_CONFIG="$OPTARG"
            ;;
        z)
            PROD_REGION="$OPTARG"
            ;;
        *)
            cli_help
            exit 1
            ;;
    esac
done

shift "$(($OPTIND-1))"

generate_random_hex_number() {
    hexchars="0123456789ABCDEF"
    local hex_rand=$( for ((i = 1; i <= $1; i++)) ; do echo -n ${hexchars:$(( $RANDOM % 16 )):1} ; done | sed -e 's/\(..\)/\1/g' )
    echo "$hex_rand"
}

if [ -z "$ACCOUNT_ID" ]; then
    cli_warn "-n <account_id> not specified! generating random uuid..."
    ACCOUNT_ID="$(generate_random_hex_number 32)"
fi

if [ -z "$DEVICE_ID" ]; then
    cli_warn "-i <device_id> not specified! generating random uuid..."
    DEVICE_ID="$(generate_random_hex_number 32)"
fi

MAC_INDEX_3="$((1 + RANDOM % 250))"
MAC_INDEX_4="$((1 + RANDOM % 250))"
MAC_INDEX_5="$((1 + RANDOM % 250))"

SERIAL_NUMBER_PREFIX="DEV0"
SN_POSTFIX="$(generate_random_hex_number 6)"
DEV_SERIAL_NUMBER=$SERIAL_NUMBER_PREFIX$SN_POSTFIX

[ -z $SERIAL_NUMBER ] && SERIAL_NUMBER=$DEV_SERIAL_NUMBER

echo "{
    \"serialNumber\": \"$SERIAL_NUMBER\",
    \"OU\": \"$ACCOUNT_ID\",
    \"deviceID\": \"$DEVICE_ID\",
    \"hardwareVersion\": \"$HW_VERSION\",
    \"radioConfig\": \"$RADIO_CONFIG\",
    \"ledConfig\": \"$LED_CONFIG\",
    \"category\": \"development\",
    \"ethernetMAC\": [
        0,
        165,
        9,
        $MAC_INDEX_3,
        $MAC_INDEX_4,
        $MAC_INDEX_5
    ],
    \"sixBMAC\": [
        0,
        165,
        9,
        0,
        1,
        $MAC_INDEX_3,
        $MAC_INDEX_4,
        $MAC_INDEX_5
    ],
    \"gatewayServicesAddress\": \"$GW_URL\",
    \"edgek8sServicesAddress\": \"$k8s_URL\",
    \"containerServicesAddress\": \"$containers_URL\",
    \"cloudAddress\": \"$API_URL\"
}" > $OUTPUT_DIR/identity.json

cli_debug "$(cat $OUTPUT_DIR/identity.json)"
cli_log 'Successfully generated identity.json'