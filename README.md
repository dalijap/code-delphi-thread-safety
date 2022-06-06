# Code examples from Delphi Thread Safety Patterns Book

[https://dalija.prasnikar.info/delphitspatt/](https://dalija.prasnikar.info/delphitspatt/)

[https://dalija.prasnikar.info](https://dalija.prasnikar.info)


## Part 2. The Core Run-Time Library

### Chapter 5. Floating-point control register 

  + BrokenMath.dpr
  + BrokenMath.dproj
  + SafeMath.dpr
  + SafeMath.dproj

## Part 3. Core Frameworks 

### Chapter 16. Serialization 

  + Serialization.dpr
  + Serialization.dproj
  + SerializationMainF.pas
  + SerializationMainF.dfm

### Chapter 17. System.Net 

  + NetClient.dpr
  + NetClient.dproj
  + NetClientMainF.pas
  + NetClientMainF.dfm
 
### Chapter 19. Indy 

  + Indy.dpr
  + Indy.dproj
  + IndyMainF.pas
  + IndyMainF.dfm

### Chapter 20. REST 

  + RESTDemo.dpr
  + RESTDemo.dproj
  + RESTMainF.pas
  + RESTMainF.dfm

### Chapter 21. Regular expressions 

  + RegEx.dpr


## Part 5. Graphics and Image Processing 

### Chapter 27. Resource consumption 

  + Resources.dpr
  + Resources.dproj
  + ResourcesMainF.pas
  + ResourcesMainF.dfm

### Chapter 30. VCL graphics example 

  + Images.dpr
  + Images.dproj
  + ImagesMainF.pas
  + ImagesMainF.dfm


## Part 6. Custom Frameworks 

### Chapter 33. Logging 

  + NX.Log.pas 
  + Logging.dpr
  + Logging.dproj

### Chapter 34. Cancellation tokens 

  + NX.Tokens.pas 
  + Tokens.dpr
  + Tokens.dproj
  + TokensMainF.pas
  + TokensMainF.dfm

### Chapter 35. Event bus 

  + NX.Horizon.pas 
  + Horizon.dpr
  + Horizon.dproj
  + HorizonMainF.pas
  + HorizonMainF.dfm

### Chapter 36. Measuring performance 

  + NX.Chronos.pas
  + ZeroThread.dpr
  + ZeroThread.dproj

---
  
Note: Purpose of the presented examples is to either show thread-unsafe code and
issues that may arise in such code, or to show general coding patterns for
achieving thread-safe code while multiple threads are running. As such many of
them don't implement proper cleanup on application shutdown, and if you close the
application before started background tasks or threads completed their job,
application may crash.

In order to perform clean shutdown, you either need to wait for task or thread
completion or use some other mechanism that will prevent accessing GUI or
other shared data during application shutdown.

You can find examples on how to shutdown application in https://github.com/dalijap/code-delphi-async Chapter 35.2 Cleanup on GUI destruction
