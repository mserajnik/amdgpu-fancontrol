# amdgpu-fancontrol

Simple bash script to control AMD Radeon graphics cards fan pwm. Adjust
temp/pwm values and hysteresis/interval in the script as desired. Other
adjustments, such as the correct hwmon path might be required as well.

This script was initially meant as an example. Please don't just run it naively
and keep in mind that I'm not responsible for failures.

## Fork changes

__Note:__ Due to a bug, the current PWM value is not reported accurately (it
always shows 0) with the fan mode set to manual (so when using this script), at
least on some cards (including my RX 6900 XT). This doesn't mean this script
doesn't work correctly: adjusting the PWM value still works fine, it's just the
hwmon readback that's wrong (which has no influence on the functionality of the
script, aside from resulting in incorrect debug output). This issue will
supposedly be fixed in kernel 5.12. See [here][pwm-bug] for
details (particularly [this comment][pwm-bug-explained]).

+ By default, `temp2_input` is used, which should be the junction temperature
  on RX 5xxx series cards and newer. This temperature represents the hottest
  point at any given moment and is also what is used to control custom fan
  curves in Windows
+ By default, a more aggressive fan curve is used (40% at 60 °C, 50% at 65 °C,
  75% at 80 °C, 100% at 95 °C). I have removed fan stop altogether as it
  doesn't seem to work when the fan mode is set to manual (at least on my RX
  6900 XT). I usually just run with automatic fan mode only use the custom fan
  curve when I stress the card (e.g., when gaming). That way, I can still use
  fan stop during regular desktop usage
+ Changed the hysteresis value (the temperature drop required before the script
  lowers the fan speed) from 6 °C to 4 °C
+ The systemd unit will attempt to restart up to 6 times if it fails (e.g.,
  if the hwmon paths are not yet available during boot), pausing 5 seconds
  after each attempt
+ Added a failsafe in case the temperature readout suddenly becomes
  unavailable: it first sets (or attempts to set) the fan speed to 100%, waits
  3 seconds and finally sets the fan mode back to automatic and exits
+ Further quieted down the output when not using debug mode to prevent journal
  spam

[pwm-bug]: https://gitlab.freedesktop.org/drm/amd/-/issues/1164
[pwm-bug-explained]: https://gitlab.freedesktop.org/drm/amd/-/issues/1164#note_599349
