import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/chat_message.dart';

class ChatRepository {
  final FirebaseFirestore _firestore;

  ChatRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _messagesRef(String userId, String companionId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('companion_chats')
        .doc(companionId)
        .collection('messages');
  }

  /// Memuat stream percakapan real-time per user dan companion
  Stream<List<ChatMessage>> watchMessages({
    required String userId,
    required String companionId,
    int limit = 50,
  }) {
    if (userId.isEmpty) {
      return Stream.value([]);
    }

    return _messagesRef(userId, companionId)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ChatMessage.fromFirestore(doc.data()))
          .toList();
    });
  }

  /// Mengambil riwayat percakapan statis
  Future<List<ChatMessage>> fetchMessages({
    required String userId,
    required String companionId,
    int limit = 50,
  }) async {
    if (userId.isEmpty) return [];

    try {
      final snapshot = await _messagesRef(userId, companionId)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => ChatMessage.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('fetchMessages error: $e');
      return [];
    }
  }

  /// Menyimpan pesan baru ke Cloud Firestore
  Future<void> saveMessage(ChatMessage message) async {
    if (message.userId.isEmpty) return;

    try {
      await _messagesRef(message.userId, message.companionId)
          .doc(message.id)
          .set(message.toFirestore());
    } catch (e) {
      debugPrint('saveMessage error: $e');
    }
  }

  /// Menghapus seluruh riwayat percakapan dengan AI tertentu
  Future<void> clearChatHistory({
    required String userId,
    required String companionId,
  }) async {
    if (userId.isEmpty) return;

    try {
      final snapshot = await _messagesRef(userId, companionId).get();
      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      debugPrint('clearChatHistory error: $e');
    }
  }
}

