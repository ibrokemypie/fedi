import 'package:json_annotation/json_annotation.dart';
import 'package:fedi/definitions/instance.dart';

part 'relationship.g.dart';

@JsonSerializable()
class Relationship {
  bool followedByMe;
  bool followingMe;
  bool requestedFollow;
  bool blocked;
  bool muted;

  Relationship({followedByMe, followingMe, requestedFollow, blocked, muted}) {
    this.followedByMe = followedByMe;
    this.followingMe = followingMe;
    this.requestedFollow = requestedFollow;
    this.blocked = blocked;
    this.muted = muted;
  }

  Relationship.fromMisskey(Map json) {
    this.followedByMe = json['isFollowing'] ?? null;
    this.followingMe = json['isFollowed'] ?? null;
    this.requestedFollow = json['hasPendingFollowRequestFromYou'] ?? null;
    this.blocked = json['isBlocked'] ?? null;
    this.muted = json['isMuted'] ?? null;
  }

  Relationship.fromMastodon(Map json) {
    this.followedByMe = json['following'];
    this.followingMe = json['followed_by'];
    this.requestedFollow = json['requested'];
    this.blocked = json['blocking'];
    this.muted = json['muting'];
  }

  Map<String, dynamic> toJson() => _$RelationshipToJson(this);
  factory Relationship.fromJson(Map<String, dynamic> json) =>
      _$RelationshipFromJson(json);
}
