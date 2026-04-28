// lib/features/profile/data/datasources/profile_remote_datasource.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/profile_model.dart';

abstract class IProfileRemoteDataSource {
  Future<ProfileModel?> getProfile(String userId);
  Future<void> updateProfile(ProfileModel profile);
}

class ProfileRemoteDataSourceImpl implements IProfileRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<ProfileModel?> getProfile(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) return null;
    return ProfileModel.fromMap(doc.data()!, userId);
  }

  @override
  Future<void> updateProfile(ProfileModel profile) async {
    await _firestore.collection('users').doc(profile.id).update(profile.toMap());
  }
}
