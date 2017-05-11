# Windows Text Rendering Profiler

I wrote this tool due to a bug I discovered in the Windows 10 creators edition release which causes a massive (x20-x50) slowdown in text rendering when using the ExtTextOutW or DrawTextExW WinAPI functions with a large font size.

I created a stack exchange discussion to see if there's a work-around for this issue:
http://stackoverflow.com/questions/43895435/exttextoutw-x50-performance-drop-on-qhd-4k-screens-after-windows-creators-editio

Download the compiled executable here:
http://zoomplayer.com/dl/WinTextRendererProfiler100.zip

Notes:
The log file is saved to "c:\Log", create the folder if you want to save detailed log files.
In order to prevent disk access from affecting the profiling, log entries are saved into memory until you click the 'save log file' button or close the application.
