import 'package:flutter/material.dart';
import 'dart:io';
import 'community_service.dart';
import 'package:intl/intl.dart'; // intl 패키지 추가

class AddPostScreen extends StatefulWidget {
  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final _titleController = TextEditingController();
  final _commentController = TextEditingController();
  final CommunityService _communityService = CommunityService();
  File? _imageFile;

  /// 날짜 포맷팅 함수
  String _formatTime(DateTime dateTime) {
    final DateFormat formatter = DateFormat('HH:mm'); // '시간:분' 형식으로 포맷
    return formatter.format(dateTime); // 포맷된 시간 반환
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('게시글 작성'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: '제목'),
            ),
            TextField(
              controller: _commentController,
              decoration: InputDecoration(labelText: '내용'),
              maxLines: 4,
            ),
            SizedBox(height: 10),
            GestureDetector(
              onTap: () async {
                _imageFile = await _communityService.pickImage();
                setState(() {});
              },
              child: Container(
                height: 150,
                color: Colors.grey[200],
                child: _imageFile != null
                    ? Image.file(_imageFile!, fit: BoxFit.cover)
                    : Center(child: Text('이미지 추가')),
              ),
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () async {
                if (_titleController.text.isEmpty || _commentController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('제목과 내용을 입력해주세요.')),
                  );
                } else {
                  try {
                    // 시간만 포맷한 date
                    String formattedTime = _formatTime(DateTime.now());

                    await _communityService.addPost(
                      title: _titleController.text,
                      author: '사용자 이름', // 임시로 사용자 이름 설정
                      date: formattedTime, // 포맷된 시간 저장
                      comment: _commentController.text,
                      imageFile: _imageFile,
                    );
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('오류가 발생했습니다: $e')),
                    );
                  }
                }
              },
              child: Text('게시글 작성'),
            ),
          ],
        ),
      ),
    );
  }
}
