#! /bin/bash

################################################################################################################
#                                                                                                              #
#    #### ##    ##  ######  ######## ########  ##     ##  ######  ######## ####  #######  ##    ##  ######     #
#     ##  ###   ## ##    ##    ##    ##     ## ##     ## ##    ##    ##     ##  ##     ## ###   ## ##    ##    #
#     ##  ####  ## ##          ##    ##     ## ##     ## ##          ##     ##  ##     ## ####  ## ##          #
#     ##  ## ## ##  ######     ##    ########  ##     ## ##          ##     ##  ##     ## ## ## ##  ######     #
#     ##  ##  ####       ##    ##    ##   ##   ##     ## ##          ##     ##  ##     ## ##  ####       ##    #
#     ##  ##   ### ##    ##    ##    ##    ##  ##     ## ##    ##    ##     ##  ##     ## ##   ### ##    ##    #
#    #### ##    ##  ######     ##    ##     ##  #######   ######     ##    ####  #######  ##    ##  ######     #
#                                                                                                              #
################################################################################################################
#
# Script Assumptions
# * Bedrock Server runs within a screen session
# * This script is allowed to kill all running screen sessions. This behavior can be altered if Bedrock Server is running in a named session by uncommenting and editing line 68 and removing line 67.
# * You have created a run.sh file that starts your Bedrock Server and run.sh is located in the Bedrock Server directory
#
#
#
# 
# Set the following variables before first use 
#
# Where can the script download the Bedrock Server zip files. This is how the script tracks the current running version.
downloadlocation=
# Example   downloadlocation=/home/minecraft/downloads

# Where should Bedrock Server run. This directory will be removed each time the Bedrock Server is upgraded.
serverlocation=
# Example   serverlocation=/home/minecraft/minecraftserver

# Where should server backups be copied to. Important data will be copied here, then copied back after the server upgrade is complete.
backuplocation=
# Example   backuplocation=/home/minecraft/server_backups

# Set line 38 to yes and set your Pushover details in order to receive Pushover notifications when this script runs
sendpushover=no
pushovertoken=
pushoveruser=

################################################################################################################
# No need to edit below this line unless instructed to

