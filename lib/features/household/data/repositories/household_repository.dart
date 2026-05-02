import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:love_routine_app/features/household/domain/models/household.dart';

class HouseholdRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String collectionPath = 'households';

  Future<Household?> getHouseholdForUser(String uid) async {
    final query = await _firestore
        .collection(collectionPath)
        .where('members', arrayContains: uid)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;

    final doc = query.docs.first;
    return Household.fromMap(doc.id, doc.data());
  }

  Future<String> createHousehold(String name, String ownerId, String ownerEmail) async {
    final docRef = await _firestore.collection(collectionPath).add({
      'name': name,
      'ownerId': ownerId,
      'members': [ownerId],
      'memberEmails': [ownerEmail],
      'sharedModules': ['shopping', 'finance', 'diet'], // Default shared modules
      'createdAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  Future<void> updateHousehold(Household household) async {
    await _firestore
        .collection(collectionPath)
        .doc(household.id)
        .update(household.toMap());
  }

  Future<void> addMemberByEmail(String householdId, String email) async {
    // Note: In a real app, we'd check if a user with this email exists.
    // For now, we add the email to memberEmails. When the user logs in, 
    // we can sync their UID if needed.
    await _firestore.collection(collectionPath).doc(householdId).update({
      'memberEmails': FieldValue.arrayUnion([email]),
    });
  }
  
  Future<void> removeMember(String householdId, String uid, String email) async {
    await _firestore.collection(collectionPath).doc(householdId).update({
      'members': FieldValue.arrayRemove([uid]),
      'memberEmails': FieldValue.arrayRemove([email]),
    });
  }
}
