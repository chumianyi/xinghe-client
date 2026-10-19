class AppItem {
  final String id;
  final String name;
  final String version;
  final String size;
  final String desc;
  final String iconUrl;
  final String downloadUrl;
  final String category;
  final String uploader;
  final int coinsPrice;
  final int downloadCount;
  final double rating;

  AppItem({
    required this.id,
    required this.name,
    required this.version,
    required this.size,
    required this.desc,
    required this.iconUrl,
    required this.downloadUrl,
    required this.category,
    required this.uploader,
    required this.coinsPrice,
    required this.downloadCount,
    required this.rating,
  });

  factory AppItem.fromJson(Map<String, dynamic> j) => AppItem(
        id: '${j['id'] ?? ''}',
        name: '${j['name'] ?? ''}',
        version: '${j['version'] ?? ''}',
        size: '${j['size'] ?? ''}',
        desc: '${j['desc'] ?? ''}',
        iconUrl: '${j['icon_url'] ?? ''}',
        downloadUrl: '${j['download_url'] ?? ''}',
        category: '${j['category'] ?? '未分类'}',
        uploader: '${j['uploader'] ?? ''}',
        coinsPrice: (j['coins_price'] ?? 0) is int
            ? j['coins_price']
            : int.tryParse('${j['coins_price']}') ?? 0,
        downloadCount: (j['download_count'] ?? 0) is int
            ? j['download_count']
            : int.tryParse('${j['download_count']}') ?? 0,
        rating: (j['rating'] is num) ? (j['rating'] as num).toDouble() : 0.0,
      );
}

class CommentItem {
  final String appId;
  final String username;
  final String content;
  final int rating;
  final String createdAt;

  CommentItem({
    required this.appId,
    required this.username,
    required this.content,
    required this.rating,
    required this.createdAt,
  });

  factory CommentItem.fromJson(Map<String, dynamic> j) => CommentItem(
        appId: '${j['app_id'] ?? ''}',
        username: '${j['username'] ?? '匿名'}',
        content: '${j['content'] ?? ''}',
        rating: (j['rating'] ?? 0) is int
            ? j['rating']
            : int.tryParse('${j['rating']}') ?? 0,
        createdAt: '${j['created_at'] ?? ''}',
      );
}

class MessageItem {
  final String appId;
  final String appName;
  final String fromUser;
  final String content;
  final int rating;
  final String time;

  MessageItem({
    required this.appId,
    required this.appName,
    required this.fromUser,
    required this.content,
    required this.rating,
    required this.time,
  });

  factory MessageItem.fromJson(Map<String, dynamic> j) => MessageItem(
        appId: '${j['app_id'] ?? ''}',
        appName: '${j['app_name'] ?? ''}',
        fromUser: '${j['from_user'] ?? ''}',
        content: '${j['content'] ?? ''}',
        rating: (j['rating'] ?? 0) is int
            ? j['rating']
            : int.tryParse('${j['rating']}') ?? 0,
        time: '${j['time'] ?? ''}',
      );
}

class PendingItem {
  final String id;
  final String name;
  final String version;
  final String size;
  final String submittedBy;
  final String createdAt;

  PendingItem({
    required this.id,
    required this.name,
    required this.version,
    required this.size,
    required this.submittedBy,
    required this.createdAt,
  });

  factory PendingItem.fromJson(Map<String, dynamic> j) => PendingItem(
        id: '${j['id'] ?? ''}',
        name: '${j['name'] ?? ''}',
        version: '${j['version'] ?? ''}',
        size: '${j['size'] ?? ''}',
        submittedBy: '${j['submitted_by'] ?? ''}',
        createdAt: '${j['created_at'] ?? ''}',
      );
}
