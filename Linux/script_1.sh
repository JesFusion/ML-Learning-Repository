#!/bin/bash


# path="$(pwd)/assignment/"

# timestamp="$(date +%d/%m/%Y,%H:%M)"


# mkdir -p $path


# # create=false?


# if false; then

#     cd $path
    
#     # create a new file...
#     > health_report.txt

#     {

#         echo "Run time: $timestamp"

#         echo -e "\nTop 5 processes by memory consumption\n"

#         ps -eo pid,user,%mem,comm --sort=-%mem | head -6 # -6 gives us the first 5

        
#         echo -e "\nTop 5 processes by CPU consumption\n"

#         ps -eo pid,user,%cpu,comm --sort=-%cpu | head -6


#     } > health_report.txt



# fi

# ps -eo pid,user,%mem,comm --sort=-%mem | head -6 # -6 gives us the first 5

ps -eo \
pid,\
user,\
%mem,\
comm \
--sort=-%mem | \
head -6









