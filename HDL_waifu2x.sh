#!/bin/sh
#Script created by Chase Cobb
#This is Honey Do List, a CLI helper for waifu2x

#include helper scripts
source ./helper_scripts/IVTC.sh
source ./helper_scripts/Model_Selector.sh
source ./helper_scripts/Generic_Helpers.sh
source ./helper_scripts/Stream_Parsing.sh

echo "Dependency check ================="
# If application is not in PATH
Waifu2xIsInstalled
waifu2xInstalledStatus=$?

if [[ $waifu2xInstalledStatus -eq 0 ]]
then
    return 0
else
    echo "Waifu2x found!"
fi

FfmpegIsInstalled
ffmpegInstalledStatus=$?

if [[ $ffmpegInstalledStatus -eq 0 ]]
then
    return 0
else
    echo "ffmpeg found!"
fi
echo "All dependencies found ================="


filesToConvert=()

echo ""
echo "Welcome to Honey Do List for Waifu2x..."
echo ""

#ARGS
#File/Files/Directory to convert
#Add all args to a list of files
for var in "$@"
do
    #Is this a directory?
    IsDirectory $var
    isDirectoryReturn=$?
    if [[ isDirectoryReturn -eq 1 ]]
    then
        #If so, loop through files in this directory (not recursively) and add
        #files to the list
        for file in "$var"/*
        do
            IsFileValid "$file"
            IsFileValidReturn=$?
            if [[ IsFileValidReturn -eq 1 ]]
            then
                filesToConvert=(${filesToConvert[@]} "$file")
            fi
        done
    else #Otherwise, add the single file to the list of files
        IsFileValid "$var"
        IsFileValidReturn=$?
        if [[ IsFileValidReturn -eq 1 ]]
        then
            filesToConvert=(${filesToConvert[@]} "$var")
        fi
    fi
done

echo ""
echo "Experimental Options ================="
ShouldPerformIVTC
performIVTC=$?
echo "================="
echo ""

echo "Configure Upscaler ================="
PromptModelSelection
GenerateFinalConfiguration $?
local waifu2xArguments=( $(GetFinalConfiguration) )
echo "${waifu2xArguments[@]}"
echo "Finished Configuring Upscaler ================="
echo ""

#Iterate through all files passed in and perform upscale
for value in "${filesToConvert[@]}"
do
    local inputFile=$value
    local currentDirectory=$(cd "$(dirname "$inputFile")"; pwd -P)
    local outputDirectory="$currentDirectory/upscaled"
    local tempDirectory="$currentDirectory/upscaled/temp"
    local fileName="$(basename $inputFile)"
    local tempVideo="$tempDirectory/$fileName"
    local tempAudio="$tempDirectory/audio.mov"
    local inputFileExtension="${fileName##*.}"
    mkdir $outputDirectory
    mkdir $tempDirectory

    if [[ $performIVTC == 1 ]]
    then
        local detelecineOut="${tempDirectory}/ivtc_${fileName}"
        ffmpeg -i $inputFile -vf fieldmatch,yadif=deint=interlaced,decimate -preset veryslow -crf 13 $detelecineOut
        inputFile="$detelecineOut"
    fi

    #echo "========================================================"
    local frameRateFraction=$(ffprobe -v error -select_streams v -of default=noprint_wrappers=1:nokey=1 -show_entries stream=r_frame_rate $inputFile)
    local frameRateTruncated=$(echo "scale=3; $frameRateFraction" | bc)
    local inputResolutionWidth=$(ffprobe -v error -select_streams v:0 -show_entries stream=width -of csv=s=x:p=0 $inputFile)
    local inputResolutionHeight=$(ffprobe -v error -select_streams v:0 -show_entries stream=height -of csv=s=x:p=0 $inputFile)

    #Make sure output is scaled according to the upscaler arguments
    GetUpscaleResolutionScalar
    local outputResolutionScalar=$?
    local outputResolution=$(echo "$(( inputResolutionWidth * $outputResolutionScalar ))x$(( inputResolutionHeight * $outputResolutionScalar ))")

    echo ""
    echo "File info =============================="
    echo "File : $inputFile"
    echo "Resolution : ${inputResolutionWidth}x${inputResolutionHeight}"
    echo "Output resolution scalar : $outputResolutionScalar"
    echo "Output resolution : $outputResolution"
    echo "Frame rate : $frameRateTruncated"
    echo "Output : $tempVideo"
    echo "File info =============================="
    echo ""

    #Upscale input video
    ffmpeg -i "$inputFile" -pix_fmt rgba64le -f rawvideo -loglevel quiet - |
        waifu2x "${waifu2xArguments[@]}" --raw --width $inputResolutionWidth --height $inputResolutionHeight --16-bit |
        ffmpeg -f rawvideo -pix_fmt rgba64le -s:v $outputResolution -r $frameRateTruncated -i - -c:v libx264 "$tempVideo"

    #Copy audio from input video to output video
    ffmpeg -i "$tempVideo" -i "$inputFile" -c:v copy -c:a copy -map 0:v:0 -map 1:a "$outputDirectory/$fileName"
    rm -r $tempDirectory

    echo ""
    unset streamsArray
done

#Wait for user interaction to exit script
echo "Process Complete... Press ENTER to exit"
read -n 1
return 0