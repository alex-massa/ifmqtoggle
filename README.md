# Network Interface MQTT Toggle

This is an OpenWrt utility used to toggle network interfaces via MQTT messages.

The utility employs the [mosquitto](https://mosquitto.org/) MQTT client to subscribe to a topic and toggle the state of a network interface based on the received messages.

## ⚠️ Disclaimer

Be careful when specifying a target network interface in your configuration, as you could potentially get locked out of your access point. \
Always double-check your configuration before applying changes.

## Build and installation

> [!IMPORTANT]
> The build process requires a running Docker daemon.
>
> Additionally, devices running on Apple Silicon should enable Rosetta to build the package successfully. \
> Please refer to the [official Docker documentation](https://docs.docker.com/desktop/settings/mac/#general) on how to enable Rosetta in Docker Desktop for macOS.

> [!TIP]
> For instructions on manually building the package, refer to [this wiki page](https://github.com/alex-massa/ifmqtoggle/wiki/Manually-building-the-package).

Clone this repository via Git, then build the package by invoking the `make` utility on the `Makefile` within the `.build` directory:
```sh
make -f .build/Makefile
```

Once finished, the build process will result in an `.ipk` package in the `.build` directory. \
Transfer a copy to the target device via SCP or any method of your choice, then install it from the shell of the device:
```sh
opkg update
opkg install ifmqtoggle_*_all.ipk
```

## Configuration

The package configuration is managed through [UCI](https://openwrt.org/docs/guide-user/base-system/uci) and can be updated either through the CLI utility or by directly editing the configuration file found at `/etc/config/ifmqtoggle`. \
A sample configuration section is provided when the package is installed.

Multiple interfaces can be managed simultaneously by defining multiple listener sections in the configuration. \
Listeners will be started in the order they appear in the configuration.

The configuration options for each listener should specify the connection parameters to the MQTT broker and the name of the target network interface:
- `enabled` determines whether the listener is active; set to `1` to enable the listener, otherwise set to `0`.
- `iface` is the name of the network interface that the listener will manage.
- `mqtt_broker_host` and `mqtt_broker_port` specify the address and port of the MQTT broker.
- `mqtt_broker_retry_delay` is the delay in seconds before retrying a failed connection to the MQTT broker; defaults to 5 seconds if unspecified.
- `mqtt_topic` is the MQTT topic that the listener will subscribe to.
- `mqtt_username` and `mqtt_password` are the credentials for the MQTT broker; leave empty if no authentication is required.
- `mqtt_options` are additional options for the MQTT client; these should be formatted as they would be on the command line for `mosquitto_sub`.

> [!NOTE]
> If you plan on controlling more than one network interface coordinately by using the same MQTT topic for multiple listeners, ensure that each one has a unique client ID specified in the `mqtt_options` option in order to avoid conflicting message consumption.
> If no client ID is specified, unique IDs should be automatically generated based on the ID of each process.
>
> For example, this is what a configuration file with two listeners could look like, with each listener specifying a unique client ID:
> ```sh
> config listener 'guest'
>         option enabled '1'
>         option iface 'guest'
>         # ... other options ...
>         option mqtt_options '-i d98a71fe-0bdb-4515-b6f9-091c080d4ee4'
> 
> config listener 'wireguard'
>         option enabled '1'
>         option iface 'wg0'
>         # ... other options ...
>         option mqtt_options '-i 51f6dbd0-c10b-4ae7-9ef4-ab35cb3e56ed'
> ```

## Usage

The utility can be managed as a service:
- Start the service: `/etc/init.d/ifmqtoggle start`
- Stop the service: `/etc/init.d/ifmqtoggle stop`
- Restart the service: `/etc/init.d/ifmqtoggle restart` or `/etc/init.d/ifmqtoggle reload`
- Check the status of the service: `/etc/init.d/ifmqtoggle status`
- Enable the service on boot: `/etc/init.d/ifmqtoggle enable`
- Disable the service from starting on boot: `/etc/init.d/ifmqtoggle disable`

### Expected MQTT message format

The utility expects MQTT messages to be simple JSON objects with a boolean `active` field:

```json
{ "active": true }
```

```json
{ "active": false }
```

The value specified in the `active` field is used to update the state of the target network interface:
- `true`: the utility will attempt to enable the target network interface.
- `false`: the utility will attempt to disable the target network interface.

Please note that the utility will discard any message with an invalid or missing `active` field. \
Any other fields present in the message will be ignored.
