# Debian packages for ChromeBooks
  
To install .list file using pkmgr:  

```shell
pkmgr curl https://github.com/pkmgr/debian/raw/master/lists/default.list
```

To install .sh script using pkmgr  

```shell
pkmgr script https://github.com/pkmgr/debian/raw/master/scripts/default.sh
```  

use the following format to manual install:  

```shell
sudo apt install --ignore-missing -y - $(cat aptlist.txt )
```
