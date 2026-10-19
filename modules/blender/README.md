

---

```shell
curl --location https://download.blender.org/release/Blender5.2/blender-5.2.1-linux-x64.tar.xz \
    --output ~/Downloads/blender-5.2.1-linux-x64.tar.xz
tar -xvf ~/Downloads/blender-5.2.1-linux-x64.tar.xz -C $(dirname ~/Downloads/blender-5.2.1-linux-x64.tar.xz)
```

- https://transloadit.com/devtips/decompress-archives-directly-with-curl-and-command-line/

```shell
# https://download.blender.org/release
# https://www.blender.org/download/lts/
version="4.5.13"
pname="blender"
# https://stackoverflow.com/a/50400861
BLENDER="${version%.*}"

curl --location https://download.blender.org/release/Blender${BLENDER}/${pname}-${version}-linux-x64.tar.xz \
    --output ./${pname}-${version}-linux-x64.tar.xz
tar -xvf ./${pname}-${version}-linux-x64.tar.xz
```

```shell
# cd ./configs/components/fhs/buildFHSEnv/blender

curl -fsSL https://download.blender.org/release/Blender${BLENDER}/${pname}-${version}-linux-x64.tar.xz \
    | tar \
        --xz \
        --extract \
        --verbose \
        --file -

# rsync:
rsync -rhav --progress ./${pname}-${version}-linux-x64 user@miniboss.meemoo.lan:/data/share/tools/.stage

# rsync from stdin (does not work):
# - https://stackoverflow.com/a/20161267
# - https://hackerpublicradio.org/eps/hpr4373/index.html

# command over ssh
# - https://www.funwithlinux.net/blog/passing-variables-in-remote-ssh-command/
ssh -t user@miniboss.meemoo.lan -- stat /data/share/tools/.stage/${pname}-${version}-linux-x64 \
    && ssh -t user@miniboss.meemoo.lan -- mv /data/share/tools/.stage/${pname}-${version}-linux-x64 /data/share/tools

rm -rf ./${pname}-${version}-linux-x64
```
