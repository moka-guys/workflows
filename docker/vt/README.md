# vt image creation
Run:
```
sudo docker build . -t seglh/vt$VERSION
sudo docker save seglh/vt:$VERSION | gzip > vt_v$VERSION.tar.gz
```