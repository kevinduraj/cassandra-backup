#!/bin/bash                                                                                                                                                   
#-------------------------------------------------------------------#
apt-get -y remove dse-full
apt-get autoremove
#-------------------------------------------------------------------#

apt-get -y install dse-full="4.8.4-1" dse="4.8.4-1" dse-hive="4.8.4-1" dse-pig="4.8.4-1" dse-demos="4.8.4-1" dse-libsolr="4.8.4-1" dse-libtomcat="4.8.4-1" dse-libsqoop="4.8.4-1" dse-liblog4j="4.8.4-1" dse-libmahout="4.8.4-1" dse-libspark="4.8.4-1" dse-libhadoop-native="4.8.4-1" dse-libcassandra="4.8.4-1" dse-libhive="4.8.4-1" dse-libpig="4.8.4-1" dse-libhadoop="4.8.4-1"

#-------------------------------------------------------------------#
