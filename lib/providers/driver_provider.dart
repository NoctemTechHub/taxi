import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:taxi/models/driver_model.dart';
import 'package:taxi/services/firebase_service.dart';

final firebaseServiceProvider = Provider((ref) => FirebaseService());

final driverListProvider = StreamProvider<List<Driver>>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return firebaseService.getDriversStream();
});


final driverProvider = FutureProvider.autoDispose
    .family<Driver?, String>((ref, driverId) async {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return await firebaseService.getDriver(driverId);
});


final driverByPlateProvider = FutureProvider.autoDispose
    .family<Driver?, String>((ref, plate) async {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return await firebaseService.getDriverByPlate(plate);
});


final selectedDriverProvider =
    StateProvider<Driver?>((ref) => null);


final availableDriversProvider =
    Provider<List<Driver>>((ref) {
  final drivers = ref.watch(driverListProvider);
  return drivers.whenData(
    (data) => data
        .where((driver) =>
            driver.status == 'available' && driver.status != 'suspended')
        .toList(),
  ).value ?? [];
});
