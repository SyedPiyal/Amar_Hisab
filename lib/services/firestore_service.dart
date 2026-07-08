import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Global Collection Methods (No UID required)
  
  Future<void> saveGlobalRecord({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore
          .collection(collection)
          .doc(documentId)
          .set(data, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firestore global save error: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchGlobalCollection({
    required String collection,
  }) async {
    try {
      final querySnapshot = await _firestore.collection(collection).get();
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      debugPrint('Firestore global fetch error: $e');
      return [];
    }
  }

  // User-specific Methods (Existing)

  Future<void> saveRecord({
    required String uid,
    required String collection,
    required String documentId,
    required Map<dynamic, dynamic> data,
  }) async {
    try {
      final Map<String, dynamic> firestoreData = {};
      data.forEach((key, value) {
        firestoreData[key.toString()] = value;
      });

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
