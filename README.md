# Network Interface MQTT Toggle

This is an OpenWrt utility used to toggle a network interface via MQTT messages.

The utility employs the [mosquitto](https://mosquitto.org/) MQTT client to subscribe to a topic and toggle the state of a network interface based on the received messages. \
These messages should consist of a JSON payload with a boolean `active` field:
- When `active` is set to `true`, the target network interface is enabled;
- When `active` is set to `false`, the target network interface is disabled.

## ⚠️ Disclaimer

Be careful when specifying a target network interface in your configuration, as you could potentially get locked out of your access point.

Always double-check your configuration before applying changes.
Use this utility at your own risk.

## Build and installation

The following steps are derived from the ["Hello, world!" for OpenWrt](https://openwrt.org/docs/guide-developer/helloworld/start) guide. \
I am confident the building process can be automated, though I have not figured out how yet.
  1.  [Prepare a local OpenWrt build system environment](https://openwrt.org/docs/guide-developer/toolchain/install-buildsystem). \
      If you are not running a compatible GNU/Linux environment or would rather avoid cluttering your local environment, a virtual machine or even a container should work just as fine.
  2.  Clone the OpenWrt repository in a directory named `source`, then checkout the branch corresponding to the version of OpenWrt you are running on your target device (as of May 2024, the latest stable release is `v23.05.3`):
      ```sh
      git clone https://git.openwrt.org/openwrt/openwrt.git source
      cd source
      git checkout v23.05.3
      make distclean
      ```
  3.  Update and install the packages from the already present feeds:
      ```sh
      ./scripts/feeds update -a
      ./scripts/feeds install -a
      ```
  4.  Configure the cross-compilation environment for the target device:
      ```sh
      make menuconfig
      ```
      - From the menu, chose the values for **Target System**, **Subtarget**, and **Target Profile** that are suitable for your target device. \
        The correct values can usually be inferred by checking the content of `/etc/openwrt_release` on the target device.
      - Exit the configuration menu and save the changes.
  5.  Build the target-independent tools and the cross-compilation toolchain (this might take some time):
      ```sh
      make toolchain/install
      ```
  6.  Clone this repository in a directory named `mypackages`, which should be a sibling of the `source` directory:
      ```sh
      git clone https://github.com/alex-massa/ifmqtoggle $(dirname $(pwd))/mypackages/ifmqtoggle
      ``` 
  7.  Update the package feeds and install packages from the `mypackages` feed:
      ```sh
      echo "src-link mypackages $(dirname $(pwd))/mypackages" > feeds.conf
      ./scripts/feeds update mypackages
      ./scripts/feeds install -a -p mypackages
      ```
  8.  Include the package in the configuration of the target firmware:
      ```sh
      make menuconfig
      ```
      - Navigate to **Network**, select `ifmqtoggle` from the list of available packages, then use the **Y** key to include the package in the firmware configuration.
      - Exit the configuration menu and save the changes.
  9.  Build the package:
      ```sh
      make package/ifmqtoggle/compile
      ```

With the above steps completed, the package should be built in the `bin/packages/<arch>/mypackages` directory. \
Transfer a copy to the target device and install it using the package manager on your OpenWrt installation:
```sh
opkg install ifmqtoggle_1.0.0-1_all.ipk
```

## Configuration

The package configuration can be managed either through UCI or by directly editing the configuration file found at `/etc/config/ifmqtoggle`. \
A sample configuration section is provided when the package is installed.

The configuration should specify the connection parameters to the MQTT broker and the name of the target network interface.

Multiple interfaces can be managed simultaneously by defining multiple listener sections in the configuration file. \
If you plan on controlling more than one network interface coordinately by using the same MQTT topic for multiple listeners, ensure that each one has a unique client ID specified in the `mqtt_options` option in order to avoid conflicting message consumption. If no client ID is specified, unique IDs should be automatically generated based on the ID of each process.

**Example**: multiple listeners explicitly specifying different client IDs
```sh
config listener 'guest'
        option enabled '1'
        option iface 'guest'
        # ... other options ...
        option mqtt_options '-i d98a71fe-0bdb-4515-b6f9-091c080d4ee4'

config listener 'wireguard'
        option enabled '1'
        option iface 'wg0'
        # ... other options ...
        option mqtt_options '-i 51f6dbd0-c10b-4ae7-9ef4-ab35cb3e56ed'
```

Listeners will be started in the order they are defined in the configuration file.

## Usage

The utility can be managed as a service:
- Start the service: `/etc/init.d/ifmqtoggle start`
- Stop the service: `/etc/init.d/ifmqtoggle stop`
- Restart the service: `/etc/init.d/ifmqtoggle restart` or `/etc/init.d/ifmqtoggle reload`
- Check the status of the service: `/etc/init.d/ifmqtoggle status`
- Enable the service on boot: `/etc/init.d/ifmqtoggle enable`
- Disable the service from starting on boot: `/etc/init.d/ifmqtoggle disable`

## Expected MQTT message format

The utility expects MQTT messages to be simple JSON objects expressed as follows:

```json
{
  "active": true
}
```
