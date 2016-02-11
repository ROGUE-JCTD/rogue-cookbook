node.normal.java.install_flavor = "oracle"
node.normal.java.oracle.accept_oracle_download_terms = true
node.normal.java.oracle.jce.enabled = true
node.normal.java.jdk_version = 8

default.java.max_heap_size = "#{(node.memory.total.to_i * 0.6 ).floor / 1024}m"
node.normal['java']['jdk']['8']['x86_64']['url'] = "https://s3.amazonaws.com/boundlessps-public/jdk-8u74-linux-x64.tar.gz"
node.normal['java']['jdk']['8']['x86_64']['checksum'] = "0bfd5d79f776d448efc64cb47075a52618ef76aabb31fde21c5c1018683cdddd"