payloadurl=$(curl -s -H "authority: minecraft.azureedge.net" -H "upgrade-insecure-requests: 1" -H "user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36" -H "accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9" -H "sec-fetch-site: cross-site" -H "sec-fetch-mode: navigate" -H "sec-fetch-user: ?1" -H "sec-fetch-dest: document" -H "referer: https://www.minecraft.net/" -H "accept-language: en-US,en;q=0.9" --compressed https://www.minecraft.net/en-us/download/server/bedrock | grep -o -m 1 -E 'https.+linux.+zip')
newfilename=$(echo $payloadurl | grep -oE '[^/]+$')
fileextension=$(echo $newfilename | grep -oE '\.[^.]*$')
newfilenameshort=$(basename $newfilename $fileextension)
targetfilename="$downloadlocation/${newfilename}"
if [[ -f "$targetfilename" ]]; then

        echo "File already present in Downloads, no further action needed"
		if [ sendpushover -eq "yes" ]; then
			curl -s -F "token=pushovertoken" -F "user=pushoveruser" -F "title=Minecraft Server" -F "message=Upgrade appears to not be needed" https://api.pushover.net/1/messages.json > /dev/null
		fi
else


        echo " _____ _                    _              "
        echo "/  ___| |                  (_)             "
        echo "\ \`--.| |_ ___  _ __  _ __  _ _ __   __ _  "
        echo " \`--. \ __/ _ \| '_ \| '_ \| | '_ \ / _\` | "
        echo "/\__/ / || (_) | |_) | |_) | | | | | (_| | "
        echo "\____/ \__\___/| .__/| .__/|_|_| |_|\__, | "
        echo "               | |   | |             __/ | "
        echo "               |_|   |_|            |___/  "
        pkill screen
		#screen -S minecraftsession -p 0 -X quit

        echo "______                    _                 _ _             "
        echo "|  _  \                  | |               | (_)            "
        echo "| | | |_____      ___ __ | | ___   __ _  __| |_ _ __   __ _ "
        echo "| | | / _ \ \ /\ / / '_ \| |/ _ \ / _\` |/ _\` | | '_ \ / _\` |"
        echo "| |/ / (_) \ V  V /| | | | | (_) | (_| | (_| | | | | | (_| |"
        echo "|___/ \___/ \_/\_/ |_| |_|_|\___/ \__,_|\__,_|_|_| |_|\__, |"
        echo "                                                       __/ |"
        echo "                                                      |___/ "
        echo "File not present in Downloads, will download now"
        wget $payloadurl -P $downloadlocation

        echo " _   _           _             _             "
        echo "| | | |         (_)           (_)            "
        echo "| | | |_ __  _____ _ __  _ __  _ _ __   __ _ "
        echo "| | | | '_ \|_  / | '_ \| '_ \| | '_ \ / _\` |"
        echo "| |_| | | | |/ /| | |_) | |_) | | | | | (_| |"
        echo " \___/|_| |_/___|_| .__/| .__/|_|_| |_|\__, |"
        echo "                  | |   | |             __/ |"
        echo "                  |_|   |_|            |___/ "
        unzip -q $targetfilename -d $downloadlocation/$newfilenameshort


        echo "______            _    _               _   _       "
        echo "| ___ \          | |  (_)             | | | |      "
        echo "| |_/ / __ _  ___| | ___ _ __   __ _  | | | |_ __  "
        echo "| ___ \/ _\` |/ __| |/ / | '_ \ / _\` | | | | | '_ \ "
        echo "| |_/ / (_| | (__|   <| | | | | (_| | | |_| | |_) |"
        echo "\____/ \__,_|\___|_|\_\_|_| |_|\__, |  \___/| .__/ "
        echo "                                __/ |       | |    "
        echo "                               |___/        |_|    "
        cp -f $serverlocation/banned-ips.json $backuplocation
        cp -f $serverlocation/banned-players.json $backuplocation
        cp -f $serverlocation/ops.json $backuplocation
        cp -f $serverlocation/server.properties $backuplocation
        cp -rf $serverlocation/world $backuplocation
        cp -rf $serverlocation/worlds $backuplocation
        cp -f $serverlocation/run.sh $backuplocation
        rm -rf $backuplocation/minecraftserver-old/
        cp -r $serverlocation $backuplocation/minecraftserver-old
        rm -rf $serverlocation/*


        echo "_   _                           _ _             "
        echo "| | | |                         | (_)            "
        echo "| | | |_ __   __ _ _ __ __ _  __| |_ _ __   __ _ "
        echo "| | | | '_ \ / _\` | '__/ _\` |/ _\` | | '_ \ / _\` |"
        echo "| |_| | |_) | (_| | | | (_| | (_| | | | | | (_| |"
        echo "\___/| .__/ \__, |_|  \__,_|\__,_|_|_| |_|\__, |"
        echo "      | |     __/ |                         __/ |"
        echo "      |_|    |___/                         |___/ "
        cp -r $downloadlocation/$newfilenameshort/* $serverlocation/


        echo "______          _             _             "
        echo "| ___ \        | |           (_)            "
        echo "| |_/ /___  ___| |_ ___  _ __ _ _ __   __ _ "
        echo "|    // _ \/ __| __/ _ \| '__| | '_ \ / _\` |"
        echo "| |\ \  __/\__ \ || (_) | |  | | | | | (_| |"
        echo "\_| \_\___||___/\__\___/|_|  |_|_| |_|\__, |"
        echo "                                       __/ |"
        echo "                                      |___/ "
        cp -f $backuplocation/banned-ips.json $serverlocation
        cp -f $backuplocation/banned-players.json $serverlocation
        cp -f $backuplocation/ops.json $serverlocation
        cp -f $backuplocation/server.properties $serverlocation
        cp -rf $backuplocation/world $serverlocation/
        cp -rf $backuplocation/worlds $serverlocation/
        cp -f $backuplocation/run.sh $serverlocation


        echo " _____ _                  _               _   _       "
        echo "/  __ \ |                (_)             | | | |      "
        echo "| /  \/ | ___  __ _ _ __  _ _ __   __ _  | | | |_ __  "
        echo "| |   | |/ _ \/ _\` | '_ \| | '_ \ / _\` | | | | | '_ \ "
        echo "| \__/\ |  __/ (_| | | | | | | | | (_| | | |_| | |_) |"
        echo " \____/_|\___|\__,_|_| |_|_|_| |_|\__, |  \___/| .__/ "
        echo "                                   __/ |       | |    "
        echo "                                  |___/        |_|    "
        rm -rf $downloadlocation/$newfilenameshort


        echo " _____ _             _   _                 "
        echo "/  ___| |           | | (_)                "
        echo "\ \`--.| |_ __ _ _ __| |_ _ _ __   __ _    "
        echo " \`--. \ __/ _\` | '__| __| | '_ \ / _\` | "
        echo "/\__/ / || (_| | |  | |_| | | | | (_| |    "
        echo "\____/ \__\__,_|_|   \__|_|_| |_|\__, |    "
        echo "                                  __/ |    "
        echo "                                 |___/     "
        screen -d -m -S minecraftsession bash -c 'cd $serverlocation && ./run.sh'
		if [ sendpushover -eq "yes" ]; then
			curl -s -F "token=$pushovertoken" -F "user=$pushoveruser" -F "title=Minecraft Server Upgraded" -F "message=Aren't you glad you didn't have to do it by hand?" https://api.pushover.net/1/messages.json > /dev/null
		fi
fi



# MIT License
#
# Copyright (c) 2021 mysterious1der
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
