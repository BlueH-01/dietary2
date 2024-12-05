import 'package:cloud_firestore/cloud_firestore.dart';

class UserDataService {
  final FirebaseFirestore firestore;

  UserDataService(this.firestore);

  // 사용자 데이터 실시간 스트림
  Stream<Map<String, dynamic>> userDataStream(String userId) {
        return firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) => snapshot.data() ?? {});
  }

  // 사용자 데이터 단일 조회
  Future<Map<String, dynamic>?> fetchUserData(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      } else {
        print('User data not found!');
        return null;
      }
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }
}
