# monero-bash guide:
* [Mining](#mining)
* [Usage](#usage)
* [Configuration](#configuration)
* [File Structure](#file-structure)
* [systemd](#systemd)

## Mining
To quickly start mining on P2Pool, make sure you have all the packages:
* `monero-bash install all`

Configure basic mining settings:
* `monero-bash config`

You can then:
* `monero-bash start all`

Remember, you are using your own node to mine. The blockchain has to be fully synced!


## Usage
<details>
<summary>Click to reveal full command usage</summary>

```
monero-bash usage: monero-bash <option> <more options>

monero-bash                              open wallet menu
uninstall                                uninstall ALL OF monero-bash
rpc                                      send a JSON RPC call to monerod

install <all/pkg>                        install <all> or a specific package
install <all/pkg> verbose                print detailed download information
remove  <all/pkg>                        remove <all> or a specific package

update                                   CHECK for updates
upgrade                                  upgrade all packages
upgrade <pkg>                            upgrade a specific package
upgrade <all/pkg> force                  forcefully upgrade packages
upgrade <all/pkg> verbose                print detailed download information
version                                  print installed package versions

config                                   configure MINING settings
start   <all/daemon/xmrig/p2pool>        start process detached (background)
stop    <all/daemon/xmrig/p2pool>        gracefully stop the process
kill    <all/daemon/xmrig/p2pool>        forcefully kill the process
restart <all/daemon/xmrig/p2pool>        restart the process
full    <daemon/xmrig/p2pool>            start the process attached (foreground)
watch   <daemon/xmrig/p2pool>            watch live output of process
edit    <daemon/xmrig/p2pool>            edit systemd service file
reset   <bash/daemon/xmrig/p2pool>       reset your configs/systemd to default

backup                                   encrypt and backup your /wallets/
decrypt                                  decrypt backup.tar.gpg

status                                   print status of all running processes
seed                                     generate random 25-word Monero seed
list                                     list wallets
size                                     show size of monero-bash folders
price                                    fetch price data from cryptocompare.com API
integrity                                check hash integrity of monero-bash

help                                     show this help message
```
</details>

## Configuration
Config files are in `~/.monero-bash/config`, you can edit them or replace them with your own

To setup P2Pool, either use `monero-bash config` or edit `.monero-bash/config/monero-bash.conf`
```
######################
# monero-bash config #
######################
# monero-bash
AUTO_START_DAEMON="true"         auto-start daemon on wallet open
AUTO_STOP_DAEMON="true"          auto-stop daemon on wallet close
AUTO_UPDATE="false"              check for all updates on wallet open
PRICE_API_IP_WARNING="true"      warn when checking price API

# hugepages
AUTO_HUGEPAGES="true"            auto-set hugepages when starting all processes
HUGEPAGES="3072"                 hugepage size

# p2pool
DAEMON_IP="127.0.0.1"            monerod IP to connect to (default: 127.0.0.1/localhost)
WALLET=""                        wallet address to send payouts to
LOG_LEVEL="2"                    log/console output level (default: 2, options are 0-6)

# daemon rpc
DAEMON_RPC_IP="127.0.0.1:18081"  monerod IP used by RPC calls (default is localhost:18081)
DAEMON_RPC_VERBOSE="false"       print extra messages on RPC calls
```

## File Structure
These are all the folders/files created by `monero-bash` after installation:

**INSTALLATION PATH**
```
/usr/local/share/monero-bash/
?????? monero-bash          main script
?????? config               backup config files
?????? gpg                  gpg keys
?????? src                  source code

/usr/local/bin/monero-bash
?????? monero-bash          symlink to main script
```

**HOME FOLDER**
```
/home/user/.monero-bash/
?????? config               config files
?????? wallets              wallet files
?????? .bitmonero           monero blockchain/data folder
```
*note:* the `.bitmonero` folder path can be set anywhere

**SYSTEMD SERVICES**
```
/etc/systemd/system/
?????? monero-bash-monerod.service
?????? monero-bash-p2pool.service
?????? monero-bash-xmrig.service
```

**TEMP FILES**
```
/tmp/
?????? monero-bash.XXXXXXXXXX
?????? monero-bash-hash.XXXXXXXXXX
?????? monero-bash-sig.XXXXXXXXXX
?????? monero-bash-gpg.XXXXXXXXX
?????? monero-bash-service.XXXXXXXXX
```
*note:* monero-bash `/tmp/` folders are deleted after upgrade, and wiped if computer is rebooted. All files created by `monero-bash` have `700/600` permissions or are within folders that have those permissions. This is to prevent any other user from reading the data. After uninstalling monero-bash, all these files are deleted with the exception of `$HOME/.bitmonero` if you picked that as your data directory.

## systemd
monero-bash creates and uses systemd service files to control:
* `monerod`
* `xmrig`
* `p2pool`

If you'd like to directly invoke a program:
* `monero-bash full <daemon/p2pool/xmrig>`

This will launch them in the current terminal
