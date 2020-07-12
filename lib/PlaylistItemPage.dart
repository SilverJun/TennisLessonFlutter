import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tennislesson/youtube.dart';
import 'package:flutter_youtube/flutter_youtube.dart';

class PlaylistItemPage extends StatelessWidget {
  bool _processing = false;
  http.Response _response;
  dynamic _value;
  String playlistID;
  var playlistitems = [];

  PlaylistItemPage({this.playlistID});

  Future<bool> getPlayListItems() async {
    if (!_processing) _processing = true;
    else return false;

    if (playlistitems.isNotEmpty) return true;

    // check shared preference
    print("check shared preference");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("shared preference loading done");

    var check = prefs.getBool('isCached_'+playlistID);
    print("check cache");
    if (check != null && check) { // 캐시가 있는지 확인.
      int mills = prefs.getInt('cachedDate_'+playlistID);
      var cday = DateTime.fromMillisecondsSinceEpoch(mills).toUtc();
      print(cday);
      var now = DateTime.now().toUtc();
      print(now);
      int diffDay = now.difference(cday).inDays;
      print("diffDay: " + diffDay.toString());
      if (diffDay < 1) { // 캐시가 2일 안에 만들어진 캐시인지 확인.
        print("cache loading");
        playlistitems = json.decode(prefs.getString('cache_'+playlistID));
        return true;
      }
    }

    print("youtube api loading");

    _response = await http.get("https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&q=정진화&playlistId=" + playlistID + "&key=" + API_KEY + "&maxResults=50").catchError((error) { return false; });
    _value = json.decode(_response.body);
    print(_value);
    if (_value['error'] != null) {
      return false;
    }
    playlistitems.addAll(_value['items']);
    var nextPageToken = _value['nextPageToken'];
    print(nextPageToken);

    while (nextPageToken != null) {
      _response = await http.get("https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&q=정진화&playlistId=" + playlistID + "&key=" + API_KEY + "&maxResults=50&pageToken=" + nextPageToken);
      _value = json.decode(_response.body);
      playlistitems.addAll(_value['items']);
      print(playlistitems.length);
      nextPageToken = _value['nextPageToken'];
      print(nextPageToken);
    }

    // save cache data
    print("save cache");
    await prefs.setBool('isCached_'+playlistID, true);
    await prefs.setInt('cachedDate_'+playlistID, DateTime.now().millisecondsSinceEpoch);
    await prefs.setString('cache_'+playlistID, json.encode(playlistitems));

    _processing = false;

    print("done making playlistitems");
    return true;
  }

  List<ListTile> _buildListTiles(List<dynamic> items) {
    return items.map((e) {
      return ListTile(
        leading: Container(
          width: 120,
          height: 90,
          child: Image.network(
            e['snippet']['thumbnails']['default']['url'],
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return CircularProgressIndicator();
            },
            fit: BoxFit.fitWidth,
          ),
        ),
        title: Text(e['snippet']['title']),
        onTap: () {
          FlutterYoutube.playYoutubeVideoByUrl(
              apiKey: API_KEY,
              videoUrl: "https://www.youtube.com/watch?v=" + e['snippet']['resourceId']['videoId'],
              autoPlay: true, //default falase
              fullScreen: true //default false
          );
        },
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('제생 목록'),
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: getPlayListItems(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return Center(child: CircularProgressIndicator(),);
            if (snapshot.data)
              return ListView(children: _buildListTiles(playlistitems));
            else return Center(child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(_value['error']['message']),
            ),);
          }
        ),
      ),
    );
  }
}