## Izuma Edge utilities 2.3.7
1. [fw-tools] - add `|| true` to 1st `ping` test to avoid abrupt script execution stop if `ping` errors.

## Izuma Edge utilities 2.3.6
1. [fw-tools] - fix handling `-h` (help) option.
1. [fw-tools] - support for custom domains (`--domain`) added, options to skip https/port443 check (`--skip443`) and tcp-bootstrap ping (`--skiptcpping`).

## Izuma Edge utilities 2.3.5
1. [fw-tools] - remove `ping` test from `serial-vault-partners.canonical.com`, it is not responding to `ping` anymore.

## Izuma Edge utilities 2.3.4
1. [fw-tools] - fix the grepping of edge-K8s logfile.

## Izuma Edge utilities 2.3.3
1. [fw-tools] - fix edge-k8s URL.
1. [fw-tools] - Check return code of `openssl` calls. 
1. [fw-tools] - Return non-zero exit code if any failures spotted.
1. [fw-tools] - Skip L4 / netcat tests if BusyBox `nc` is detected (as it does not support DNS queries).
1. [fw-tools] - Skip L3 / ping tests if 100% packet loss encountered with google.com. ICMP traffic is then most likely blocked.

## Izuma Edge utilities 2.3.2
1. [fw-tools] - add `tcp-lwm2m.mbedcloud.com` address to be tested.
1. [fw-tools] - add option `-e` for echoing/debugging the script.
1. [fw-tools] - improve error checking.

## Izuma Edge utilities 2.3.1
1. [edge-info] - remove echo $NORM at beginning of firmware info, it's not coming out right.

## Izuma Edge utilities 2.3.0
1. [edge-testnet] - add support for container registry.
1. [edge-info] - add printout for internal id.

## Izuma Edge utilities 2.2.2
1. Version number bump from 2.2.0 to 2.2.2.

## Izuma Edge utilities 2.2.1
1. [identity-tool] Silence `curl` to have less noise in logs.

## Izuma Edge utilities 2.2.0
1. [edge-info] Add support for different localhost:<port>/status ports (snap port `8081`, edge-core only `8080` and LmP `9091`).
1. [edge-info] Removed unused files.
1. [edge-info] Path fixes for snap-pelion-edge information.
1. [edge-testnet] Check also snapcraft.io specific addresses, if running in a snap.
1. [identity-tools/developer_identity] Merge the logging functionality from `common.sh` into `create-dev-identity.sh` (and remove that `common.sh` completely).

## Izuma Edge utilities 2.1.0
1. [edge-info] Rename `info` tool to `edge-info`. Linux already has a command called `info`, so we need to avoid that overlap with names.
1. [testnet.sh] Renamed `testnet.sh` to `edge-testnet` to have similarity in naming with `edge-info`.

## Izuma Edge utilities 2.0.15
1. [info] Update info tool to use edge-terminal instead of pe-terminal

## Izuma Edge utilities 2.0.14
1. [info] Update info tool to auto-detect the location of edge-core and pe-terminal from the 2 possible locations.
1. [info] Update info tool to handle different output formats of ifconfig when determining IP addresses.
 
## Izuma Edge utilities 2.0.13
1. [info] Update info tool to create statistics file if not found.
 
## Izuma Edge utilities 2.0.12
1. [info] Update version information and tool name (Relay -> Edge).
1. [info] Update info tool to work better with non-LmP releases.
1. [info] CPU-frequency printing is evenly spaced and handles non-existent cpu-frequencies.
1. [info] Process state reporting takes better into account non-running processes.
1. [info] Clean shellcheck findings.

## Izuma Edge utilities 2.0.11
1. [info] Fix geolocation information printing for multi-word cases (like New York).
1. [common] Convert all tabs to spaces in script files.

## Pelion Edge utilities 2.0.10
1. [fw-tools] Tool for checking Izuma cloud connections (in case of firewalls blocking etc.)

## Pelion Edge utilities 2.0.9
1. [info] Read the hardware version from /proc/device-tree/model
1. [info] Correctly read the CPU temperature


## Pelion Edge utilities 2.0.8
1. [info] adds temperature for uzeg
1. [info] direct comms with edge-core
1. [info] detects need for sudo and informs user when using -m case
1. [info] new process status section

## Pelion Edge utilities 2.0.7

1. [identity] Added support in address derviation for a variant of UDP/TCP LwM2M domain.

## Pelion Edge utilities 2.0.6

1. [identity] Update the filter to accept any values of LwM2M service address and generate respective Edge gateway service addresses.
1. [identity] Removed the API address from identity file.
1. [info] Report Gateway service address as cloud server.

## Pelion Edge utilities 2.0.5

1. [identity] Populate the HW_VERSION by extracting the device model from file `/proc/device-tree/model`.
1. [identity] Added container service address to identity file.
1. [info] Addressed the slow down of `info -m` command.
1. [info] Ported `info` to work on `imx8mmevk` and `uz3eg-iocc`.

## Pelion Edge utilities 2.0.4

1. [identity] Developer and factory flow, both will use endpoint-name as serial number.
1. [identity] If user run create-dev-identity without passing -e argument then system will autogenerate a serial number.
1. [identity] Added a statement on successful exit.
1. [identity] Removed custom json parser. using jq tool to parse json.
1. [info] Removed parsing of ssl certs.
