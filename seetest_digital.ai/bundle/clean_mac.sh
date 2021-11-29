#!/bin/sh


echo "Clean XCode simu"
rm -rf ~/Library/Developer/CoreSimulator/Caches/*
rm -rf ~/Library/Developer/Xcode/iOS\ DeviceSupport/*

echo "Clean Experitest data"
sudo rm -rf /Applications/Experitest/Cloud/Agent/PaltielOrCyder_* /Applications/Experitest/Cloud/Agent/seetest_* 
sudo find /var/folders/ -name "seetest*" | sudo xargs rm -rf

echo "Clean temporary files"
sudo rm -rf /private/var/vm/sleepimage
rm -rf ~/Library/Caches/com.google.SoftwareUpdate/Downloads

echo "Remove Experitest installer folders"
rm -rf "~/Documents/Cloud*/"
rm -rf "~/Desktop/Cloud*/"
rm -rf "~/Downloads/Cloud*/"

echo "Clean trash"
rm -rf ~/.Trash/*

df -kh
