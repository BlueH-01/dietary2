import 'package:flutter/material.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('게시글 상세보기'),
        backgroundColor:
            const Color.fromARGB(255, 11, 200, 115), // AppBar 배경색 변경
      ),
      body: SingleChildScrollView(
        // 스크롤 기능 추가
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              imageUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius:
                          BorderRadius.circular(10.0), // 이미지 둥근 모서리 처리
                      child: Image.network(
                        imageUrl,
                        width: double.infinity, // 이미지 크기 100%로
                        height: 250.0, // 이미지 고정 높이
                        fit: BoxFit.cover, // 이미지가 영역을 넘지 않도록 설정
                      ),
                    )
                  : const SizedBox.shrink(),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 26, // 타이틀 크기 증가
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '작성자: $author',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color.fromARGB(255, 7, 23, 17),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '작성 날짜: $date',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              Divider(color: Colors.grey.shade400), // 구분선 추가
              const SizedBox(height: 16),
              Text(
                comment,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5, // 줄 간격 조정
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
