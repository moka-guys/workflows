# MSIsensor2 image creation
Run:
```
sudo docker build . -t seglh/msisensor2:$VERSION
sudo docker save seglh/msisensor2:$VERSION | gzip > msisensor2_v$VERSION.tar.gz
```