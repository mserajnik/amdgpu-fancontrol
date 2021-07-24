#!/bin/bash

# amdgpu-fancontrol
# Copyright (C) 2018-present  grmat  https://github.com/grmat
# Copyright (C) 2021-present  Michael Serajnik  https://git.sr.ht/~mser

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.

# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

HYSTERESIS=4000   # in mK
SLEEP_INTERVAL=1  # in s
DEBUG=false

# set temps (in degrees C * 1000) and corresponding pwm values in ascending order and with the same amount of values
TEMPS=( 60000 65000 80000 95000 )
PWMS=(  102   128   191   255 )

# hwmon paths, hardcoded for one amdgpu card, adjust as needed
FILE_PWM=$(echo /sys/class/drm/card0/device/hwmon/hwmon?/pwm1)
FILE_FANMODE=$(echo /sys/class/drm/card0/device/hwmon/hwmon?/pwm1_enable)
FILE_TEMP=$(echo /sys/class/drm/card0/device/hwmon/hwmon?/temp2_input)

# load configuration file if present
[ -f /etc/amdgpu-fancontrol.cfg ] && . /etc/amdgpu-fancontrol.cfg

[[ -f "$FILE_PWM" && -f "$FILE_FANMODE" && -f "$FILE_TEMP" ]] || { echo "Invalid hwmon files" ; exit 1; }

# check if amount of temps and pwm values match
if [ "${#TEMPS[@]}" -ne "${#PWMS[@]}" ]
then
  echo "Amount of temperature and PWM values does not match"
  exit 1
fi

# checking for privileges
if [ $UID -ne 0 ]
then
  echo "Writing to sysfs requires privileges, relaunch as root"
  exit 1
fi

function debug {
  if $DEBUG; then
    echo $1
  fi
}

# set fan mode to max(0), manual(1) or auto(2)
function set_fanmode {
  echo "Setting fan mode to $1"
  echo "$1" > "$FILE_FANMODE"
}

function set_pwm {
  NEW_PWM=$1
  OLD_PWM=$(cat $FILE_PWM)

  debug "Current PWM: $OLD_PWM. Requested to set PWM to $NEW_PWM"
  if [ $(cat ${FILE_FANMODE}) -ne 1 ]
  then
    echo "Fan mode not set to manual"
    set_fanmode 1
  fi

  if [ -z "$TEMP_AT_LAST_PWM_CHANGE" ] || [ "$TEMP" -gt "$TEMP_AT_LAST_PWM_CHANGE" ] || [ $(($(cat $FILE_TEMP) + HYSTERESIS)) -le "$TEMP_AT_LAST_PWM_CHANGE" ]; then
    debug "Temperature at last change was $TEMP_AT_LAST_PWM_CHANGE"
    debug "Changing PWM to $NEW_PWM"
    echo "$NEW_PWM" > "$FILE_PWM"
    TEMP_AT_LAST_PWM_CHANGE=$(cat $FILE_TEMP)
  else
    debug "Not changing PWM, we just did at $TEMP_AT_LAST_PWM_CHANGE. Next change when below $((TEMP_AT_LAST_PWM_CHANGE - HYSTERESIS))"
  fi
}

function interpolate_pwm {
  i=0

  if [[ ! -f "$FILE_TEMP" || ! $(cat $FILE_TEMP) -gt 0 ]]; then
    # failsafe in case the temperature readout suddenly becomes unavailable
    echo "Cannot read temperature, starting emergency exit"
    emergency_exit
  fi

  TEMP=$(cat $FILE_TEMP)

  debug "Current temperature: $TEMP"

  if [[ $TEMP -le ${TEMPS[0]} ]]; then
    # below first point in list, set to min speed
    set_pwm "${PWMS[i]}"
    return
  elif [[ $TEMP -gt ${TEMPS[-1]} ]]; then
    # above last point in list, set to max speed
    set_pwm "${PWMS[-1]}"
    return
  fi

  for i in "${!TEMPS[@]}"; do
    if [[ $TEMP -gt ${TEMPS[$i]} ]]; then
      continue
    fi

    # interpolate linearly
    LOWERTEMP=${TEMPS[i-1]}
    HIGHERTEMP=${TEMPS[i]}
    LOWERPWM=${PWMS[i-1]}
    HIGHERPWM=${PWMS[i]}
    PWM=$(echo "( ( $TEMP - $LOWERTEMP ) * ( $HIGHERPWM - $LOWERPWM ) / ( $HIGHERTEMP - $LOWERTEMP ) ) + $LOWERPWM" | bc)
    debug "Interpolated PWM value for temperature $TEMP is: $PWM"
    set_pwm "$PWM"
    return
  done
}

function emergency_exit {
  echo "255" > "$FILE_PWM"
  sleep 3
  reset_on_exit
}

function reset_on_exit {
  echo "Exiting, resetting fan to auto control"
  set_fanmode 2
  exit 0
}

# always try to reset fans on exit
trap "reset_on_exit" SIGINT SIGTERM

function run_daemon {
  while :; do
    interpolate_pwm
    debug
    sleep $SLEEP_INTERVAL
  done
}

# set fan control to manual
set_fanmode 1

# finally start the loop
run_daemon
