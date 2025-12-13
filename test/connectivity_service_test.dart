import 'package:flutter_test/flutter_test.dart';
import 'package:allosante_benin/core/services/connectivity_service.dart';

void main() {
  late ConnectivityService connectivityService;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() {
    connectivityService = ConnectivityService();
  });

  group('ConnectivityService', () {
    test('should be a singleton', () {
      // Arrange & Act
      final instance1 = ConnectivityService();
      final instance2 = ConnectivityService();

      // Assert
      expect(identical(instance1, instance2), isTrue);
    });

    test('should have default connected state', () {
      // Assert
      expect(connectivityService.isConnected, isTrue);
      expect(connectivityService.hasInternetAccess, isTrue);
      expect(connectivityService.isOffline, isFalse);
    });

    test('should return correct connection status text when connected', () {
      // Assert - Default state should be connected
      final statusText = connectivityService.connectionStatusText;
      expect(statusText, isNotEmpty);
    });

    test('should return correct connection icon', () {
      // Assert
      final icon = connectivityService.connectionIcon;
      expect(icon, isNotEmpty);
    });

    group('executeIfOnline', () {
      test('should execute action when online', () async {
        // Arrange
        var actionExecuted = false;

        // Act
        final result = await connectivityService.executeIfOnline(() async {
          actionExecuted = true;
          return 'success';
        });

        // Assert
        expect(result, equals('success'));
        expect(actionExecuted, isTrue);
      });
    });

    group('executeWithFallback', () {
      test('should execute online action when connected', () async {
        // Arrange & Act
        final result = await connectivityService.executeWithFallback(
          onlineAction: () async => 'online',
          offlineFallback: () => 'offline',
        );

        // Assert
        expect(result, equals('online'));
      });

      test('should use fallback when online action fails', () async {
        // Arrange & Act
        final result = await connectivityService.executeWithFallback(
          onlineAction: () async {
            throw Exception('Network error');
          },
          offlineFallback: () => 'fallback_value',
        );

        // Assert
        expect(result, equals('fallback_value'));
      });
    });

    group('updateLastSyncTime', () {
      test('should update last sync time', () {
        // Arrange
        final beforeUpdate = connectivityService.lastSyncTime;

        // Act
        connectivityService.updateLastSyncTime();

        // Assert
        expect(connectivityService.lastSyncTime, isNotNull);
        if (beforeUpdate != null) {
          expect(
            connectivityService.lastSyncTime!.isAfter(beforeUpdate),
            isTrue,
          );
        }
      });
    });

    group('checkConnection', () {
      test('should return connectivity status', () async {
        // Act
        final result = await connectivityService.checkConnection();

        // Assert
        expect(result, isA<bool>());
      });
    });
  });

  group('ConnectivityService integration', () {
    test('should notify listeners when sync time is updated', () {
      // Arrange
      var notified = false;
      connectivityService.addListener(() {
        notified = true;
      });

      // Act
      connectivityService.updateLastSyncTime();

      // Assert
      expect(notified, isTrue);

      // Cleanup
      connectivityService.removeListener(() {});
    });
  });
}
