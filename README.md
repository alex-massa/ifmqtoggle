# Network Interface MQTT Toggle

OpenWrt utility used to toggle a network interface via MQTT messages.

It listens for MQTT messages containing a JSON payload with an `active` field:
- if `active` is set to `true`, it enables the target network interface;
- if `active` is set to `false`, it disabled the target network interface.

## ⚠️ Disclaimer

Please be careful when specifying a target network interface in your configuration.

If you mistakenly specify the target network interface, you could potentially lose access to your access point.

Always double-check your configuration before applying changes.
Use this utility at your own risk.

## Build and installation

The package can be built using the OpenWrt build system.

Please refer to the OpenWrt Wiki for more information on how to build packages:
- ["Hello, world!" for OpenWrt](https://openwrt.org/docs/guide-developer/helloworld/start)
- ["Build system setup"](https://openwrt.org/docs/guide-developer/toolchain/install-buildsystem)

With the package built, transfer a copy to the target device and install it on using the package manager on your OpenWRT installation:
```sh
opkg install ifmqtoggle_1-1.0.0_all.ipk
```

## Configuration

The configuration can be manipulated using the UCI system or by editing the configuration file `/etc/config/ifmqtoggle` directly. \
A sample configuration section is provided when the package is installed. \
Configuration should include the connection parameters towards the MQTT broker and the name of the target network interface.

More than one interface can be handled at once by specifying multiple listener sections in the configuration. \
If you intend rely on the same MQTT topic for multiple listeners, make sure to provide a unique client ID for each one in the `mqtt_options` option. \
Alternatively, if left unspecified, different client ID should be generated automatically according to each process ID.

**Example**
```conf
config listener 'guest'
        option enabled '1'
        option iface 'guest'
        ...
        option mqtt_options '-i d98a71fe-0bdb-4515-b6f9-091c080d4ee4'

config listener 'wireguard'
        option enabled '1'
        option iface 'wg0'
        ...
        option mqtt_options '-i 51f6dbd0-c10b-4ae7-9ef4-ab35cb3e56ed'
```

**NOTE**: listeners will be started in the order they are defined in the configuration file.

## Usage

The utility can be managed as a service:
- start the service by running `/etc/init.d/ifmqtoggle start`.
- stop the service by running `/etc/init.d/ifmqtoggle stop`
- restart the service by running `/etc/init.d/ifmqtoggle restart` or `/etc/init.d/ifmqtoggle reload`
- check the status of the service: `/etc/init.d/ifmqtoggle status`
- enable the service on boot: `/etc/init.d/ifmqtoggle enable`
- disable the service from starting on boot: `/etc/init.d/ifmqtoggle disable`

## MQTT Message Format

The utility expects MQTT messages to be simple JSON objects expressed as follow:

```json
{
  "active": true
}
```
