class Household {
  final String id;
  final String name;
  final String ownerId;
  final List<String> members; // UIDs of members
  final List<String> memberEmails; // Emails of members for easy searching
  final List<String> sharedModules; // Slugs of shared modules: 'finance', 'shopping', etc.

  Household({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.members,
    required this.memberEmails,
    required this.sharedModules,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'ownerId': ownerId,
      'members': members,
      'memberEmails': memberEmails,
      'sharedModules': sharedModules,
    };
  }

  factory Household.fromMap(String id, Map<String, dynamic> map) {
    return Household(
      id: id,
      name: map['name'] ?? '',
      ownerId: map['ownerId'] ?? '',
      members: List<String>.from(map['members'] ?? []),
      memberEmails: List<String>.from(map['memberEmails'] ?? []),
      sharedModules: List<String>.from(map['sharedModules'] ?? []),
    );
  }

  Household copyWith({
    String? name,
    List<String>? members,
    List<String>? memberEmails,
    List<String>? sharedModules,
  }) {
    return Household(
      id: id,
      name: name ?? this.name,
      ownerId: ownerId,
      members: members ?? this.members,
      memberEmails: memberEmails ?? this.memberEmails,
      sharedModules: sharedModules ?? this.sharedModules,
    );
  }
}
