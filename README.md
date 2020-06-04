<p align="center">
<img src="https://i.imgur.com/WLz38p7.png" alt="App Icon" width=64 height=64>

# NYU Mobility

NYU Mobility is a tracking application built for iOS (in Swift), used to track mobility movement. 
Using gyroscope sensors and GPS tracking services, the app tracks steps taken, orientation,
and GPS location at different points of time. The data that is tracked, is exported as a JSON
format, and is sent as an email to clinicians.

## How to Use

When the app is loaded for the very first time, an email is needed send out results.
If an email is not recorded, every time the app is loaded or a session is finished,
the pop up will ask for it.

To start the tracking, tap the screen once. To pause or resume, double tap the screen.
To finish the tracking, tap the screen to finish, in a tracking phase.
An email draft will be created, and sent with one click.

## Sample Data

This is what a sample result file will look like:

```json
[
  {
    "gyroData" : {
      "y" : [
        -7.3105683326721191,
        3.3047740459442139,
        0.61987042427062988,
        -4.6807045936584473,
        1.4731142520904541,
        2.6723716259002686,
        -2.674152135848999,
        6.2216396331787109,
        3.9273302555084229,
        -2.8058013916015625,
        5.6073040962219238,
        3.2976479530334473,
        -3.0928046703338623
      ],
      "z" : [
        -13.707607269287109,
        7.992732048034668,
        4.6650567054748535,
        -17.16522216796875,
        5.3620214462280273,
        10.450821876525879,
        -9.0638999938964844,
        3.8457601070404053,
        9.7794389724731445,
        -9.7465114593505859,
        4.6088643074035645,
        10.662748336791992,
        -7.1020655632019043
      ],
      "x" : [
        -5.8127603530883789,
        3.755112886428833,
        0.44787818193435669,
        -5.3479099273681641,
        4.4255795478820801,
        -1.1275120973587036,
        -0.89676862955093384,
        3.1764481067657471,
        -2.0343599319458008,
        0.45830231904983521,
        5.0250248908996582,
        1.8969517946243286,
        -0.54934251308441162
      ]
    },
    "time" : "2020-06-03 06:42:03",
    "coordinates" : {
      "lat" : [
        37.601277990742169,
        37.601276175518642,
        37.601275936076249
      ],
      "long" : [
        -122.39759052708706,
        -122.39759646688307,
        -122.39761069813927
      ]
    },
    "steps" : 28
  }
]

```
