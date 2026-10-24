<!-- TOC -->
* [batiq](#batiq)
  * [Deploy batiq](#deploy-batiq)
  * [Ayon-batiq](#ayon-batiq)
<!-- TOC -->

---

# batiq

## Deploy batiq

```shell
# https://github.com/georgeantonopoulos/batiq-releases/releases
version="v0.2.41"
pname="batiq"
# https://stackoverflow.com/a/50400861

# unzipping a file from stdin ignores executable bits
# unzipping a file from file system applies executable bits correctly
# tested with
# - `bsdtar`
#   - `-p` does not make a difference
# - `busybox unzip`

# nix-shell -p busybox
# curl -fsSL https://github.com/georgeantonopoulos/${pname}-releases/releases/download/${version}/${pname}-${version}-linux-x86_64.zip \
#     | busybox unzip -d ./${pname}-${version}-linux-x86_64 -

nix-shell -p libarchive
mkdir -p ./${pname}-${version}-linux-x86_64
curl -fsSL https://github.com/georgeantonopoulos/${pname}-releases/releases/download/${version}/${pname}-${version}-linux-x86_64.zip \
    | bsdtar -p -xvf- -C ./${pname}-${version}-linux-x86_64

# extracting from zip archive seems to disregard
# executable bits
# tested with
# - busybox unzip
# - bsdtar
# How about files in
# - python/bin
# - python/lib
# ?
chmod +x ./${pname}-${version}-linux-x86_64/{batiq,batiq-app,batiq-headless,ffmpeg,ffprobe,libvulkan.so.1}

# rsync:
rsync -rhav --progress ./${pname}-${version}-linux-x86_64 user@miniboss.meemoo.lan:/data/share/tools/.stage

# rsync from stdin (does not work):
# - https://stackoverflow.com/a/20161267
# - https://hackerpublicradio.org/eps/hpr4373/index.html

# command over ssh
# - https://www.funwithlinux.net/blog/passing-variables-in-remote-ssh-command/
ssh -t user@miniboss.meemoo.lan -- stat /data/share/tools/.stage/${pname}-${version}-linux-x86_64 \
    && ssh -t user@miniboss.meemoo.lan -- mv /data/share/tools/.stage/${pname}-${version}-linux-x86_64 /data/share/tools

rm -rf ./${pname}-${version}-linux-x86_64
```

## Ayon-batiq

References:
= [GitHub - georgeantonopoulos/ayon-batiq](https://github.com/georgeantonopoulos/ayon-batiq)
