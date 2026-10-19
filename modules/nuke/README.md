

```shell
NUKE="Nuke15.2v9-linux-x86_64"
tar -tf ${NUKE}.tgz
# tar -xOzvf ${NUKE}.tgz ${NUKE}.run | bash ${NUKE}.run --accept-foundry-eula
tar -xzvf ${NUKE}.tgz
# chmod +x ${NUKE}.run
bash ${NUKE}.run --accept-foundry-eula --prefix=./Nuke
rm ${NUKE}.tgz
rm ${NUKE}.run
```

```shell
ldd --verbose /home/nixos/Downloads/Nuke/Nuke15.2v9/Nuke15.2 > ldd__${NUKE}.txt
```

> [!CAUTION]
>
> `Failed to load libstudio-15.2.9.so: <some missing lib>: cannot open shared object file: No such file or directory`
- https://discourse.nixos.org/t/where-can-i-get-libgthread-2-0-so-0/16937/7

https://github.com/hellonomonom/NukeLicenseServerSetup