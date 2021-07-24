# amdgpu-fancontrol

> A simple bash script to control the fan speed of AMD graphics cards

This is a simple bash script to control the fan speed of AMD graphics cards.
The project has originally been forked from
[grmat/amdgpu-fancontrol][original-project] and adjusted for my needs as a
temporary tool to use while I work on my own, more elaborate solution. As such,
I didn't invest much time to bring this up to my personal standards in regards
to documentation, installation and ease of use.

The script can be configured via `/etc/amdgpu-fancontrol.cfg`
([example configuration](etc-amdgpu-fancontrol.cfg)). A
[systemd service configuration](amdgpu-fancontrol.service) as well as a
[PKGBUILD](PKGBUILD) for Arch-based distributions are available.

## My changes

+ By default, `temp2_input` is used, which should be the junction temperature
  on RX 5xxx series cards and newer. This temperature represents the hottest
  point at any given moment and is also what is used to control custom fan
  curves under Windows
+ By default, a more aggressive fan curve is used (40% at 60 °C, 50% at 65 °C,
  75% at 80 °C, 100% at 95 °C). I have removed fan stop altogether as it
  doesn't seem to work when the fan mode is set to manual (at least on my RX
  6900 XT). I usually just run with automatic fan mode and only use the custom
  fan curve when I stress the card (e.g., when gaming). That way, I can still
  use fan stop during regular desktop usage
+ Changed the hysteresis value (the temperature drop required before the script
  lowers the fan speed) from 6 °C to 4 °C
+ The systemd unit will attempt to restart up to 6 times if it fails (e.g., if
  the hwmon paths are not yet available during boot), pausing 5 seconds after
  each attempt
+ Added a failsafe in case the temperature readout suddenly becomes
  unavailable: it first sets (or attempts to set) the fan speed to 100%, waits
  3 seconds and finally sets the fan mode back to automatic and exits
+ Further quieted down the output when not using debug mode to prevent journal
  spam
+ Disabled debug mode by default

[original-project]: https://github.com/grmat/amdgpu-fancontrol
[pwm-bug]: https://gitlab.freedesktop.org/drm/amd/-/issues/1164
[pwm-bug-explained]: https://gitlab.freedesktop.org/drm/amd/-/issues/1164#note_599349
