import '../../domain/entities/leaderboard.dart';

class LeaderboardEntryModel extends LeaderboardEntry {
  const LeaderboardEntryModel({
    required super.userId,
    required super.displayName,
    required super.score,
    required super.rank,
    super.photoUrl,
    super.country,
    super.avatar,
    super.isCurrentUser = false,
    super.metadata = const <String, dynamic>{},
  });

  factory LeaderboardEntryModel.fromMap(Map<String, dynamic> map) {
    return LeaderboardEntryModel(
      userId: map['userId'] as String? ?? '',
      displayName: map['displayName'] as String? ?? 'لاعب',
      score: map['score'] as int? ?? 0,
      rank: map['rank'] as int? ?? 0,
      photoUrl: map['photoUrl'] as String?,
      country: map['country'] as String?,
      avatar: map['avatar'] as String?,
      isCurrentUser: map['isCurrentUser'] as bool? ?? false,
      metadata: Map<String, dynamic>.from(
        map['metadata'] as Map? ?? <String, dynamic>{},
      ),
    );
  }

  factory LeaderboardEntryModel.fromEntity(LeaderboardEntry entry) {
    return LeaderboardEntryModel(
      userId: entry.userId,
      displayName: entry.displayName,
      score: entry.score,
      rank: entry.rank,
      photoUrl: entry.photoUrl,
      country: entry.country,
      avatar: entry.avatar,
      isCurrentUser: entry.isCurrentUser,
      metadata: entry.metadata,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'displayName': displayName,
      'score': score,
      'rank': rank,
      'photoUrl': photoUrl,
      'country': country,
      'avatar': avatar,
      'isCurrentUser': isCurrentUser,
      'metadata': metadata,
    };
  }
}
