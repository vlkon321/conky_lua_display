### Conky Lua Display
is an attempt to fit whole TEXT section of conky config file into a lua script.  
Why? Because I want and I can. Also I wanted to play with text transparency an graph distortion but conky can't do that on its own.


You should probably go through `conky_meter.lua` and change number of CPU cores (and corresponding _iter_ parameters);  
remove/change _/storage_ in HDD section;  
network interface in master_settings;  
and if you don't have Nvidia graphic card then you should probably completely disable GPU in master_settings

Place everything from _conky_ into _$HOME/.config/conky/_  
Launch `conky_start.sh` after login to display clock and other monitors.

If you modify any file then restart it with `killall conky` and then execure `conky_start.sh` again.  
There are some settings that may cause problems otherwise.


SinceI am not exactly skilled with lua and cairo the script is a mess that doesn't hold a consistent format, anotation and syntax.  
But if you feel lucky you may try to read through the code and definitely make it less demanding on PC resources.  
Although it is not really noticeable on my hardware I would definitely appreciate some optimising of the code.

</br>

__Note:__ This package also include content from other authors (and therefore have its own licensing).  
Fonts used in conky scripts are all packed in _fonts_.  
Just upack it where you usually store fonts (commonly _/usr/share/fonts_).  
Or better yet install them from your repositories if you have that option.  
I've got them from these websites:  
[Liberation Sans](https://fontlibrary.org/en/font/liberation-sans), [Liberation Serif](https://fontlibrary.org/en/font/liberation-serif), [Liberation Mono](https://fontlibrary.org/en/font/liberation-mono), [Petit Formal Script](https://fontlibrary.org/en/font/petit-formal-script), [Alex Brush](https://fontlibrary.org/en/font/alex-brush)
