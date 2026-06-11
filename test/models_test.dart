import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motion/models.dart';
import 'package:motion/widgets.dart';

void main() {
  group('Email', () {
    test('constructor sets all fields', () {
      const email = Email(
        sender: 'Test Sender',
        time: '1 hour ago',
        subject: 'Test Subject',
        message: 'Test message body',
        avatar: 'reply/avatars/avatar_0.jpg',
        recipients: 'User',
        containsPictures: false,
      );

      expect(email.sender, 'Test Sender');
      expect(email.time, '1 hour ago');
      expect(email.subject, 'Test Subject');
      expect(email.message, 'Test message body');
      expect(email.avatar, 'reply/avatars/avatar_0.jpg');
      expect(email.recipients, 'User');
      expect(email.containsPictures, false);
    });

    test('supports value equality', () {
      const email1 = Email(
        sender: 'A',
        time: '0m',
        subject: 'S',
        message: 'M',
        avatar: 'a.png',
        recipients: 'R',
        containsPictures: false,
      );
      const email2 = Email(
        sender: 'A',
        time: '0m',
        subject: 'S',
        message: 'M',
        avatar: 'a.png',
        recipients: 'R',
        containsPictures: false,
      );

      expect(email1, email2);
    });
  });

  group('EmailStore', () {
    late EmailStore store;

    setUp(() {
      store = EmailStore();
    });

    test('initial state', () {
      expect(store.currentlySelectedInbox, 'Inbox');
      expect(store.currentlySelectedEmailId, -1);
      expect(store.onMailView, false);
      expect(store.onCompose, false);
      expect(store.bottomDrawerVisible, false);
      expect(store.themeMode, ThemeMode.system);
      expect(store.slowMotionSpeed, SlowMotionSpeedSetting.normal);
    });

    test('emits six categories', () {
      expect(store.emails.length, 6);
      expect(store.emails.containsKey('Inbox'), true);
      expect(store.emails.containsKey('Starred'), true);
      expect(store.emails.containsKey('Sent'), true);
      expect(store.emails.containsKey('Trash'), true);
      expect(store.emails.containsKey('Spam'), true);
      expect(store.emails.containsKey('Drafts'), true);
    });

    test('Inbox is not empty', () {
      expect(store.emails['Inbox']!.isNotEmpty, true);
    });

    test('Starred starts empty', () {
      expect(store.emails['Starred']!.isEmpty, true);
    });

    test('currentlySelectedInbox setter', () {
      store.currentlySelectedInbox = 'Starred';
      expect(store.currentlySelectedInbox, 'Starred');
    });

    test('currentlySelectedEmailId setter', () {
      store.currentlySelectedEmailId = 2;
      expect(store.currentlySelectedEmailId, 2);
    });

    test('onMailView is true when emailId > -1', () {
      expect(store.onMailView, false);
      store.currentlySelectedEmailId = 0;
      expect(store.onMailView, true);
    });

    test('onCompose setter', () {
      store.onCompose = true;
      expect(store.onCompose, true);
    });

    test('bottomDrawerVisible setter', () {
      store.bottomDrawerVisible = true;
      expect(store.bottomDrawerVisible, true);
    });

    test('themeMode setter', () {
      store.themeMode = ThemeMode.dark;
      expect(store.themeMode, ThemeMode.dark);
    });

    test('isEmailStarred returns false for non-starred email', () {
      final email = store.emails['Inbox']!.elementAt(0);
      expect(store.isEmailStarred(email), false);
    });

    test('starEmail adds to Starred', () {
      final email = store.emails['Inbox']!.elementAt(0);
      store.starEmail('Inbox', 0);
      expect(store.isEmailStarred(email), true);
    });

    test('starEmail removes from Starred when already starred', () {
      final email = store.emails['Inbox']!.elementAt(0);
      store.starEmail('Inbox', 0);
      expect(store.isEmailStarred(email), true);
      store.starEmail('Inbox', 0);
      expect(store.isEmailStarred(email), false);
    });

    test('deleteEmail removes email from all categories', () {
      final email = store.emails['Inbox']!.elementAt(0);
      store.starEmail('Inbox', 0);
      expect(store.isEmailStarred(email), true);

      store.deleteEmail('Inbox', 0);
      expect(store.emails['Inbox']!.contains(email), false);
      expect(store.emails['Starred']!.contains(email), false);
    });

    test('onMailView evaluates correctly', () {
      expect(store.onMailView, false);
      store.currentlySelectedEmailId = -1;
      expect(store.onMailView, false);
      store.currentlySelectedEmailId = 0;
      expect(store.onMailView, true);
    });
  });

  group('SlowMotionSpeedSetting', () {
    test('normal has value 1.0', () {
      expect(SlowMotionSpeedSetting.normal.value, 1.0);
    });

    test('slow has value 5.0', () {
      expect(SlowMotionSpeedSetting.slow.value, 5.0);
    });

    test('slower has value 10.0', () {
      expect(SlowMotionSpeedSetting.slower.value, 10.0);
    });

    test('slowest has value 15.0', () {
      expect(SlowMotionSpeedSetting.slowest.value, 15.0);
    });
  });

  group('ThemeMode extension', () {
    test('system returns System', () {
      expect(ThemeMode.system.name, 'System');
    });

    test('light returns Light', () {
      expect(ThemeMode.light.name, 'Light');
    });

    test('dark returns Dark', () {
      expect(ThemeMode.dark.name, 'Dark');
    });
  });
}
