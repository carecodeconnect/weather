#! /bin/bash

# Initialise bash script with shebang

# Script Name: analyse_forecast_accuracy.sh
# Description: This script evaluates the accuracy of weather forecasts by comparing
#              the forecasted temperatures against the actual observed temperatures.
#              It extracts temperature data from specified log files, calculates the
#              difference between forecasted and actual figures, and categorizes the
#              accuracy of the forecast. Results, along with date information, are
#              appended to a historical accuracy file for record-keeping and analysis.
#
# Usage: ./analyse_forecast_accuracy.sh
# Note: The script is designed to be run daily, after the latest weather data (both
#       forecasted and observed temperatures) have been logged. It assumes a consistent
#       log file structure with forecasted temperatures logged one day in advance.
#
# Inputs:
#   - log_weather_data.log: Log file containing forecasted and observed temperatures. The script
#                 expects the last two lines to represent the relevant data for "yesterday"
#                 (forecasted) and "today" (observed).
#
# Outputs:
#   - saved_forecast_accuracy.tsv: A tab-separated file where each line corresponds to a
#                                 day's forecast accuracy data, including the date, observed
#                                 temperature, forecasted temperature, calculated accuracy,
#                                 and an accuracy category (excellent, good, fair, poor).
#
# Dependencies:
#   - Requires bash shell environment and standard GNU core utilities (echo, tail, head, cut, etc.).
#   - Assumes the 'log_weather_data.log' file exists in the current working directory and follows
#     the expected format.
#
# Error Handling: This script does not currently handle errors and will fail with unclear
#                 messaging if inputs are not as expected. Future improvements should include
#                 more robust error handling and input validation.

# extract yesterday's forecasted temperature from the weather log
yesterday_fc=$(tail -2 log_weather_data.log | head -1 | cut -d " " -f5)
echo "Yesterday's forecasted temperature was $yesterday_fc"

# extract today's observed temperature from the weather log
today_temp=$(tail -1 log_weather_data.log | cut -d " " -f4)

# calculate accuracy of forecast
accuracy=$(($yesterday_fc-$today_temp))

# print accuracy
echo "the difference between temperatures is $accuracy"

# use conditional statements to assign a label to each forecast based on its accuracy
if [ -1 -le $accuracy ] && [ $accuracy -le 1 ]
then
   accuracy_range=excellent
elif [ -2 -le $accuracy ] && [ $accuracy -le 2 ]
then
    accuracy_range=good
elif [ -3 -le $accuracy ] && [ $accuracy -le 3 ]
then
    accuracy_range=fair
else
    accuracy_range=poor
fi

echo "Forecast accuracy is $accuracy_range"

# append a record to historical forecast accuracy file

row=$(tail -1 log_weather_data.log)
year=$( echo $row | cut -d " " -f1)
month=$( echo $row | cut -d " " -f2)
day=$( echo $row | cut -d " " -f3)
echo -e "$year\t$month\t$day\t$today_temp\t$yesterday_fc\t$accuracy\t$accuracy_range" >> historical_forecast_accuracy.tsv
