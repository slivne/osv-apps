cd apps/cassandra

wget https://github.com/downloads/brianfrankcooper/YCSB/ycsb-0.1.4.tar.gz
tar xfvz ycsb-0.1.4.tar.gz

make upstream/apache-cassandra-2.1.0

chmod +x upstream/current/tools/bin/*
