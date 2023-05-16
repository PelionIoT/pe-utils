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

cli_log() {
    script_name=${0##*/}
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    echo "$timestamp $script_name LOG $1"
}

cli_error() {
    script_name=${0##*/}
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    echo "$timestamp $script_name ERROR $1"
}

cli_warn() {
    script_name=${0##*/}
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    echo "$timestamp $script_name WARN $1"
}

cli_debug() {
    if [ -n "$VERBOSE" ]; then
        script_name=${0##*/}
        timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
        echo "$timestamp $script_name DEBUG $1"
    fi
}

HW_VERSION="unknown"
[ -f /proc/device-tree/model ] && HW_VERSION=$(sed 's/ /_/g' <<< $(tr -d '\0' </proc/device-tree/model))

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
    -m <common_address>           part of the cloud address common to all domains
    -c <container_url>            containers api address (default: 'https://containers.us-east-1.mbedcloud.com')
    -g <gw_server_url>            gateway services api address (default: 'https://gateways.us-east-1.mbedcloud.com')
    -k <k8s_server_url>.          edge kubernetes server address (default: 'https://edge-k8s.us-east-1.mbedcloud.com')
    -e <serial_number>            [optional] gateway serial number (default: autogenerate a random serial number)
    -n <account_id>               account identifier (mandatory)
    -o <output_directory>         output directory of identity.json (default: './')
    -i <device_id>                edge-core's internal-id (mandatory)
    -w <hw_type>                  hardware version of the gateway, refer configurations section in
                                  $DEVID_CLI_DIR/radioProfile.template.json#L228 (default: '$HW_VERSION')
    -r <radio_config>             radio configuration of the gateway, refer configurations section in
                                  $DEVID_CLI_DIR/radioProfile.template.json#L228 (default: '00')
    -l <led_config>               status led configuration of the gateway (default: '01')

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
            COMMON_ADDR=".us-east-1.mbedcloud.com"
            RADIO_CONFIG="00"
            LED_CONFIG="01"
            OUTPUT_DIR="./"
            GW_URL="https://gateways.us-east-1.mbedcloud.com"
            k8s_URL="https://edge-k8s.us-east-1.mbedcloud.com"
            containers_URL="https://containers.us-east-1.mbedcloud.com"
            ;;
        m)
            COMMON_ADDR="$OPTARG"
            GW_URL="https://gateways${COMMON_ADDR}"
            k8s_URL="https://edge-k8s${COMMON_ADDR}"
            containers_URL="https://containers${COMMON_ADDR}"
            ;;
        c)
            containers_URL="$OPTARG"
            ;;
        g)
            GW_URL="$OPTARG"
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
    \"containerServicesAddress\": \"$containers_URL\"
}" > $OUTPUT_DIR/identity.json

cli_debug "$(cat $OUTPUT_DIR/identity.json)"
cli_log 'Successfully generated identity.json'