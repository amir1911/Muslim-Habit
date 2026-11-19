import 'package:flutter_test/flutter_test.dart';
import 'package:muslimhabit/models/community/user_profile_model.dart';
import 'package:muslimhabit/models/community/community_model.dart';
import 'package:muslimhabit/models/community/community_post_model.dart';
import 'package:muslimhabit/models/community/chat_message_model.dart';
import 'package:muslimhabit/models/community/community_notification_model.dart';

void main() {
  group('Community Feature Model Tests', () {
    test('UserProfileModel serialization and status string', () {
      final user = UserProfileModel(
        userId: 'user_123',
        username: 'maulana_a',
        displayName: 'Maulana Adiatma',
        bio: 'Hati yang senantiasa berdzikir',
        isOnline: true,
      );

      expect(user.displayName, equals('Maulana Adiatma'));
      expect(user.activeStatusString, equals('Online'));

      final json = user.toJson();
      final restored = UserProfileModel.fromJson(json);

      expect(restored.userId, equals('user_123'));
      expect(restored.username, equals('maulana_a'));
      expect(restored.displayName, equals('Maulana Adiatma'));
      expect(restored.isOnline, isTrue);
    });

    test('CommunityModel serialization and member handling', () {
      final comm = CommunityModel(
        communityId: 'comm_01',
        name: '7 Ukhti, 1 Langkah Kebaikan',
        description: 'Komunitas akhwat pejuang kebaikan',
        category: 'Al-Qur\'an',
        isPrivate: true,
        adminId: 'user_admin',
        memberCount: 71,
        memberIds: ['user_admin', 'user_member_1'],
      );

      expect(comm.privacyLabel, contains('Invite Only'));
      expect(comm.memberIds.length, equals(2));

      final json = comm.toJson();
      final restored = CommunityModel.fromJson(json);

      expect(restored.communityId, equals('comm_01'));
      expect(restored.name, equals('7 Ukhti, 1 Langkah Kebaikan'));
      expect(restored.isPrivate, isTrue);
      expect(restored.memberCount, equals(71));
      expect(restored.memberIds.contains('user_member_1'), isTrue);
    });

    test('CommunityPostModel like toggling and copyWith', () {
      final post = CommunityPostModel(
        postId: 'post_01',
        communityId: 'comm_01',
        userId: 'user_01',
        userName: 'Fatimah',
        content: 'Alhamdulillah selesai 1 juz hari ini.',
        likes: ['user_02'],
      );

      expect(post.isLikedBy('user_02'), isTrue);
      expect(post.isLikedBy('user_03'), isFalse);

      final updated = post.copyWith(likes: ['user_02', 'user_03']);
      expect(updated.isLikedBy('user_03'), isTrue);
      expect(updated.likes.length, equals(2));
    });

    test('ChatMessageModel serialization and roundtrip', () {
      final now = DateTime.now();
      final msg = ChatMessageModel(
        messageId: 'msg_01',
        chatId: 'chat_01',
        senderId: 'user_01',
        senderName: 'Maulana Adiatma',
        text: 'Assalamu\'alaikum akhi!',
        createdAt: now,
      );

      final json = msg.toJson();
      final restored = ChatMessageModel.fromJson(json);

      expect(restored.messageId, equals('msg_01'));
      expect(restored.senderName, equals('Maulana Adiatma'));
      expect(restored.text, equals('Assalamu\'alaikum akhi!'));
    });

    test('CommunityNotificationModel type and copyWith', () {
      final notif = CommunityNotificationModel(
        notificationId: 'notif_01',
        receiverId: 'user_01',
        type: NotificationType.friendRequest,
        senderId: 'user_02',
        senderName: 'Bagus Harimurti',
        message: 'Bagus Harimurti mengirimkan permintaan pertemanan.',
      );

      expect(notif.isRead, isFalse);
      expect(notif.type, equals(NotificationType.friendRequest));

      final readNotif = notif.copyWith(isRead: true);
      expect(readNotif.isRead, isTrue);
    });
  });
}
