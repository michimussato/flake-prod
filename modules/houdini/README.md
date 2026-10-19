

---

- https://discourse.nixos.org/t/buildfhs-alternatives/61752

Download Houdini
```shell
# https://www.sidefx.com/login/
# https://www.sidefx.com/download/daily-builds/?show_launcher=false&production=true&linux=true
curl https://www.sidefx.com/login/
curl \
  --location \
  -X POST \
  -H 'Content-type: application/json' \
  -H 'Referer: ";auto"' \
  --data '{"username":"","password":""}' \
  "https://www.sidefx.com/login/?next=/download/download-houdini/152083/get/"
```

- [houdini-qt5-21.0.792-linux_x86_64_gcc11.2.tar.gz](https://www.sidefx.com/download/download-houdini/150277/get/)
- [houdini-22.0.429-linux_x86_64_gcc14.2.tar.gz](https://www.sidefx.com/download/download-houdini/152083/get/)

Extract Houdini
- https://mylinux.work/guides/backup-basics-with-tar-and-rsync/
```shell
# cd houdini.tar.gz base dir
# HOUDINI="houdini-22.0.429-linux_x86_64_gcc14.2"
HOUDINI=""
# List contents
# - https://techearl.com/find-and-tar-archive
# # tar -tzvf ${HOUDINI}.tar.gz
# - https://www.cyberciti.biz/faq/grep-regular-expressions/
tar -tf ${HOUDINI}.tar.gz --wildcards ${HOUDINI}/"python*.tar.gz" | grep -E "${HOUDINI}/python[[:digit:]]{1,2}\.[[:digit:]]{1,2}\.tar\.gz" | sed "s,${HOUDINI}/,,g"
# - https://linuxlearncmd.com/commands/ptargrep/
# - https://www.geeksforgeeks.org/perl/perl-regex-cheat-sheet/
# ptargrep --list-only "python" ${HOUDINI}.tar.gz 
# HOUDINI_PYTHON="python3.11"
HOUDINI_PYTHON=""
# The downloaded tar archive contains multiple sub archives that are relevant
# - houdini.tar.gz
# - python3.11.tar.gz
# - pythonlibdeps.tar.gz
# extract contained houdini.tar.gz first
# tar -xzvf ${HOUDINI}.tar.gz ${HOUDINI}/houdini.tar.gz
# mkdir -p ./${HOUDINI}
# tar -xzvf houdini.tar.gz -C ./${HOUDINI}

mkdir -p ./${HOUDINI}
tar -xOvf ${HOUDINI}.tar.gz ${HOUDINI}/houdini.tar.gz | tar -xzvf - -C ./${HOUDINI}
# Python and Python Libs may (depending on the version of Houdini)
# come in separate tar archives and have to be extracted individually:
mkdir -p ./${HOUDINI}/python
# tar -xOvf ${HOUDINI}.tar.gz --wildcards ${HOUDINI}/${HOUDINI_PYTHON}.tar.gz | tar -xzvf - -C ./${HOUDINI}/python
tar -xOvf ${HOUDINI}.tar.gz ${HOUDINI}/${HOUDINI_PYTHON}.tar.gz | tar -xzvf - -C ./${HOUDINI}/python
tar -xOvf ${HOUDINI}.tar.gz ${HOUDINI}/pythonlibdeps.tar.gz | tar -xzvf - -C ./${HOUDINI}/python

rm ./${HOUDINI}.tar.gz

# rsync -rhav --progress /home/michael/git/repos/nixos-configuration/configs/components/fhs/buildFHSEnv/houdini/${HOUDINI}.tar.gz user@miniboss.meemoo.lan:/data/share/tools/
# scp:
# scp -r ./${HOUDINI} user@miniboss.meemoo.lan:/data/share/tools/
# rsync:
# rsync -rhav --progress ./${HOUDINI} user@miniboss.meemoo.lan:/data/share/tools
# 
# pushd ./${HOUDINI}
# source houdini_setup
# QT_QPA_PLATFORM=xcb houdini
# popd

rm -rf ./${HOUDINI}
```

---

LDD
```shell
ldd /data/share/tools/${HOUDINI}/bin/houdini
# not a dynamic executable
# => Use /data/share/tools/${HOUDINI}/bin/houdini-bin instead
```

---

RUN

Vulkan:
- https://github.com/michimussato/deadline-setup/blob/main/houdini/README_HOUDINI.md#vulkan

Set License Server:
- https://www.sidefx.com/docs/houdini/ref/utils/sesictrl.html
- https://www.sidefx.com/docs/houdini/ref/utils/hserver.html
```shell
hserver --server http://miniboss.meemoo.lan:1715
# or set SESI_LMHOST
```

```shell
nix-shell ./houdini-shell.nix
pushd /data/share/tools/${HOUDINI}
source houdini_setup
houdini
popd
```
