# RecordingAndOutputFrames

---
2022/11/17

因為PreviewLayer無法拓展到指定的UIView上，
所以參考了別人的做法，
整理出CameraController控制相機相關的方法。

MediaHandler就留下處理和CameraController無關的功能。

---
2022/11/15

此Project包含了兩個部分

1.使用相機錄影畫面，並儲存到暫存的位置。

2.將暫存的影片切成UIImage陣列

因為有個影像傳遞的需求是是要將影片轉成JPG陣列再傳輸，
所以做了這樣的研究。

---
測試使用XCode內建的套件，
達到錄影&每一個Frame輸出成UIImage的功能。