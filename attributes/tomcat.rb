node.normal.tomcat.base_version = 7
node.normal.tomcat.service = "tomcat#{node.tomcat.base_version}"
node.normal.tomcat.cors_enabled = true
node.normal.tomcat.java_options =
  if node.java.jdk_version == 8
    "-Djava.awt.headless=true -Xms256m -Xmx#{node.java.max_heap_size} -Xrs -XX:PerfDataSamplingInterval=500 -XX:+UseParallelOldGC -XX:+UseParallelGC -XX:SoftRefLRUPolicyMSPerMB=36000"
  else
    "-Djava.awt.headless=true -Xms256m -Xmx#{node.java.max_heap_size} -Xrs -XX:PerfDataSamplingInterval=500 -XX:+UseParallelOldGC -XX:+UseParallelGC -XX:MaxPermSize=512m -XX:SoftRefLRUPolicyMSPerMB=36000"
  end
