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

1. [identity] Update the filter to accept any values of LwM2M service address and generate respecitve Edge gateway service addresses.
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
