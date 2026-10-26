#!/bin/sh
cli -s .isp.exposure 15
cli -s .video0.size 1920x1080
cli -s .video0.fps 60
cli -s .video0.bitrate 12000
cli -s .video0.codec h265
cli -s .video0.rcMode avbr
cli -s .outgoing.enabled true
cli -s .outgoing.server udp://192.168.2.209:5600
cli -s .records.split 5
cli -s .records.notime true
