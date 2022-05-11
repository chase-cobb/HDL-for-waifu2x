#!/bin/sh
#Script created by Chase Cobb

#Returns 1 if waifu2x is found. Otherwise, returns 0.
#If waifu2x is found, but is not in PATH, an alias will be set.
Waifu2xIsInstalled () {
    if [ -z "/Applications/waifu2x.app/Contents/MacOS/waifu2x" ]
    then
        echo "Waifu2x needs to be installed from the Mac App Store"
        return 0
    else
        local waifu2xIsInPath=$(command -v waifu2x)
        
        if [ -z "$waifu2xIsInPath" ]
        then
            alias waifu2x=/Applications/waifu2x.app/Contents/MacOS/waifu2x
        fi

        return 1
    fi
}

#Returns 1 if ffmpeg is found. Otherwise, returns 0.
FfmpegIsInstalled () {
    local ffmpegInstallPath=$(command -v ffmpeg)

    if [ -z "$ffmpegInstallPath" ]
    then
        echo "ffmpeg is not installed!"
        return 0
    fi

    return 1
}

#Is a directory
IsDirectory () {
    echo "testing $1"
    if [ -d "$1" ] 
    then
        #echo "$1 is a directory"
        return 1
    else
        #echo "$1 is not a directory"
        return 0
    fi
}

#Is input file valid
IsFileValid () {
    echo "testing file $1"
    if [[ "$1" == *.mp4 ]] || [[ "$1" == *.mkv ]]
    then
        #echo "$1 is a valid file"
        return 1
    else
        echo "$1 is an invalid file"
        return 0
    fi
}