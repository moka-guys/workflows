# Vardict image creation
Run:
```
sudo docker build . -t seglh/vardict:$VERSION
sudo docker save seglh/vardict:$VERSION | gzip > vardict_v$VERSION.tar.gz
```