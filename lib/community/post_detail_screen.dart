// post_detail_screen.dart
import 'package:flutter/material.dart';
import 'community_service.dart';

class PostDetailScreen extends StatelessWidget {
  final String title;
  final String author;
  final String date;
  final String comment;
  final String imageUrl;
  final String postId; // 추가: 게시글 ID

  const PostDetailScreen({
    super.key,
    required this.title,
    required this.author,
    required this.date,
    required this.comment,
    required this.imageUrl,
    required this.postId, // 추가: 게시글 ID를 받음
  });

  @override
  Widget build(BuildContext context) {
    final CommunityService communityService = CommunityService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('게시글 상세보기'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              // 게시글 삭제
              await communityService.deletePost(postId);
              Navigator.pop(context); // 삭제 후 뒤로 가기
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            imageUrl.isNotEmpty
                ? Image.network(imageUrl)
                : const SizedBox.shrink(),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '작성자: $author',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              '작성 날짜: $date',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            Text(
              comment,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
