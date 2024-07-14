package org.apache.hadoop.hdfs.server.namenode;

import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;

import org.apache.hadoop.hdfs.HdfsConfiguration;
import org.apache.hadoop.hdfs.NameNodeProxies;
import org.apache.hadoop.hdfs.protocol.ClientProtocol;
import org.apache.hadoop.security.UserGroupInformation;

public class SmallBench{
  public static void main(String args[]){
    try {
      ClientProtocol nn = NameNodeProxies.createProxy(new HdfsConfiguration(), new URI("hdfs://localhost:9000"), ClientProtocol.class).getProxy();
      long start, end;
      float sum = 0.0f;
      int count = 100000;
      for(int i = 0;i<count;i++){
        start= System.nanoTime();
        // nn.append("/small._COPYING_.", UserGroupInformation.getCurrentUser().getUserName());
        nn.getBlockLocations("/small", 0, 100);
        end=System.nanoTime();
        sum += (end-start+0.0f);
      }
      System.out.println("average: " + sum/count/1e6 +"ms");
    } catch (IOException e) {
      e.printStackTrace();
    } catch (URISyntaxException e) {
      e.printStackTrace();
    }
  }
}
