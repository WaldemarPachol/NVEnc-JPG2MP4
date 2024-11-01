# NVEnc-JPG2MP4
Multithreaded nvenc jpg to mp4 converter.

How to use:
1. Download the file and save it in the folder with the timelapse images for conversion.
2. The files should be named `0001.jpg`, `0002.jpg`, `0003.jpg`, and so on.
3. Open and edit the file `convert_jpg_to_mp4.sh`:

```
input_dir="."             # this is the input directory with JPG files, do not change this
output_file="output.mp4"  # this is the name of the output MP4 file :)
block_size=50             # this is the number of images in one processing block
max_instances=4           # this is the maximum number of concurrent ffmpeg instances,
video_bitrate="50M"       # this is the video bitrate
```
**Note:** Maximum number of concurrent ffmpeg instances, depending on your GPU's memory. For example, my GTX 1050 has 4GB of RAM, and max_instances is 5 for me. Above this value, I run out of memory, and the conversion is not performed correctly. If you see a lot of red text, reduce this value. 

4. Save the file and give it executable permissions.
5. Open a console and run in the console:
```
./convert_jpg_to_mp4.sh
```

If you enjoyed this code, consider sending $1 my way: https://www.paypal.com/paypalme/WaldemarPachol. Thanks a lot!

Have fun!
Waldemar
