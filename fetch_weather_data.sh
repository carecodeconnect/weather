#! /bin/bash

# Script Name: fetch_weather_data.sh
# Version: 0.1.0
# Description: This script retrieves the current weather data for a specified location
#              (default is Berlin) from wttr.in, extracts critical temperature information,
#              and logs this data into a file for future reference and analysis. The script
#              is designed to capture both the current observed temperature and the forecasted
#              temperature for the next day, providing a basis for comparison and forecast accuracy analysis.
#
# Usage: ./fetch_weather_data.sh [Optional: Add usage instructions, if parameters can be passed or if the script
#        should be run at specific intervals/times]
#
# Inputs: None (The script could accept parameters for flexibility, such as the city for which
#         weather data is retrieved. If such enhancements are made, document them here.)
#
# Outputs:
#   - A raw data file containing the full weather report from wttr.in, named with the date of retrieval.
#   - A log entry in 'log_weather_data.log' containing the date, observed temperature, and forecasted temperature.
#
# Dependencies:
#   - Requires an active internet connection and relies on the availability of wttr.in.
#   - Requires tools such as curl, grep, and standard GNU core utilities (awk, sed, date, etc.).
#   - Assumes the script has the necessary permissions to create files in the working directory
#     and that sufficient space is available for these files.
#
# Error Handling: This version of the script does not include error handling and will not provide
#                 informative feedback or fail gracefully if wttr.in is unavailable or if expected
#                 outputs cannot be created. Future versions should incorporate comprehensive error checking.

# to start fresh, uncomment these three lines
# to continue once started, comment them
# create a header for the weather log file:
header=$(echo -e "year\tmonth\tday\tobs_tmp\tfc_temp")
echo $header>log_weather_data.log

# create a tab-delimited file called saved_forecast_accuracy.tsv
# using the following code to insert a header of column names:
echo -e "year\tmonth\tday\tobs_tmp\tfc_temp\taccuracy\taccuracy_range" > historical_forecast_accuracy.tsv

# use command substitution to create a datestamped filname (in YYYYMMDD format) for the raw wttr data
# to store a variable called today
today=$(date +%Y%m%d)
weather_report=raw_data_$today
city=Berlin

# use curl to download today's weather report from wttr.in
# use curl argument --output to write to file $weather_report instead of stdout
curl wttr.in/$city --output $weather_report

# use date command with command substitution to store current hour, day, month, and year in corresponding shell variables
# -u uses Coordinated Universal Time (UTC) for hour and day
hour=$(TZ='Germany/Berlin' date -u +%H)
day=$(TZ='Germany/Berlin' date -u +%d)
month=$(TZ='Germany/Berlin' date +%m)
year=$(TZ='Germany/Berlin' date +%Y)

# use grep to extract all lines containing temperatures from weather report and write to file temperatures.txt
# the first line should be the current temperature
grep °C $weather_report > temperatures.txt

# extract first line of the file using cat -A to make control characters visible
first_line=$(cat -A temperatures.txt | head -n 1)
#echo "The first line is $first_line "

# feed first line into cut using pipe
# set delimeter to ^ and extract field 5
# store in variable obs_tmp
obs_tmp=$(echo $first_line | cut -d "^" -f4)
#echo "The first cut is $obs_tmp "
# use regular expressions with grep to isolate temperature following character m
obs_tmp=$(echo $obs_tmp | grep -oP '(?<=m)[+-]?\d+') 
echo "The observed temperature in $city is $obs_tmp °C"

# failed tries to extract observed temperature
# obs_tmp=$(cat -A temperatures.txt | head -n 1 | cut -c 20-21)
# obs_tmp=$(cat -A temperatures.txt | head -1 | cut -d "^" -f4 | cut -d "m" -f2 )

# extract forecast temperature for noon tomorrow
# extract 3rd line
third_line=$(cat -A temperatures.txt | head -n 3 | tail -n 1)
#echo "The third line is $third_line "

fc_tmp=$(echo $third_line | cut -d "^" -f15)
#echo "The second cut is $fc_tmp "
# extract the forecast for noon tomorrow
fc_tmp=$(echo $fc_tmp | grep -oP '(?<=m)[+-]?\d+')
echo "The forecast temperature in $city is $fc_tmp °C"

# failed tries to extract the forecast for noon tomorrow
# fc_tmp=$(cat -A temperatures.txt | head -3 | tail -1 | cut -d "+" -f2 | cut -d "(" -f1 | cut -d "^" -f1 )
# fc_tmp=$(cat -A temperatures.txt | head -3 | tail -1 | cut -d "+" -f2 | cut -d "(" -f2 | cut -d "^" -f3 | cut -d "m" -f1 | cut -d ";" -f3 | cut -d "0" -f1 )

# create a tab-delimited record and merge fields into this variable
# corresponding to a single row, then append to weather log
record=$(echo -e "$year\t$month\t$day\t$obs_tmp\t$fc_tmp")
echo $record>>log_weather_data.log
