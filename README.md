# ppidump :desktop_computer:
## Deets
A small mac command to find the Pixels Per Inch (ppi/Pixel Density) of every connected display. It calculates the data using physical resolution, so it shouldn't make any mistakes from retina-scaling.

I threw it together in, like, an hour. It's written in Swift because why not.

## Building
Just run `make`. Boom, your done.
## Usage
The command defaults to printing all display info, but you can manually input data using
```
ppidump [width_px height_px diag_size]
```
For example, like
```
ppidump 2560 1440 24.5
```
## Example Output

```
$ ./ppidump

Built-in Retina Display (2560x1600 Physical at 13.3") = 227 ppi
LG HDR QHD (2560x1440 Physical at 31.5") = 93 ppi
DELL U2415 (1920x1200 Physical at 24.0") = 94 ppi
```
Display names are printed in cyan :wink:
