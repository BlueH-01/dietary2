import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './community_service.dart';
import './add_post_screen.dart';
import './post_detail_screen.dart'; // 추가한 상세보기 화면 import

class CommunityScreen extends StatelessWidget {
  final CommunityService _communityService = CommunityService();

  CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '다이어터 커뮤니티',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        centerTitle: true, // 제목을 가운데 정렬
        automaticallyImplyLeading: false, // 뒤로가기 버튼 제거
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _communityService.getPosts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('게시글이 없습니다.'));
          }

          final posts = snapshot.data!;
          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                elevation: 4,
                child: ListTile(
                  title: Text(post['title'],
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('작성자: ${post['author']}'),
                      Text('작성 날짜: ${post['date']}'),
                      const SizedBox(height: 4),
                      Text(
                        post['comment'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  leading: post['image_url'].isNotEmpty
                      ? Image.network(post['image_url'],
                          width: 50, height: 50, fit: BoxFit.cover)
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
            MaterialPageRoute(builder: (context) => const AddPostScreen()),
          );
        },
        child: const Icon(Icons.edit), // 연필 아이콘으로 변경
      ),
    );
  }
}
