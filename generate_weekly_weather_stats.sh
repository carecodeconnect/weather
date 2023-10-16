#!/bin/bash

# Script Name: Weekly Forecast Accuracy Evaluation
# Script:      generate_weekly_weather_stats.sh
# Description: This script analyzes historical forecast accuracy data from the past week,
#              extracting the relevant statistics and calculating the minimum and maximum
#              absolute errors. The data is sourced from a TSV file containing daily forecast
#              accuracy records, with the script specifically focusing on the last 7 entries.
# Usage:       ./generate_weekly_weather_stats.sh
# Note:        The script expects a TSV file named 'historical_forecast_accuracy.tsv' in the current directory,
#  	       which is created by fetch_weather_data.sh

# extract 6th field frm last 7 lines of data file
# write this data to scratch file

echo $(tail -7 historical_forecast_accuracy.tsv  | cut -f6) > scratch.txt

week_fc=($(echo $(cat scratch.txt)))

# Validate the results by printing each forecast accuracy entry from the array
echo "Forecast accuracies for the week:"
for i in {0..6}; do
    echo "Day $((i + 1)): ${week_fc[$i]} units"
done

# Process each forecast accuracy entry in the array
echo "Adjusting values to absolute numbers for comparison:"
for i in {0..6}; do
  if [[ ${week_fc[$i]} < 0 ]]
  then
  # If the forecast accuracy is negative, convert it to a positive value (absolute value)
    week_fc[$i]=$(((-1)*week_fc[$i]))
  fi
  # Validate the result by printing the adjusted forecast accuracy.
  echo "Day $((i + 1)) adjusted accuracy: ${week_fc[$i]} units"
done

# Initialize variables to store the minimum and maximum forecast accuracies, starting with the first entry in the array
minimum=${week_fc[1]}
maximum=${week_fc[1]}

# Iterate through each forecast accuracy entry in the array
for item in ${week_fc[@]}; do
   # If the current entry is less than the current minimum, update the minimum
   if [[ $minimum > $item ]]
   then
     minimum=$item
   fi
   # If the current entry is greater than the current maximum, update the maximum.
   if [[ $maximum < $item ]]
   then
     maximum=$item
   fi
done

# Display the minimum and maximum forecast accuracy values for the week.
echo "minimum absolute error = $minimum"
echo "maximum absolute error = $maximum"
