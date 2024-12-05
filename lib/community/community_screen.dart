// community_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './community_service.dart';
import './add_post_screen.dart';
import './post_detail_screen.dart'; // 추가한 상세보기 화면 import

class CommunityScreen extends StatelessWidget {
  final CommunityService _communityService = CommunityService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('게시판'),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>( 
        stream: _communityService.getPosts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('게시글이 없습니다.'));
          }

          final posts = snapshot.data!;
          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return Card(
                margin: EdgeInsets.all(8.0),
                elevation: 4,
                child: ListTile(
                  title: Text(post['title'], style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('작성자: ${post['author']}'),
                      Text('작성 날짜: ${post['date']}'),
                      SizedBox(height: 4),
                      Text(
                        post['comment'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  leading: post['image_url'].isNotEmpty
                      ? Image.network(post['image_url'], width: 50, height: 50, fit: BoxFit.cover)
                      : null,
                  onTap: () {
                    // 게시글 상세보기 화면으로 이동
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PostDetailScreen(
                          title: post['title'],
                          author: post['author'],
                          date: post['date'],
                          comment: post['comment'],
                          imageUrl: post['image_url'],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddPostScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
