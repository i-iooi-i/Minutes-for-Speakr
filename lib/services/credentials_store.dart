import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'credentials_store.freezed.dart';
part 'credentials_store.g.dart';

@freezed
sealed class SpeakrCredentials with _$SpeakrCredentials {
  const factory SpeakrCredentials({
    required String baseUrl,
    required String token,
  }) = _SpeakrCredentials;

  factory SpeakrCredentials.fromJson(Map<String, dynamic> json) =>
      _$SpeakrCredentialsFromJson(json);
}

class CredentialsStore {
  CredentialsStore([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  static const _kBaseUrl = 'speakr.baseUrl';
  static const _kToken = 'speakr.token';

  final FlutterSecureStorage _storage;

  Future<SpeakrCredentials?> read() async {
    final base = await _storage.read(key: _kBaseUrl);
    final token = await _storage.read(key: _kToken);
    if (base == null || token == null) return null;
    return SpeakrCredentials(baseUrl: base, token: token);
  }

  Future<void> write(SpeakrCredentials creds) async {
    await _storage.write(key: _kBaseUrl, value: creds.baseUrl);
    await _storage.write(key: _kToken, value: creds.token);
  }

  Future<void> clear() async {
    await _storage.delete(key: _kBaseUrl);
    await _storage.delete(key: _kToken);
  }
}

final credentialsStoreProvider = Provider<CredentialsStore>((ref) {
  return CredentialsStore();
});

/// Cached credentials, refreshed when [credentialsControllerProvider] writes.
final currentCredentialsProvider = FutureProvider<SpeakrCredentials?>((
  ref,
) async {
  return ref.watch(credentialsStoreProvider).read();
});
