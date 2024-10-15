#build
MARG=$1
HADOOP_PROTOC_PATH=/usr/bin/protoc JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 mvn $MARG clean install -U package -Pdist -Dmaven.javadoc.skip=true -Dmaven.test.skip=true
#JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 mvn test-compile
