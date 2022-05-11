#!/bin/sh
#Script created by Chase Cobb

SplitStreams () {
    local formattedStreams=()

    #Get streams
    local streamInfo=($(ffprobe -of default=nw=1 -v error -show_entries stream=index,codec_name,codec_type $1))
    local entriesPerStream=3
    local numberOfTotalStreamEntries=${#streamInfo[@]}
    local streamRatio="$numberOfTotalStreamEntries/$entriesPerStream"
    local numberOfStreams=("$(($streamRatio))")

    #Split stream and format into easily parsed strings
    local numberOfEntries=1
    local formattedStreamText=''
    for infoEntry in $streamInfo
    do
        local splitInfoEntry=$(echo "$infoEntry" | cut -d "=" -f 2)

        if [ -z "$formattedStreamText" ]
        then
            formattedStreamText=$splitInfoEntry
        else
            formattedStreamText="${formattedStreamText}${splitInfoEntry}"
        fi

        #Add infoEntry to a ':'separated string
        if (($numberOfEntries < 3))
        then
            formattedStreamText="${formattedStreamText}:"
            numberOfEntries=$(expr $numberOfEntries + 1)

        else
            # add this formatted string to the array of split streams
            formattedStreams+=($formattedStreamText)
            
            # clear out the temp variables
            formattedStreamText=""
            numberOfEntries=1
        fi
    done

    echo ${formattedStreams[@]}
}

#input is ALL streams
GetAudioStreams () {
    local audioStreams=()
    
    echo "looking for audio streams ??????"

    #Find audio streams in the array of all streams
    for stream in "$1"
    do
        currentStream=!(GetStreamType $stream)
        if [[ $currentStream == "audio" ]]
        then
            echo $stream
        fi
    done
}

#input is a stream that has been formatted by SplitStream
GetStreamType () {
    local streamType=$(echo "$1" | cut -d ":" -f 3)
    if [[ $streamType == "audio" ]]
    then
        return 2
    #TODO : add return types for other types of streams
    fi
}

GetAudioStreamFormat () {
    #Parse the string for the audio stream type

    # TODO : What are the supported types?
}

#EXAMPLE: Snippet showing how to get audio streams
#Get all streams from this file
#echo ""
#local -a streamsArray=( $(SplitStreams $inputFile) )
#local -a audioStreams=()
#for stream in $streamsArray
#do
#    echo "$stream"
#    GetStreamType $stream
#    local streamType=$?

#    if [[ $streamType == 2 ]]
#    then
#        audioStreams+=($stream)
#    fi
#done

#Get audio streams from this file
#for stream in $audioStreams
#do
#    echo "audio stream found --> $stream"
#done
#echo ""