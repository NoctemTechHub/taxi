import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:taxi/models/package_model.dart';
import 'package:taxi/services/firebase_service.dart';

final firebaseServiceProvider = Provider((ref) => FirebaseService());

final packageListProvider = StreamProvider<List<TaxiPackage>>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return firebaseService.getPackagesStream();
});

final packagesProvider = StreamProvider<List<TaxiPackage>>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return firebaseService.getPackagesStream();
});
