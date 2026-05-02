import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:love_routine_app/features/household/domain/models/household.dart';

class HouseholdRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String collectionPath = 'households';

  Future<List<Household>> getHouseholdsForUser(String uid, String email) async {
    final cleanEmail = email.trim().toLowerCase();
    
    // Search by UID
    final uidQuery = await _firestore
        .collection(collectionPath)
        .where('members', arrayContains: uid)
        .get();

    // Search by Email (for new invites)
    final emailQuery = await _firestore
        .collection(collectionPath)
        .where('memberEmails', arrayContains: cleanEmail)
        .get();

    final allDocs = [...uidQuery.docs, ...emailQuery.docs];
    final uniqueDocs = {for (var doc in allDocs) doc.id: doc};

    final households = uniqueDocs.values
        .map((doc) => Household.fromMap(doc.id, doc.data()))
        .toList();

    // Sync UID for any households found only by email
    for (var household in households) {
      if (!household.members.contains(uid)) {
        try {
          await _firestore.collection(collectionPath).doc(household.id).update({
            'members': FieldValue.arrayUnion([uid]),
          });
          household.members.add(uid);
        } catch (e) {
          // Ignore permission errors during sync - email access is sufficient
          print('Optional UID sync failed: $e');
        }
      }
    }

    return households;
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
    final cleanEmail = email.trim().toLowerCase();
    await _firestore.collection(collectionPath).doc(householdId).update({
      'memberEmails': FieldValue.arrayUnion([cleanEmail]),
    });
  }
  
  Future<void> removeMember(String householdId, String uid, String email) async {
    await _firestore.collection(collectionPath).doc(householdId).update({
      'members': FieldValue.arrayRemove([uid]),
      'memberEmails': FieldValue.arrayRemove([email]),
    });
  }
}
