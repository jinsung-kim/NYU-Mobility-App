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
    "gyroData" : {
      "x" : [
        2.0242891311645508,
        3.1933741569519043,
        1.5122534036636353,
        -3.437119722366333,
        4.7632288932800293,
        4.0083470344543457,
        -3.5545260906219482,
        0.60849845409393311,
        2.3982362747192383,
        -2.5304968357086182,
        4.3529486656188965,
        3.0652337074279785,
        -4.2357287406921387,
        1.6501470804214478,
        2.8467772006988525,
        -3.0719692707061768,
        2.0320093631744385,
        0.11020160466432571,
        -3.3018698692321777,
        -0.032294820994138718,
        6.0102472305297852,
        -1.0640404224395752,
        -4.755253791809082,
        -2.4443323612213135,
        3.9541590213775635,
        3.7154099941253662,
        -4.2859554290771484,
        -0.97794950008392334,
        3.8673045635223389,
        -2.880979061126709,
        -2.3622927665710449,
        0.36358940601348877,
        2.3354833126068115,
        -3.0840761661529541,
        -1.8954137563705444,
        1.6661965847015381,
        -1.6196908950805664,
        -2.4799821376800537,
        -1.4490232467651367,
        -0.16710510849952698,
        -0.256468266248703,
        -0.20047584176063538
      ],
      "z" : [
        2.2905783653259277,
        6.2936983108520508,
        5.1717309951782227,
        -6.9055190086364746,
        5.8047990798950195,
        5.0042901039123535,
        -7.7745094299316406,
        2.7402489185333252,
        5.3539028167724609,
        -9.036280632019043,
        6.4586377143859863,
        6.2261338233947754,
        -8.9224443435668945,
        3.7632908821105957,
        3.5357017517089844,
        -4.8612074851989746,
        1.9346016645431519,
        2.5939357280731201,
        -5.0436062812805176,
        0.1593523770570755,
        5.7329096794128418,
        2.1733846664428711,
        -7.5617227554321289,
        -2.1264255046844482,
        4.4163665771484375,
        2.7872951030731201,
        -3.6456966400146484,
        -0.56918090581893921,
        2.7984893321990967,
        -0.76226246356964111,
        -4.6241607666015625,
        1.7781417369842529,
        5.1546158790588379,
        -6.7424530982971191,
        -2.1681714057922363,
        6.4172496795654297,
        -0.33171668648719788,
        -5.1175823211669922,
        -2.5500240325927734,
        -0.32816961407661438,
        -0.37212029099464417,
        -0.25413107872009277
      ],
      "y" : [
        5.3428173065185547,
        2.0450360774993896,
        4.1075015068054199,
        -2.8811852931976318,
        4.0121631622314453,
        -0.077526219189167023,
        0.5255247950553894,
        1.3251231908798218,
        2.3102567195892334,
        -3.142413854598999,
        2.2499854564666748,
        2.9643149375915527,
        -1.2139759063720703,
        -0.42450493574142456,
        -0.54727905988693237,
        0.57215780019760132,
        0.11856020241975784,
        0.18112637102603912,
        -0.46939998865127563,
        -0.26302072405815125,
        -0.30582302808761597,
        -1.9451528787612915,
        0.024927454069256783,
        -0.21530911326408386,
        -1.2738152742385864,
        -0.24222861230373383,
        0.39643949270248413,
        -2.5068495273590088,
        3.2208175659179688,
        -1.7738889455795288,
        -0.0068152956664562225,
        -0.189596027135849,
        -0.71955949068069458,
        0.18109121918678284,
        -1.1433466672897339,
        -0.62830120325088501,
        -0.16922551393508911,
        -1.0379921197891235,
        -4.3040966987609863,
        -1.0636870861053467,
        -0.39560672640800476,
        0.37632143497467041
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
