import 'package:flutter/material.dart';
import 'package:tennislesson/PlaylistItemPage.dart';
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
            SizedBox(height: 16),
            Container(
              height: 414,
              child: Image.asset('assets/home.jpeg',)
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text('''안녕하십니까? 테니스넷(tennisnet.co.kr)운영자 정진화입니다.
정진화테니스레슨 동영상을 언제, 어디서, 누구나, 쉽게 접근하여 볼 수 있도록 테니스기술(서브, 포핸드, 백핸드, 포핸드발리, 백핸드발리, 스매쉬, 리턴, 로브, 어프로치샷)을 찾기 쉽게 정리하였습니다. 레슨동영상을 보시고 테니스코트에서 연습하여 테니스를 통해서 건강하고 행복한 삶을 영위하시기를 바랍니다.

테니스넷 : http://www.tennisnet.co.kr/'''),
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
              title: Text('테니스넷 이동'),
              trailing: Icon(Icons.launch),
              onTap: () {
                launch('http://www.tennisnet.co.kr/');
              },
            ),
//            ListTile(
//              title: Text('저장된 영상'),
//            ),
            SizedBox(height: 60.0,),
          ]
        ),
      )
    );
  }

}