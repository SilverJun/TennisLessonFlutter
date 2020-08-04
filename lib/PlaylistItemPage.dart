import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tennislesson/SavedVideoPage.dart';
import 'package:tennislesson/youtube.dart';
import 'package:flutter_youtube/flutter_youtube.dart';
import 'package:path_provider/path_provider.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as YE;

bool _processing = false;

//https://pub.dev/packages/youtube_explode_dart
// TODO : explode 로 로직 다 바꾸기! API 쓰지말자.

class PlaylistItemPage extends StatelessWidget {
  http.Response _response;
  dynamic _value = null;
  String playlistID;

  //"title": video.title,
  //"thumbnails": video.thumbnails.standardResUrl,
  //"videoId": video.id,
  var playlistitems = [];
  ProgressDialog pr;

  PlaylistItemPage({this.playlistID});

  Future<bool> getPlayListItems() async {
    print(_processing);
    if (!_processing) _processing = true;
    else return false;

//    if (playlistitems.isNotEmpty) {
//      _processing = false;
//      return true;
//    }
//
//    // check shared preference
//    print("check shared preference");
//    SharedPreferences prefs = await SharedPreferences.getInstance();
//    print("shared preference loading done");
//
//    var check = prefs.getBool('isCached_'+playlistID);
//    print("check cache");
//    if (check != null && check) { // 캐시가 있는지 확인.
//      int mills = prefs.getInt('cachedDate_'+playlistID);
//      var cday = DateTime.fromMillisecondsSinceEpoch(mills).toUtc();
//      print(cday);
//      var now = DateTime.now().toUtc();
//      print(now);
//      int diffDay = now.difference(cday).inDays;
//      print("diffDay: " + diffDay.toString());
//      if (diffDay < 1) { // 캐시가 2일 안에 만들어진 캐시인지 확인.
//        print("cache loading");
//        playlistitems = json.decode(prefs.getString('cache_'+playlistID));
//        _processing = false;
//        return true;
//      }
//    }
//
//    print("youtube api loading");
//
//    _response = await http.get("https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&q=정진화&playlistId=" + playlistID + "&key=" + API_KEY + "&maxResults=50").catchError((error) { return false; });
//    _value = json.decode(_response.body);
//    print(_value);
//    if (_value['error'] != null) {
//      _processing = false;
//      return false;
//    }
//    playlistitems.addAll(_value['items']);
//    var nextPageToken = _value['nextPageToken'];
//    print(nextPageToken);
//
//    while (nextPageToken != null) {
//      _response = await http.get("https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&q=정진화&playlistId=" + playlistID + "&key=" + API_KEY + "&maxResults=50&pageToken=" + nextPageToken).catchError((error) { return false; });
//      _value = json.decode(_response.body);
//      if (_value['error'] != null) {
//        _processing = false;
//        return false;
//      }
//
//      playlistitems.addAll(_value['items']);
//      //print(playlistitems.length);
//      print(_value);
//      nextPageToken = _value['nextPageToken'];
//      print(nextPageToken);
//    }
//
//    // save cache data
//    print("save cache");
//    await prefs.setBool('isCached_'+playlistID, true);
//    await prefs.setInt('cachedDate_'+playlistID, DateTime.now().millisecondsSinceEpoch);
//    await prefs.setString('cache_'+playlistID, json.encode(playlistitems));
//
//    _processing = false;
//
//    print("done making playlistitems");

    var yt = YE.YoutubeExplode();

// Get playlist metadata.
    var playlist = await yt.playlists.get(playlistID).catchError((error) {
      _processing = false;
      _value = error;
      print("return false");
      return false;
    });

    playlistitems = [];
    print("YoutubeExplode start");
    await for (var video in yt.playlists.getVideos(playlist.id)) {
      playlistitems.add({
        "title": video.title,
        "thumbnails": video.thumbnails.lowResUrl,
        "videoId": video.id.toString(),
      });
    }
    print("YoutubeExplode end");

    yt.close();
    _processing = false;

    return true;
  }

  List<Widget> _buildListTiles(List<dynamic> items, BuildContext context) {
    return items.map((e) {
      return Slidable(
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: 0.25,
        child: Container(
          color: Colors.white,
          child: ListTile(
            leading: Container(
              width: 120,
              height: 90,
              child: Image.network(
                e['thumbnails'],
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return CircularProgressIndicator();
                },
                fit: BoxFit.fitWidth,
              ),
            ),
            title: Text(e['title']),
            onTap: () {
              FlutterYoutube.playYoutubeVideoByUrl(
                  apiKey: API_KEY,
                  videoUrl: "https://www.youtube.com/watch?v=" + e['videoId'],
                  autoPlay: true, //default falase
                  fullScreen: true //default false
              );
            },
          ),
        ),
        secondaryActions: <Widget>[
          IconSlideAction(
            caption: 'Download',
            color: Colors.grey,
            icon: Icons.file_download,
            foregroundColor: Colors.white,
            onTap: () async {
              await pr.show();
              var videoId = e['videoId'];
              Directory directory = await getApplicationDocumentsDirectory();
              String filePath = directory.path + '/'+videoId;
              print(videoId);
              var yt = YE.YoutubeExplode();

              var manifest = await yt.videos.streamsClient.getManifest(videoId);
              print(manifest);
              var streamInfo = manifest.muxed.first;

              var stream = yt.videos.streamsClient.get(streamInfo);

              // Open a file for writing.
              var file = File(filePath);
              var fileStream = file.openWrite();

              // Pipe all the content of the stream into the file.
              await stream.pipe(fileStream);

              // Close the file.
              await fileStream.flush();
              await fileStream.close();
              yt.close();

              // Add in shared_preference
              savedList.add(SavedVideo({
                "name" : e['title'],
                "fileName" : file.path,
              }));

              //TODO: shared preference에 영상정보 업데이트 하기.

              await pr.hide();
              Scaffold.of(context).showSnackBar(SnackBar(content: Text("다운로드가 완료되었습니다."),));
            },
          ),
        ],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    pr = ProgressDialog(context,type: ProgressDialogType.Normal, isDismissible: false);
    return Scaffold(
      appBar: AppBar(
        title: Text('재생 목록'),
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: getPlayListItems(),
          builder: (context, snapshot) {
            print(snapshot.data);
            if (!snapshot.hasData && _value == null) return Center(child: CircularProgressIndicator(),);
            if (playlistitems.isNotEmpty)
              return Builder(builder: (context) => ListView(children: _buildListTiles(playlistitems, context)));
            else return Center(child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("재생목록을 불러오는 중 오류가 발생했습니다."),
                  SizedBox(height: 8.0,),
                  Text(_value.toString(), style: TextStyle(color: Colors.grey, fontSize: 10.0),),
                ]),
            ),);
          }
        ),
      ),
    );
  }
}