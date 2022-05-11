#!/bin/sh
#Script created by Chase Cobb

fullyConfiguredArguments=""
resolutionScalar=1

#Internal helper to keep global variable access in check.
function SetResolutionScalar () {
    echo "Setting resolution scalar to $1"
    resolutionScalar=$1
}

#Allow the user to pick the basic noise reduction level.
BasicModelConfigureNoiseReduction () {
    echo ""
    #Noise reduction None 0 1 2 3
    while true
    do
        echo "Please type the number of the target noise reduction to use"
        echo "1 - 0"
        echo "2 - 1"
        echo "3 - 2"
        echo "4 - 3"
        read noiseReductionSelection

        if [[ $noiseReductionSelection -gt 0 ]] && [[ $noiseReductionSelection -lt 5 ]]
        then
            return $noiseReductionSelection
        fi
    done
    echo ""
}

#Allow the user to pick the basic upscale level.
BasicModelConfigureUpscaleLevel () {
    echo ""
    #Upscale level None 2x 4x
    while true
    do
        echo "Please type the number of the target upscale level"
        echo "1 - NONE"
        echo "2 - 2x"
        echo "3 - 4x"
        read upscaleSelection

        if [[ $upscaleSelection -gt 0 ]] && [[ $upscaleSelection -lt 4 ]]
        then
            if [[ $upscaleSelection -eq 1 ]]
            then
                SetResolutionScalar 1
            elif [[ $upscaleSelection -eq 2 ]]
            then
                SetResolutionScalar 2
            elif [[ $upscaleSelection -eq 3 ]]
            then
                SetResolutionScalar 4
            fi
            return $upscaleSelection
        fi
    done
    echo ""
}

#Allow the user to pick the Esrgan variant.
EsrganConfigureVariant () {
    echo ""
    while true
    do
        #Variant Select
        echo "Please type the number of the variant to use"
        echo "1 - Anime 4x"
        echo "2 - Anime 2x (video)"
        echo "3 - Anime 4x (video)"
        echo "4 - Photo 2x (sharp)"
        echo "5 - Photo 4x (sharp)"
        echo "6 - Photo 4x (smooth)"
        read variantSelection

        if [[ $variantSelection -gt 0 ]] && [[ $variantSelection -lt 7 ]]
        then
            if [[ $variantSelection -eq 2 ]] || [[ $variantSelection -eq 4 ]]
            then
                SetResolutionScalar 2
            else
                SetResolutionScalar 4
            fi

            return $variantSelection
        fi
    done
    echo ""
}

#Allow the user to pick the Cugan upscale level.
CuganConfigureUpscaleLevel () {
    echo ""
    #Upscale level 2x 3x 4x
    while true
    do
        echo "Please type the number of the target upscale level"
        echo "1 - 2x"
        echo "2 - 3x"
        echo "3 - 4x"
        read upscaleSelection

        if [[ $upscaleSelection -gt 0 ]] && [[ $upscaleSelection -lt 4 ]]
        then
            if [[ $upscaleSelection -eq 1 ]]
            then
                SetResolutionScalar 2
            elif [[ $upscaleSelection -eq 2 ]]
            then
                SetResolutionScalar 3
            elif [[ $upscaleSelection -eq 3 ]]
            then
                SetResolutionScalar 4
            fi

            return $upscaleSelection
        fi
    done
    echo ""
}

#Allow the user to pick the Cugan noise level.
CuganConfigureNoiseLevel () {
    echo ""
    #Noise level Conservative Noise Free Noise_Level_1 Noise_Level_2 Noise_Level_3
    while true
    do
        echo "Please type the number of the target noise reduction to use"
        echo "1 - Conservative"
        echo "2 - Noise Free"
        echo "3 - Noise Level 1"
        echo "4 - Noise Level 2"
        echo "5 - Noise Level 3"
        read noiseReductionSelection

        if [[ $noiseReductionSelection -gt 0 ]] && [[ $noiseReductionSelection -lt 6 ]]
        then
            return $noiseReductionSelection
        fi
    done
    echo ""
}

