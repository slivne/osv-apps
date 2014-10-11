wget https://github.com/downloads/brianfrankcooper/YCSB/ycsb-0.1.4.tar.gz
tar xfvz ycsb-0.1.4.tar.gz
cd ycsb-0.1.4
mvn package install

chmod +x ../upstream/current/tools/bin/*
