
import 'package:MusicApp/Feature/mp3Access.dart';
import 'package:flutter/material.dart';

import 'package:flute_music_player/flute_music_player.dart';

import 'Custom/sizeConfig.dart';

// import 'package:flutter_svg/flutter_svg.dart';

//import 'main.dart';

enum PlayerState { stopped, playing, paused }
enum PlayerMode { shuffle, repeat, normal }

Song song;

class MusicPlayer extends StatefulWidget {
  final Mp3Access fileData;
  final Song _song;
  final bool nowPlaying;
  MusicPlayer(this.fileData, this._song, {this.nowPlaying});

  @override
  MusicPlayerState createState() => MusicPlayerState();
}

class MusicPlayerState extends State<MusicPlayer> {
  
//Package Music
  MusicFinder audioPlayer;
  Duration duration;
  Duration position;
  PlayerState playerState;
  PlayerMode playerMode;

  get currentSong => song;

  get isPlaying => playerState == PlayerState.playing;
  get isPaused => playerState == PlayerState.paused;

  get isShuffle => playerMode == PlayerMode.shuffle;
  get isRepeat => playerMode == PlayerMode.repeat;

  get durationText =>
      duration != null ? duration.toString().split('.').first : '';
  get positionText =>
      position != null ? position.toString().split('.').first : '';

  set playMode(int mode){
    if (mode == 0)
      setState(() {
        playerMode = PlayerMode.normal;
      });
    else if (mode == 1)
      setState(() {
        if (!isRepeat)
          playerMode = PlayerMode.repeat;
        else
          playerMode = PlayerMode.normal;
      });
    else 
      setState(() {
        if (!isShuffle)
          playerMode = PlayerMode.shuffle;
        else
          playerMode = PlayerMode.normal;
      });
  }

  initPlayer() async {
    if (audioPlayer == null) {
      audioPlayer = widget.fileData.audioPlayer;
    }
    setState(() {
      song = widget._song;
      if (widget.nowPlaying == null || widget.nowPlaying == false)
        if (playerState != PlayerState.stopped) 
          stop();
    });
    
    audioPlayer.setDurationHandler((d) => 
      setState(() {
        duration = d;
      }));

    audioPlayer.setPositionHandler((p) => 
      setState(() {
          position = p;
      }));

    audioPlayer.setCompletionHandler(() {
      onComplete();
      setState(() {
        position = duration;
      });

    });

    audioPlayer.setErrorHandler((msg) {
      setState(() {
        playerState = PlayerState.stopped;
        duration = new Duration(seconds: 0);
        position = new Duration(seconds: 0);
      });
    });
  }

  Future play(Song s) async {
    if (s != null) {
      final result = await audioPlayer.play(s.uri, isLocal: true);
      if (result == 1)
        setState(() {
          playerState = PlayerState.playing;
          song = s;
        });
    }
  }

  Future pause() async {
    final result = await audioPlayer.pause();
    if (result == 1) setState(() => playerState = PlayerState.paused);
  }

  Future stop() async {
    final result = await audioPlayer.stop();
    if (result == 1)
      setState(() {
        playerState = PlayerState.stopped;
        position = new Duration();
      });
  }

  Future next(Mp3Access f) async {
    stop();
    setState(() {
      song = f.nextSong;
      play(song);
    });
  }

  Future prev(Mp3Access f) async {
    stop();
    setState(() {
      song = f.prevSong;
      play(song);
    });
  }

  void onComplete() {
    setState(() => playerState = PlayerState.stopped);
    if (isRepeat) 
      play(song);
    else if (isShuffle) {
      play(widget.fileData.randomSong);   
    }
    else
      play(widget.fileData.nextSong);
  }

//--------------------------------

  double value = 0.0; // Track current music
  bool pauseState = true;

// Button play
  Icon iconPlay = Icon(
    Icons.play_circle_filled,
    color: Colors.white,
  );
// Button pause
  Icon iconPause = Icon(
    Icons.pause_circle_filled,
    color: Colors.white,
  );

  @override
  void initState() {
    super.initState();
    initPlayer();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container();
  }

}
