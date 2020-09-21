<p align="center">
<img src="https://i.imgur.com/WLz38p7.png" alt="App Icon" width=64 height=64>

# NYU Mobility

NYU Mobility is a tracking application built for iOS (in Swift), used to track mobility movement. 
Using gyroscope sensors and GPS tracking services, the app tracks steps taken, orientation,
and GPS location at different points of time. The data that is collected, is given to researchers and specialists.

## How to Use

### Registration

Users select whether they are a specialist or a client when they start up the app for the first time.

<img src="https://i.imgur.com/4705Gvm.png" alt="Registration page" width=350>

If a user is a specialist, a unique code will be presented. This code is for clients to connect with their specialists.

<img src="https://i.imgur.com/W9Sye43.png" alt="Generated code example" width=350>

### Tracking

All a client needs to do to track a session is tap on the start button. They can stop at any given point by tapping the stop button.
Once a session is completed, the client can share the video with their specialist, currently through email.
<img src="https://i.imgur.com/4705Gvm.png" alt="Tracking a session" width=350>
<img src="https://i.imgur.com/uZaV36a.png" alt="Sharing and downloading a session" width=350>

Specialists can have multiple clients, so when they open up the app, they will have to select a client to work with.

<img src="https://i.imgur.com/HtK5173.png" alt="All patients" width=350>

Specialists also have an additional form of visual tracking. The visual tracking option offers the same JSON file as the client tracking
feature, but also offers a video with it. It can be used to track where the user goes, and see what movements should be noted. To access this
mode, there is a small bar at the bottom of the tracking controller to switch modes. Specialists can see their 
sessions on the upper right hand corner of their tracking screen.

<img src="https://i.imgur.com/9d596yn.png" alt="All sessions" width=350>

Specialists also have access to the session tracking without visuals, just like the clients.

<img src="https://i.imgur.com/TItRZ3j.png" alt="All sessions" width=350>

## Sample Data

This is what a sample result file will look like:

```json
[
  {
    "coordinates" : {
      "long" : [
        -122.39774834243978,
        -122.39775186831477,
        -122.39775307745653,
        -122.39774992768537,
        -122.39774480977732,
        -122.39771817788204,
        -122.3976953467614,
        -122.39767339618678,
        -122.39765101235834,
        -122.39764084524997,
        -122.39764758245487
      ],
      "lat" : [
        37.601402633790364,
        37.601402981699991,
        37.601403101009964,
        37.601371141411661,
        37.601392699959362,
        37.601354143559462,
        37.601327463623619,
        37.601305485049295,
        37.601286924471076,
        37.60126849328293,
        37.601266114056969
      ]
    },
    "time" : "2020-07-27 09:28:55",
    "steps" : 16,
    "distance" : 20,
    "avgPace" : 0.24452209472656772,
    "currCad" : 0,
    "currPace" : 0
  },
  {
    "currPace" : 0,
    "coordinates" : {
      "lat" : [
        37.601272666522789
      ],
      "long" : [
        -122.39764153328159
      ]
    },
    "gyroData" : {
      "y" : [
        -0.27315562963485718
      ],
      "z" : [
        -0.27126932144165039
      ],
      "x" : [
        -0.28011873364448547
      ]
    },
    "distance" : 20,
    "steps" : 16,
    "time" : "2020-07-27 09:28:55",
    "avgPace" : 0.3852367401123129,
    "currCad" : 0
  }
]
```
