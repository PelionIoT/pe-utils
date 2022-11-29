#!/usr/bin/env bash
#
# Copyright (c) 2022 Izuma Networks
#
# Please run this script while being in the same folder as the script
# ./testnet.sh
#
# Credential files will not be found otherwise.
#
temp=$(mktemp -d /tmp/IzumaNetTest-XXXXX)
bootT=$temp/bootstrap.txt
LWT=$temp/test-lwm2m.txt
L3T=$temp/layer3.txt
L4T=$temp/layer4.txt

VERBOSE=0
DONTDELETE=0

port=5684
NORM="\u001b[0m"
#BOLD="\u001b[1m"
#REV="\u001b[7m"
#UND="\u001b[4m"
#BLACK="\u001b[30m"
RED="\u001b[31m"
GREEN="\u001b[32m"
YELLOW="\u001b[33m"
#BLUE="\u001b[34m"
#MAGENTA="\u001b[35m"
#MAGENTA1="\u001b[35m"
#MAGENTA2="\u001b[35m"
#MAGENTA3="\u001b[35m"
#CYAN="\u001b[36m"
#WHITE="\u001b[37m"
#ORANGE="$YELLOW"
#ERROR="${REV}Error:${NORM}"

clihelp::success() {
    echo -e "[${GREEN}   OK   ${NORM}]\t$1"
}
clihelp::failure() {
    echo -e "[${RED} FAILED ${NORM}]\t$1"
}
clihelp::warning() {
    echo -e "[${YELLOW}  WARN   ${NORM}]\t$1"
}

verbose() {
    if [[ $VERBOSE -eq 1 ]]; then
        echo "$1"
    fi
}

test_bootstrap() {
    verbose "Test bootstrap server connection (port $port)"
    verbose "--------------------------------------------"
    verbose "Uses openssl to connect to bootstrap server using device credentials."
    verbose "Write openssl output to $bootT."
    echo | openssl s_client -CAfile credentials/bootstrap.pem -key credentials/device01_key.pem -cert credentials/device01_cert.pem -connect tcp-bootstrap.us-east-1.mbedcloud.com:5684 2>"$bootT" >"$bootT"

    # get openssl return code
    RESULT=$(grep 'Verify return code' "$bootT")
    if [ -z "$RESULT" ]; then
        clihelp::failure "openssl failed with: $(cat "$bootT")"
    fi
    # print result
    CODE=$(echo "$RESULT" | awk -F' ' '{print $4}')
    if [ "$CODE" = 0 ]; then
        clihelp::success "TLS to bootstrap server (port $port)"
    else
        clihelp::failure "TLS to bootstrap server (port $port)"
        echo "--------------"
        echo "$RESULT"
        echo "--------------"
    fi
}

test_lwm2m() {
    verbose "Test LwM2M server connection (port $port)"
    verbose "----------------------------------------"
    verbose "Uses openssl to connect to LwM2M server using device credentials."
    verbose "Write openssl output to $LWT."
    echo | openssl s_client -CAfile credentials/lwm2m.pem -key credentials/device01_key.pem -cert credentials/device01_cert.pem -connect lwm2m.us-east-1.mbedcloud.com:"$port" 2>"$LWT" >"$LWT"
    # get openssl return code
    RESULT=$(grep "Verify return code" "$LWT")

    if [ -z "$RESULT" ]; then
        clihelp::failure "openssl failed with: $(cat "$LWT")"
        exit
    fi
    # print result
    CODE=$(echo "$RESULT" | awk -F' ' '{print $4}')

    if [ "$CODE" = 0 ]; then
        clihelp::success "TLS to LwM2M server (port $port)"
    else
        clihelp::failure "TLS to LwM2M server (port $port)"
        echo "--------------"
        echo "$RESULT"
        echo "--------------"
    fi
}

test_L3() {
    _url() {
        if [[ $(ping -q -c 1 "$1" >>"$L3T" 2>&1) -eq 0 ]]; then
            clihelp::success "ping $1"
        else
            clihelp::failure "ping $1"
        fi
    }
    verbose "Test Layer 3 (requires icmp ping)"
    verbose "---------------------------------"
    _url api.snapcraft.io
    _url lwm2m.us-east-1.mbedcloud.com
}

test_L4() {
    _nc() {
        if [[ $(nc -v -w 1 "$1" "$2" >>"$L4T" 2>&1) -eq 0 ]]; then
            clihelp::success "netcat $1 $2"
        else
            clihelp::failure "netcat $1 $2"
        fi
    }
    verbose "Test Layer 4 (requires nc), port 443 and 5684"
    verbose "---------------------------------------------"
    _nc api.snapcraft.io 443
    _nc bootstrap.us-east-1.mbedcloud.com 443
    _nc bootstrap.us-east-1.mbedcloud.com 5684
    _nc lwm2m.us-east-1.mbedcloud.com 443
    _nc lwm2m.us-east-1.mbedcloud.com 5684
}

main() {
    test_L3
    test_L4
    test_bootstrap
    test_lwm2m
    port=443
    test_bootstrap
    test_lwm2m
    if [[ "$DONTDELETE" -eq 0 ]]; then
        rm -rf "$temp"
    else
        echo "Your files are preserved at $temp"
    fi
}

displayHelp() {
    echo "Usage: $0 -options"
    echo "  -d do not delete temporary storage"
    echo "  -v verbose output"
    exit
}

argprocessor() {
    while getopts "hHdv" optsin; do
        case "${optsin}" in
            #
            d) DONTDELETE=1 ;;
            #
            h) displayHelp ;;
            #
            H) displayHelp ;;
            #
            v) VERBOSE=1 ;;
            #
            \?)
                echo -e "Option -$OPTARG not allowed.\n "
                displayHelp
                ;;
                #
        esac
    done
    shift $((OPTIND - 1))
    if [[ $# -ne 0 ]]; then
        displayHelp
    else
        shift
        main "$@"
    fi
}
argprocessor "$@"
