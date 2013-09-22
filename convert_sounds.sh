#! /bin/bash
for i in assets/sound/*.{wav,aiff}; 
do echo "converting $i ..."; 
filename=$(basename "$i")
filename="${filename%.*}"
sox "$i" assets/sound/${filename}.mp3 rate 44100 reverse silence 1 0.005 0.1% reverse; 
done
