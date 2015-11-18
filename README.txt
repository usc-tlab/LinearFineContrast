This folder contains:

1) BRCal
Matlab functions for achieving linearized high-precision (>9 btis) luminance contrast control
on CRTs using a video attenuator (Pelli & Zhang, 1991; Li et al., 2003) to commbine voltages 
from the R and B channel to a single video channel.

This code is based on Matlab functions provided by Zhong-Lin Lu (filename starts with BR) and 
extended by Bosco Tjan.

To calibrate a CRT, run BRCal/BRCalibrator.m

To use BRCal, start with initscreen.m.  See main.m for a demo.

References:
Pelli, D. G., & Zhang, L. (1991). Accurate control of contrast on microcomputer displays. Vision Research, 31, 1337–1350. 
Li X, Lu ZL, Xu P, Jin J, Zhou Y (2003) Generating high gray-level resolution monochrome displays with conventional computer graphics cards and color monitors. Journal of neuroscience methods 130:9-18.

2) main.m
This is a toy visual psychophysics experiment aim to (1) provide a common coding style for TLab 
and (2) demonstrate how to use BRCal. It requires the PsychToolbox (http://psychtoolbox.org).

Credits and history are provided in the source files. BT = Bosco Tjan (btjan@usc.edu)
