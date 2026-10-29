import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Resolved [PackageInfo] for the running build. Hand-rolled FutureProvider
/// (no codegen) following the classic riverpod idiom used elsewhere in the
/// codebase (see services/preferences/time_format_providers.dart).
final packageInfoProvider = FutureProvider<PackageInfo>((ref) async {
  return PackageInfo.fromPlatform();
});

/// The app's user-facing version string (e.g. "0.1.0"), derived from the
/// build's versionName. Used by the Settings screens.
final appVersionProvider = FutureProvider<String>((ref) async {
  final info = await ref.watch(packageInfoProvider.future);
  return info.version;
});
