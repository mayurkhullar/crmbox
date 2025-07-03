import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/user_model.dart';

class AuthService extends GetxController {
  static AuthService get to => Get.find();
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  final Rx<User?> _firebaseUser = Rx<User?>(null);
  final Rx<UserModel?> _userModel = Rx<UserModel?>(null);
  
  User? get firebaseUser => _firebaseUser.value;
  UserModel? get userModel => _userModel.value;
  bool get isAuthenticated => _firebaseUser.value != null;
  
  @override
  void onInit() {
    super.onInit();
    _firebaseUser.bindStream(_auth.authStateChanges());
    ever(_firebaseUser, _handleAuthChanged);
  }
  
  void _handleAuthChanged(User? user) async {
    if (user == null) {
      _userModel.value = null;
      Get.offAllNamed('/login');
    } else {
      try {
        final userData = await _getUserData(user.uid);
        if (userData != null) {
          _userModel.value = userData;
          // Update last login
          await _updateLastLogin(user.uid);
          Get.offAllNamed('/dashboard');
        } else {
          await signOut();
        }
      } catch (e) {
        await signOut();
      }
    }
  }
  
  Future<UserModel?> _getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data()?['isActive'] == true) {
        return UserModel.fromMap({...doc.data()!, 'uid': uid});
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  Future<void> _updateLastLogin(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Handle error silently as this is not critical
      print('Error updating last login: $e');
    }
  }
  
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found with this email.';
          break;
        case 'wrong-password':
          message = 'Wrong password provided.';
          break;
        case 'user-disabled':
          message = 'This account has been disabled.';
          break;
        default:
          message = 'An error occurred. Please try again.';
      }
      throw message;
    }
  }
  
  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? teamId,
  }) async {
    try {
      // Only admins can create new users
      if (userModel?.role != UserRole.admin) {
        throw 'Unauthorized to create new users';
      }
      
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      if (credential.user != null) {
        await _firestore.collection('users').doc(credential.user!.uid).set({
          'email': email,
          'name': name,
          'role': role.name,
          'teamId': teamId,
          'createdAt': FieldValue.serverTimestamp(),
          'isActive': true,
        });
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'This email is already registered.';
          break;
        case 'weak-password':
          message = 'The password provided is too weak.';
          break;
        default:
          message = 'An error occurred. Please try again.';
      }
      throw message;
    }
  }
  
  Future<void> updateUserProfile({
    required String uid,
    String? name,
    UserRole? role,
    String? teamId,
  }) async {
    try {
      // Only admins can update roles, and managers can update names and teams
      if (userModel?.role != UserRole.admin && 
          (role != null || userModel?.role != UserRole.manager)) {
        throw 'Unauthorized to update user profile';
      }
      
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (role != null) updates['role'] = role.name;
      if (teamId != null) updates['teamId'] = teamId;
      
      await _firestore.collection('users').doc(uid).update(updates);
    } catch (e) {
      throw 'Failed to update user profile: $e';
    }
  }
  
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found with this email.';
          break;
        default:
          message = 'An error occurred. Please try again.';
      }
      throw message;
    }
  }
  
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw 'Failed to sign out';
    }
  }
  
  Future<void> deactivateUser(String uid) async {
    try {
      // Only admins can deactivate users
      if (userModel?.role != UserRole.admin) {
        throw 'Unauthorized to deactivate users';
      }
      
      await _firestore.collection('users').doc(uid).update({
        'isActive': false,
      });
    } catch (e) {
      throw 'Failed to deactivate user: $e';
    }
  }
  
  bool hasPermission(UserRole requiredRole) {
    return userModel?.hasPermission(requiredRole) ?? false;
  }
}
