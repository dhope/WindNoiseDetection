#!/usr/bin/bash

directory_='/cygdrive/d/!_TEMP_AUDIO_SAMPLES/ARU_RecordingSample_P7-04/20211004_NapkenLk_duskdawn/'
output_director='/cygdrive/d/!_TEMP_AUDIO_SAMPLES/outputs/'
# INFILE='20211004T203500-0400_SS.wav'


for f in $(find $directory_ -name '*.wav')
    do 
        echo $f
        # arrIN=(${f#/*/*/})
        part1=$(dirname "$f")
        part2=$(basename "$f")
        tail=".wav"
        filenameshort=${part2%$tail}
        # echo $filenameshort;
        ./windDet.exe -i $f -o $output_director$filenameshort.txt -j $output_director$filenameshort.json  -t 1 -g 1 -f 43 -w 25 -v 0

    done

# ./windDet.exe -i $directory_$INFILE -o test/Windless3.txt -j test/Windless3.json -f 20 -v 1