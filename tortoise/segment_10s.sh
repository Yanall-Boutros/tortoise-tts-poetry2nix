ffmpeg -i $1 -f segment -segment_time 10 output_%03d.wav
