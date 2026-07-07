import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // users/{uid}/{collection}/{documentId}

  Future<void> saveRecord({
    required String uid,
    required String collection,
    required String documentId,
    required Map<dynamic, dynamic> data,
  }) async {
    try {
      // Ensure all keys are strings for Firestore
      final Map<String, dynamic> firestoreData = {};
      data.forEach((key, value) {
        firestoreData[key.toString()] = value;
      });

      // Add a server timestamp for sync resolution if needed later
      firestoreData['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection('users')
          .doc(uid)
          .collection(collection)
          .doc(documentId)
          .set(firestoreData, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firestore save error: $e');
      rethrow;
    }
  }

  Future<void> deleteRecord({
    required String uid,
    required String collection,
    required String documentId,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection(collection)
          .doc(documentId)
          .delete();
    } catch (e) {
      debugPrint('Firestore delete error: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchCollection({
    required String uid,
    required String collection,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection(collection)
          .get();
      
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      debugPrint('Firestore fetch error: $e');
      return [];
    }
  }
}
