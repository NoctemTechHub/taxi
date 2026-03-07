import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:taxi/models/package_model.dart';
import 'package:taxi/providers/driver_provider.dart';

final packageListProvider = StreamProvider<List<TaxiPackage>>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return firebaseService.getPackagesStream();
});
