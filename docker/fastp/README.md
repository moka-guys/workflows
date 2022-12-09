# Fastp image creation
Run:
```
sudo docker build . -t seglh/fastp:$VERSION
sudo docker save seglh/fastp:$VERSION | gzip > fastp_v$VERSION.tar.gz
```