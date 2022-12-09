# GATK image creation
Run:
```
sudo docker build . -t seglh/gatk:$VERSION
sudo docker save seglh/gatk:$VERSION | gzip > gatk_v$VERSION.tar.gz
```