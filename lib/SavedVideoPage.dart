import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flick_video_player/flick_video_player.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';


// metadata for saving video
class SavedVideo {
  String name;
  String fileName;
  File video;

  SavedVideo(Map map) :
    name = map["name"],
    fileName = map["fileName"];
}

Set<SavedVideo> savedList;

class SavedVideoPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SavedVideoState();
}

class SavedVideoState extends State<SavedVideoPage> {

  FlickManager flickManager;

  Future<Set<SavedVideo>> getSavedList() async {
    var prefs = await SharedPreferences.getInstance();
    savedList = {};

    print(prefs.getKeys());
    for (var e in prefs.getKeys())
    {
      print(e);
      var tmp = SavedVideo({
        "name": e.toString(),
        "fileName": prefs.getString(e),
      });
      print(tmp);
      if (!savedList.contains(tmp)) {
        print("add savedList");
        savedList.add(tmp);
      }
    }
    print("exit");
    return savedList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("저장한 영상"),
      ),
      body:
      FutureBuilder(
        future: getSavedList(),
        builder: (context, value) {
          print(value.data);
          if (value.data == null) return Center(child: CircularProgressIndicator());

          return savedList.isEmpty ? Center(child: Container(padding: const EdgeInsets.all(32.0), child: Text("저장된 영상이 없습니다.\n\n재생 목록에서 저장하고 싶은 레슨을 왼쪽으로 스와이프하면 저장할 수 있습니다.", textAlign: TextAlign.center,)),) :
          Builder(
            builder: (context) {
              return ListView(
                children: savedList.map((elem) {
                  return Dismissible(
                    background: Container(color: Colors.red, child: Container(margin: const EdgeInsets.only(right:8.0), alignment: Alignment.centerRight, child: Icon(Icons.delete, color: Colors.white,)),),
                    key: Key(elem.name),
                    child: ListTile(
                      key: Key(elem.name),
                      title: Text(elem.name),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                            builder: (context) => SavedVideoPlayer(elem)));
                      },
                    ),
                    onDismissed: (DismissDirection direction) async { // 파일 삭제 수행!
                      savedList.remove(elem);
                      var pr = ProgressDialog(context,type: ProgressDialogType.Normal, isDismissible: false);
                      await pr.show();
                      print(elem.name + " deleting...");

                      await File(elem.fileName).delete();

                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      await prefs.remove(elem.name);

                      await pr.hide();
                      Scaffold.of(context).showSnackBar(SnackBar(content: Text("삭제가 완료되었습니다."),));
                    },
                  );
                }).toList(),
              );
            }
          );
        }
      ),
    );
  }

}

class SavedVideoPlayer extends StatefulWidget {
  final SavedVideo video;

  SavedVideoPlayer(this.video);

  @override
  State<StatefulWidget> createState() => SavedVideoPlayerState();
}

class SavedVideoPlayerState extends State<SavedVideoPlayer> {
  FlickManager flickManager;
  File videoFile;
  @override
  void initState() {
    super.initState();
    print(widget.video.fileName);
    videoFile = File(widget.video.fileName);
    widget.video.video = videoFile;
    videoFile.length().then((value) => print(value));
    flickManager = FlickManager(
      videoPlayerController:
      VideoPlayerController.file(videoFile),
      //VideoPlayerController.network("https://github.com/GeekyAnts/flick-video-player-demo-videos/blob/master/demo/default_player.mp4?raw=true"),
    );
  }

  @override
  void dispose() {
    flickManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.video.name),),
      body: SafeArea(
        child: Center(
          child: FlickVideoPlayer(
            flickManager: flickManager,
            preferredDeviceOrientationFullscreen: [
              DeviceOrientation.portraitUp,
              DeviceOrientation.landscapeLeft,
              DeviceOrientation.landscapeRight,
            ],
            flickVideoWithControls: FlickVideoWithControls(
              controls: CustomOrientationControls(),
            ),
            flickVideoWithControlsFullscreen: FlickVideoWithControls(
              controls: CustomOrientationControls(),
            ),
          ),
        ),
      ),
    );
  }
}



class CustomOrientationControls extends StatelessWidget {
  const CustomOrientationControls(
      {Key key, this.iconSize = 20, this.fontSize = 12})
      : super(key: key);
  final double iconSize;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    FlickVideoManager flickVideoManager =
    Provider.of<FlickVideoManager>(context);

    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: FlickAutoHideChild(
            child: Container(color: Colors.black38),
          ),
        ),
        Positioned.fill(
          child: FlickShowControlsAction(
            child: FlickSeekVideoAction(
              child: Center(
                child: flickVideoManager.nextVideoAutoPlayTimer != null
                    ? FlickAutoPlayCircularProgress(
                  colors: FlickAutoPlayTimerProgressColors(
                    backgroundColor: Colors.white30,
                    color: Colors.red,
                  ),
                )
                    : FlickAutoHideChild(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
//                      Padding(
//                        padding: const EdgeInsets.all(8.0),
//                        child: GestureDetector(
//                          onTap: () {
//                            dataManager.skipToPreviousVideo();
//                          },
//                          child: Icon(
//                            Icons.skip_previous,
//                            color: dataManager.hasPreviousVideo()
//                                ? Colors.white
//                                : Colors.white38,
//                            size: 35,
//                          ),
//                        ),
//                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FlickPlayToggle(size: 50),
                      ),
//                      Padding(
//                        padding: const EdgeInsets.all(8.0),
//                        child: GestureDetector(
//                          onTap: () {
//                            dataManager.skipToNextVideo();
//                          },
//                          child: Icon(
//                            Icons.skip_next,
//                            color: dataManager.hasNextVideo()
//                                ? Colors.white
//                                : Colors.white38,
//                            size: 35,
//                          ),
//                        ),
//                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: FlickAutoHideChild(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          FlickCurrentPosition(
                            fontSize: fontSize,
                          ),
                          Text(
                            ' / ',
                            style: TextStyle(
                                color: Colors.white, fontSize: fontSize),
                          ),
                          FlickTotalDuration(
                            fontSize: fontSize,
                          ),
                        ],
                      ),
                      Expanded(
                        child: Container(),
                      ),
                      FlickFullScreenToggle(
                        size: iconSize,
                      ),
                    ],
                  ),
                  FlickVideoProgressBar(
                    flickProgressBarSettings: FlickProgressBarSettings(
                      height: 5,
                      handleRadius: 5,
                      curveRadius: 50,
                      backgroundColor: Colors.white24,
                      bufferedColor: Colors.white38,
                      playedColor: Colors.red,
                      handleColor: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}