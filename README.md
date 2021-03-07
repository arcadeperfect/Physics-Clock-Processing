# Physics-Clock-Processing

© 2020 Alex Harding

**Physics Clock**

This is the prototype code the project linked below is based on. It runs in Processing. Future versions of the project will run on a different platform, so this code will not be developed.

Set "mouseControll" to true to enable controll of gravity vector with mouse.  
Set "debug" to true for various visualisations to show what's going on.  

You can modify the "down" vector with any input you want, for example an IMU sensor, if you can find a way to access that data from processing. 

The most recent "hour" and "minute" number instances will not be allowed to fall off the screen until their replacements spawn. However they will not be actively removed, so you can end up with a lot of large "hour" instances if you leave it running for a long time. 

The color scheme can be changed in the "number" class. It is not an intuitive system, sorry. 

---

www.alexharding.io  
https://hackaday.io/project/176037-concrete-physics-clock  
https://github.com/arcadeperfect/Physics-Clock-Processing  

---

Processing  
https://processing.org/  

---

Originally based on Dan Shiffman's "boxes" example for his Box2D wrapper for processing:  
https://github.com/shiffman/Box2D-for-Processing/tree/master/Box2D-for-Processing/dist/box2d_processing/examples/Boxes