#Allow the user to pick the Cugan intensity. This will be scaled appropriately
#before it is passed to waifu2x.
CuganConfigureIntensity () {
    echo ""
    #Intensity 0.5-1.5
    while true
    do
        echo "Please enter the intensity value 5 - 15 (Defaut 10)"
        read intensityValue

        # TODO : intensityValue needs to be error checked

        if [[ $intensityValue -gt 4 ]] && [[ $intensityValue -lt 16 ]]
        then
            echo ""
            return $intensityValue
        else
            echo "$intensityValue is outside of accepted range ========="
            echo ""
        fi
    done
}

#Allow the user to pick the upscale model.
PromptModelSelection () {
    fullyConfiguredArguments=""
    SetResolutionScalar 1

    echo ""
    while true
    do
        #Model to run [srcnn_anime, srcnn_photo, cunet_anime, pan_anime, real_esrgan, real_cugan].
        echo "Please type the number of the model to use"
        echo "1 - SRCNN - Anime"
        echo "2 - SRCNN - Photo"
        echo "3 - CUnet - Anime"
        echo "4 - Pan - Anime"
        echo "5 - Real-ESRGAN"
        echo "6 - Real-CUGAN"
        read modelSelection

        if [[ $modelSelection -gt 0 ]] && [[ $modelSelection -lt 7 ]]
        then
            return $modelSelection
        fi
    done
    echo ""
}

#Build a basic model configuration based on prior user selections.
BuildBasicConfiguration () {
    local noiseReduction=$1
    local upscaleLevel=$2
    local configurationArguments=""

    if [[ $noiseReduction -eq 1 ]]
    then
        configurationArguments="${configurationArguments}-n 0"
    elif [[ $noiseReduction -eq 2 ]]
    then
        configurationArguments="${configurationArguments}-n 1"
    elif [[ $noiseReduction -eq 3 ]]
    then
        configurationArguments="${configurationArguments}-n 2"
    elif [[ $noiseReduction -eq 4 ]]
    then
        configurationArguments="${configurationArguments}-n 3"
    fi

    if [[ $upscaleLevel -eq 2 ]]
    then
        configurationArguments="${configurationArguments} -s 2"
    elif [[ $upscaleLevel -eq 3 ]]
    then
        configurationArguments="${configurationArguments} -s 4"
    fi

    echo "$configurationArguments"
}

#Build a Esrgan model configuration based on prior user selections.
BuildEsrganConfiguration () {
    if [[ $1 -eq 1 ]]
    then
        echo "-v anime_4x"
    elif [[ $1 -eq 2 ]]
    then
        echo "-v anime_2x_video"
    elif [[ $1 -eq 3 ]]
    then
        echo "-v anime_4x_video"
    elif [[ $1 -eq 4 ]]
    then
        echo "-v photo_2x_sharp"
    elif [[ $1 -eq 5 ]]
    then
        echo "-v photo_4x_sharp"
    elif [[ $1 -eq 6 ]]
    then
        echo "-v photo_4x_smooth"
    fi
}

#Build a Cugan model configuration based on prior user selections.
BuildCuganConfiguration () {
    local noiseLevel=$1
    local upscaleLevel=$2
    local intensity=$3
    local configurationArguments=""

    #Noise level
    if [[ $noiseLevel -eq 1 ]]
    then
        configurationArguments="${configurationArguments}--cugan-variant conservative "
    elif [[ $noiseLevel -eq 2 ]]
    then
        configurationArguments="${configurationArguments}--cugan-variant noise_free "
    elif [[ $noiseLevel -eq 3 ]]
    then
        configurationArguments="${configurationArguments}--cugan-variant noise_1 "
    elif [[ $noiseLevel -eq 4 ]]
    then
        configurationArguments="${configurationArguments}--cugan-variant noise_2 "
    elif [[ $noiseLevel -eq 5 ]]
    then
        configurationArguments="${configurationArguments}--cugan-variant noise_3 "
    fi

    #Upscale level
    if [[ $upscaleLevel -eq 1 ]]
    then
        configurationArguments="${configurationArguments}--cugan-scale 2"
    elif [[ $upscaleLevel -eq 2 ]]
    then
        configurationArguments="${configurationArguments}--cugan-scale 3"
    elif [[ $upscaleLevel -eq 3 ]]
    then
        configurationArguments="${configurationArguments}--cugan-scale 4"
    fi

    #scale the intensity by dividing by 10
    intensity=$(echo "scale=1; ${intensity}/10" | bc)
    echo "${configurationArguments} --cugan-intensity $intensity"
}

