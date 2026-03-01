import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:taxi/config/app_constants.dart';
import 'package:taxi/models/app_settings_model.dart';
import 'package:taxi/models/driver_model.dart';
import 'package:taxi/models/package_model.dart';
import 'package:taxi/models/request_model.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();

  FirebaseService._internal();

  factory FirebaseService() {
    return _instance;
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  
  Future<void> initialize() async {
    await Firebase.initializeApp();
    
    
    String? token = await _messaging.getToken();
    print('FCM Token: $token');
  }

  
  Stream<List<Driver>> getDriversStream() {
    return _firestore
        .collection(AppConstants.driversCollection)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Driver.fromJson(doc.data(), doc.id))
          .toList();
    });
  }

  Future<Driver?> getDriver(String driverId) async {
    final doc = await _firestore
        .collection(AppConstants.driversCollection)
        .doc(driverId)
        .get();
    
    if (doc.exists) {
      return Driver.fromJson(doc.data()!, doc.id);
    }
    return null;
  }

  Future<Driver?> getDriverByPlate(String plate) async {
    final query = await _firestore
        .collection(AppConstants.driversCollection)
        .where('plate', isEqualTo: plate)
        .limit(1)
        .get();
    
    if (query.docs.isNotEmpty) {
      return Driver.fromJson(query.docs.first.data(), query.docs.first.id);
    }
    return null;
  }

  Future<String> addDriver(Driver driver) async {
    final doc = await _firestore
        .collection(AppConstants.driversCollection)
        .add(driver.toJson());
    return doc.id;
  }

  Future<void> updateDriver(String driverId, Driver driver) async {
    await _firestore
        .collection(AppConstants.driversCollection)
        .doc(driverId)
        .update(driver.toJson());
  }

  Future<void> updateDriverStatus(String driverId, String status) async {
    await _firestore
        .collection(AppConstants.driversCollection)
        .doc(driverId)
        .update({'status': status});
  }

  Future<void> updateDriverField(String driverId, String field, dynamic value) async {
    await _firestore
        .collection(AppConstants.driversCollection)
        .doc(driverId)
        .update({field: value});
  }

  Future<void> deleteDriver(String driverId) async {
    await _firestore
        .collection(AppConstants.driversCollection)
        .doc(driverId)
        .delete();
  }

  
  Stream<List<TaxiRequest>> getRequestsStream() {
    return _firestore
        .collection(AppConstants.requestsCollection)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TaxiRequest.fromJson(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> addRequest(TaxiRequest request) async {
    await _firestore
        .collection(AppConstants.requestsCollection)
        .add(request.toJson());
  }

  Future<void> updateRequestStatus(String requestId, String status) async {
    await _firestore
        .collection(AppConstants.requestsCollection)
        .doc(requestId)
        .update({'status': status});
  }

  
  Stream<List<TaxiPackage>> getPackagesStream() {
    return _firestore
        .collection(AppConstants.packagesCollection)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TaxiPackage.fromJson(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> addPackage(TaxiPackage package) async {
    await _firestore
        .collection(AppConstants.packagesCollection)
        .add(package.toJson());
  }

  Future<void> updatePackage(String packageId, TaxiPackage package) async {
    await _firestore
        .collection(AppConstants.packagesCollection)
        .doc(packageId)
        .update(package.toJson());
  }

  Future<void> deletePackage(String packageId) async {
    await _firestore
        .collection(AppConstants.packagesCollection)
        .doc(packageId)
        .delete();
  }

  
  Future<AppSettings> getSettings() async {
    final doc = await _firestore
        .collection(AppConstants.settingsCollection)
        .doc(AppConstants.settingsDocument)
        .get();
    
    if (doc.exists) {
      return AppSettings.fromJson(doc.data()!);
    }
    
    
    return AppSettings(
      adminPassword: AppConstants.adminDefaultPassword,
      whatsappNumber: AppConstants.defaultWhatsappNumber,
      downloadLink: AppConstants.defaultDownloadLink,
    );
  }

  Stream<AppSettings> getSettingsStream() {
    return _firestore
        .collection(AppConstants.settingsCollection)
        .doc(AppConstants.settingsDocument)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return AppSettings.fromJson(snapshot.data()!);
      }
      return AppSettings(
        adminPassword: AppConstants.adminDefaultPassword,
        whatsappNumber: AppConstants.defaultWhatsappNumber,
        downloadLink: AppConstants.defaultDownloadLink,
      );
    });
  }

  Future<void> updateSettings(AppSettings settings) async {
    await _firestore
        .collection(AppConstants.settingsCollection)
        .doc(AppConstants.settingsDocument)
        .set(settings.toJson(), SetOptions(merge: true));
  }
}
