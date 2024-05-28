#build
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
mvn package -Pdist -Dmaven.javadoc.skip=true -Dmaven.test.skip=true
