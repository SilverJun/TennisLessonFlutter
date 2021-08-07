
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:flutter/services.dart';

class YoutubePage extends StatelessWidget {
  String videoId;
  YoutubePlayerController _controller;
  YoutubePage({this.videoId}) {
    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: YoutubePlayerFlags(
        autoPlay: true,
        controlsVisibleAtStart: true,
      ),
    );
    // _controller.play();
  }

  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    //   appBar: AppBar(
    //     title: Text('영상'),
    //   ),
    // body: SafeArea(
    //   child: YoutubePlayerBuilder(
    //     player: YoutubePlayer(
    //       controller: _controller,
    //     ),
    //     builder: (context, player) {
    //       return Column(
    //         children: [
    //           // some widgets
    //           player,
    //           //some other widgets
    //         ],
    //       );
    //     })
    //   ),
    //   //YoutubePlayer(controller: _controller),
    // );
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        topActions: [IconButton(onPressed: () {
          _controller.pause();
          // _controller.dispose();
          SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
          Navigator.pop(context);
          SystemChrome.setPreferredOrientations(DeviceOrientation.values);
        }, icon: Icon(Icons.close), color: Colors.white,)],
      ),
      builder: (context, player) {
        return SafeArea(
          child: Center(child: player,)
        );
      }
    );
  }

}