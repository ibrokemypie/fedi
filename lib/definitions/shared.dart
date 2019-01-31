String appName = "fedi";
String appDescription = "Mobile client for Mastodon and Miskkey APIs";
String appCallbackUri = "fedi://appredirect";
String appHomepage = "https://boopsnoot.gq";

List<String> misskeyScope = [
  "account-read",
  "account-write",
  "note-read",
  "note-write",
  "reaction-read",
  "reaction-write",
  "following-read",
  "following-write",
  "drive-read",
  "drive-write",
  "notification-read",
  "notification-write",
  "favorite-read",
  "favorites-read",
  "favorite-write",
  "account/read",
  "account/write",
  "messaging-read",
  "messaging-write",
  "vote-read",
  "vote-write"
];

String mastodonScope = "read write follow push";
