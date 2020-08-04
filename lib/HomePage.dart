import 'package:flutter/material.dart';
import 'package:tennislesson/PlaylistItemPage.dart';
import 'package:tennislesson/SavedVideoPage.dart';
import 'package:tennislesson/youtube.dart';
import 'package:url_launcher/url_launcher.dart';


class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('정진화 테니스레슨'),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            SizedBox(height: 8),
            Container(
              child: Image.asset('assets/home.jpeg',)
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text('''정진화 테니스레슨 영상을 언제, 어디서, 누구나, 쉽게 접근하여 볼 수 있도록 테니스기술(서브, 포핸드, 백핸드, 포핸드발리, 백핸드발리, 스매쉬, 리턴, 로브, 어프로치샷)을 찾기 쉽게 정리하였습니다. 테니스를 통해서 건강하고 행복한 삶을 영위하시기를 바랍니다.

정진화테니스아카데미
문의처 : 010-2723-2134
주소 : 서울시 은평구 응암로 310 파인빌딩 지하 1층'''),
            ),
            ExpansionTile(
              initiallyExpanded: true,
              title: Text('레슨 목록'),
              children: playlist.map((e) {
                //print(e['name']);
                return ListTile(title: Text(e['name']), trailing: Icon(Icons.navigate_next), onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => PlaylistItemPage(playlistID: e['id'],)));
                },);
              }).toList(),
            ),
            ListTile(
              title: Text("저장한 영상"),
              trailing: Icon(Icons.navigate_next),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => SavedVideoPage()));
              },
            ),
            ListTile(
              title: Text('정진화 테니스아카데미 블로그 이동'),
              trailing: Icon(Icons.launch),
              onTap: () {
                launch('https://blog.naver.com/jtennis2134/'); // https://www.youtube.com/channel/UC_0KlMiTzpejiet6ovAtoOQ
              },
            ),
            ListTile(
              title: Text('정진화 테니스레슨 인스타그램 이동'),
              trailing: Icon(Icons.launch),
              onTap: () {
                launch('https://www.instagram.com/jeongjinhoa_tennis_academy/');
              },
            ),
            ListTile(
              title: Text('정진화 테니스아카데미 인스타그램 이동'),
              trailing: Icon(Icons.launch),
              onTap: () {
                launch('https://www.instagram.com/jta_tennis/');
              },
            ),

            SizedBox(height: 60.0,),
          ]
        ),
      )
    );
  }

}