import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:taxi/models/app_settings_model.dart';
import 'package:taxi/services/firebase_service.dart';

final settingsProvider = StreamProvider<AppSettings>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return firebaseService.getSettingsStream();
});

final firebaseServiceProvider = Provider((ref) => FirebaseService());