#Gets a model based on the integer value of the user selection.
GetModelSelection () {
    if [[ $1 -eq 1 ]]
    then
        echo "-m srcnn_anime "
    elif [[ $1 -eq 2 ]]
    then
        echo "-m srcnn_photo "
    elif [[ $1 -eq 3 ]]
    then
        echo "-m cunet_anime "
    elif [[ $1 -eq 4 ]]
    then
        echo "-m pan_anime "
    elif [[ $1 -eq 5 ]]
    then
        echo "-m real_esrgan"
    elif [[ $1 -eq 6 ]]
    then
        echo "-m real_cuga"
    fi
}

#Builds a final argument configuration, based on user selections.
function GenerateFinalConfiguration () {
    fullyConfiguredArguments=""
    if [[ $1 -eq 1 ]]
    then
        BasicModelConfigureNoiseReduction
        local noiseReduction=$?
        echo "Noise reduction : $noiseReduction"

        BasicModelConfigureUpscaleLevel
        local upscaleLevel=$?

        basicConfiguration=$(BuildBasicConfiguration $noiseReduction $upscaleLevel)
        fullyConfiguredArguments="-m srcnn_anime $basicConfiguration"
    elif [[ $1 -eq 2 ]]
    then
        BasicModelConfigureNoiseReduction
        local noiseReduction=$?
        echo "Noise reduction : $noiseReduction"

        BasicModelConfigureUpscaleLevel
        local upscaleLevel=$?

        basicConfiguration=$(BuildBasicConfiguration $noiseReduction $upscaleLevel)
        fullyConfiguredArguments="-m srcnn_photo $basicConfiguration"
    elif [[ $1 -eq 3 ]]
    then
        BasicModelConfigureNoiseReduction
        local noiseReduction=$?
        echo "Noise reduction : $noiseReduction"

        BasicModelConfigureUpscaleLevel
        local upscaleLevel=$?

        basicConfiguration=$(BuildBasicConfiguration $noiseReduction $upscaleLevel)
        fullyConfiguredArguments="-m cunet_anime $basicConfiguration"
    elif [[ $1 -eq 4 ]]
    then
        BasicModelConfigureNoiseReduction
        local noiseReduction=$?
        echo "Noise reduction : $noiseReduction"

        BasicModelConfigureUpscaleLevel
        local upscaleLevel=$?

        basicConfiguration=$(BuildBasicConfiguration $noiseReduction $upscaleLevel)
        fullyConfiguredArguments="-m pan_anime $basicConfiguration"
    elif [[ $1 -eq 5 ]]
    then
        EsrganConfigureVariant
        local esrganConfiguration=$?

        additionalArguments=$(BuildEsrganConfiguration $esrganConfiguration)
        fullyConfiguredArguments="-m real_esrgan $additionalArguments"
    elif [[ $1 -eq 6 ]]
    then
        CuganConfigureNoiseLevel
        local noiseLevel=$?

        CuganConfigureUpscaleLevel
        local upscaleLevel=$?

        CuganConfigureIntensity
        local intensity=$?

        additionalArguments=$(BuildCuganConfiguration $noiseLevel $upscaleLevel $intensity)
        fullyConfiguredArguments="-m real_cugan $additionalArguments"
    fi
}

#Gets the global configuration, as set by the user.
function GetFinalConfiguration () {
    echo "$fullyConfiguredArguments"
}

#Gets an integer value representing the desired output resolution
#as defined by user selections.
function GetUpscaleResolutionScalar () {
    echo "Resolution scalar is set to $resolutionScalar"
    return $resolutionScalar
}