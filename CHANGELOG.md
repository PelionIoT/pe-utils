## Pelion Edge utilities 2.5.0

1. [identity] Populate the HW_VERSION by extracting the device model from file `/proc/device-tree/model`.
1. [identity] Added container service address to identity file.
1. [info] Addressed the slow down of `info -m` command.
1. [info] Ported `info` to work on `imx8mmevk` and `uz3eg-iocc`.

## Pelion Edge utilities 2.4.0

1. [identity] Developer and factory flow, both will use endpoint-name as serial number.
1. [identity] If user run create-dev-identity without passing -e argument then system will autogenerate a serial number.
1. [identity] Added a statement on successful exit.
1. [identity] Removed custom json parser. using jq tool to parse json.
1. [info] Removed parsing of ssl certs.