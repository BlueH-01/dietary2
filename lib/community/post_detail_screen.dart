// post_detail_screen.dart
import 'package:flutter/material.dart';

class PostDetailScreen extends StatelessWidget {
  final String title;
  final String author;
  final String date;
  final String comment;
  final String imageUrl;

  PostDetailScreen({
    required this.title,
    required this.author,
    required this.date,
    required this.comment,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('게시글 상세보기'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            imageUrl.isNotEmpty
                ? Image.network(imageUrl)
                : SizedBox.shrink(),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '작성자: $author',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 4),
            Text(
              '작성 날짜: $date',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 16),
            Text(
              comment,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
