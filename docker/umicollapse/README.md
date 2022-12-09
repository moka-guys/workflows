# UMICollapse image creation
Run:
```
sudo docker build . -t seglh/umicollapse:$VERSION
sudo docker save seglh/umicollapse:$VERSION | gzip > umicollapse_v$VERSION.tar.gz
```