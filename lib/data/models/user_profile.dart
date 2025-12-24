
class UserProfile {
  final String id;
  final List<String> lifeContexts; // e.g., ["Work", "Coffee", "Social"]
  final String humorTone; // e.g., "Sarcastic", "Relatable"
  final String preferredMood; // Emoji ID, e.g., "🫠"

  UserProfile({
    required this.id,
    required this.lifeContexts,
    required this.humorTone,
    required this.preferredMood,
  });

  factory UserProfile.empty() {
    return UserProfile(
      id: '',
      lifeContexts: [],
      humorTone: 'Relatable',
      preferredMood: '😀',
    );
  }

  UserProfile copyWith({
    String? id,
    List<String>? lifeContexts,
    String? humorTone,
    String? preferredMood,
  }) {
    return UserProfile(
      id: id ?? this.id,
      lifeContexts: lifeContexts ?? this.lifeContexts,
      humorTone: humorTone ?? this.humorTone,
      preferredMood: preferredMood ?? this.preferredMood,
    );
  }
}
