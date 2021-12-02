#!/usr/bin/bash

directory_='//WRIV02DTSTDNT1/RecordStor20172019/BetweenRivers_2019/T049_1144/Data/'
output_director='/cygdrive/d/WindDetection/outputs/'

echo $directory_

for f in $(find $directory_ -name '*.wav')
    do 
        #echo $f
        # arrIN=(${f#/*/*/})
        part1=$(dirname "$f")
        part2=$(basename "$f")
        tail=".wav"
        filenameshort=${part2%$tail}
        echo $filenameshort;
        ./windDet.exe -i $f -o $output_director$filenameshort.txt -j $output_director$filenameshort.json  -t 1 -g 1 -f 43 -w 25 -v 0

    done

# ./windDet.exe -i $directory_$INFILE -o test/Windless3.txt -j test/Windless3.json -f 20 -v 1