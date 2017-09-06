# OSU-automapping
An auto-mapping AI for OSU!

## What's OSU!

OSU! is a rhythm/music game. Link : osu.ppy.sh/

OSU gameplay is based on the beatmap, where circles, sliders and spinners are placed. Players click or drag or spin the objects at the right place and time.

OSU! has a huge beatmap library which is created by game players themselves. With the in-game edit function, everyone can 'map' a song, then uploading to the game server.

OSU! has a community to promote users communication, where uploaded beatmaps are tested and modified. Not all beatmaps are admitted by player group or official ranking system, while the "ranked" beatmaps do. Through this system, over 100000 beatmaps are accounted as "ranked", each of which has a splendid high quality.

## What's OSU-automapping

OSU-automapping is meant to be created to "map" any songs by Artificial Intelligence. The audio file will be considered as the input, and a new beatmap will be as output.

Neural network will be used to help this system learning the existed ranked beatmaps.

## Who is Frostofwinter

God

## What is FrOstNova

FrostNova is a model to realized automapping by (perhaps recurrent) convolution neural network(CNN), where the input is the spectrogram at the time region ![](http://latex.codecogs.com/gif.latex?[t_k-\\delta t, t_k+\\delta t]) of the given song, and the output/target is a 3-dimensional 1-or-0 vector \{isCircle,isSliderHead,isSliderEnd\}
