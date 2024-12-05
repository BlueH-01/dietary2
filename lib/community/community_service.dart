import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // intl 패키지 추가
import 'dart:io';

class CommunityService {
  final _collection = FirebaseFirestore.instance.collection('community');
  final _storage = FirebaseStorage.instance;
  final _auth = FirebaseAuth.instance;

  /// Firestore에 게시글 추가
  Future<void> addPost({
    required String title,
    required String date,
    String? comment,
    File? imageFile,
  }) async {
    // 제목은 반드시 필요
    if (title.isEmpty) {
      throw ArgumentError('제목은 필수 입력 항목입니다.');
    }

    // 내용은 반드시 필요하고, 공백만 포함된 내용도 불가
    if (comment == null || comment.trim().isEmpty) {
      throw ArgumentError('내용은 필수 입력 항목입니다.');
    }

    // 내용 길이 검증 (최소 5자 이상)
    if (comment.length < 5) {
      throw ArgumentError('내용은 최소 5자 이상이어야 합니다.');
    }

    String? imageUrl;
    String? authorName;
    final user = _auth.currentUser;

    if (user == null) {
      throw ArgumentError('로그인된 사용자가 없습니다.');
    }

    // Firestore에서 사용자의 이름을 가져오기
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    if (userDoc.exists) {
      authorName = userDoc['name'];
    } else {
      throw ArgumentError('사용자 정보가 존재하지 않습니다.');
    }

    // 날짜를 포맷팅
    String formattedDate = _formatDate(DateTime.now());

    // Firestore에 데이터 저장
    await _collection.add({
      'title': title,
      'author': authorName,
      'date': formattedDate,
      'comment': comment,
      'image_url': imageUrl ?? '',
    });
  }

  /// Firestore에서 게시글 삭제
  Future<void> deletePost(String postId) async {
    try {
      await _collection.doc(postId).delete();
    } catch (e) {
      throw Exception("게시글 삭제에 실패했습니다.");
    }
  }

  /// 날짜 포맷팅 함수
  String _formatDate(DateTime dateTime) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(dateTime);
  }

  /// 갤러리에서 이미지를 선택하는 메서드
  Future<File?> pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  /// Firestore에서 실시간으로 데이터를 가져오는 Stream
  Stream<List<Map<String, dynamic>>> getPosts() {
    return _collection
        .orderBy('date', descending: true) // 작성 날짜 기준 내림차순 정렬
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'id': doc.id, // 게시글 ID 추가
          'title': doc['title'] ?? '제목 없음',
          'author': doc['author'] ?? '작성자 없음',
          'date': doc['date'] ?? '날짜 없음',
          'comment': doc['comment'] ?? '내용 없음',
          'image_url': doc['image_url'] ?? '',
        };
      }).toList();
    });
  }
}
