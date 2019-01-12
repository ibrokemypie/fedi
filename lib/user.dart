class User {
  String username;
  String nickname;
  String id;
  String host;
  String avatarUrl;
  String url;
  String acct;

  User(username, nickname, id, host, avatarUrl, url) {
    this.username = username;
    this.nickname = nickname;
    this.id = id;
    this.host = host;
    this.avatarUrl = avatarUrl;
    this.url = this.host + "/@" + this.username;
    this.acct = this.username + "@" + this.host;
  }

  User.fromJson(Map json) {
    this.username = json['username'];
    this.nickname = json['nickname'];
    this.id = json['id'];
    this.host = json['host'];
    this.avatarUrl = json['avatarUrl'];
    this.url = this.host + "/@" + this.username;
    this.acct = this.username + "@" + this.host;
  }
}
