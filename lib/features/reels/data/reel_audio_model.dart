// to store the structure of the audio data received from the api/ convert json to model and vice versa

class ReelAudio {
  final String id;
  final String title;
  final String audioUrl;
  final String imagePath;
  final String username;
  final int likesCount;
  final int listensCount;

  ReelAudio({
    required this.id,
    required this.title,
    required this.audioUrl,
    required this.imagePath,
    required this.username,
    required this.likesCount,
    required this.listensCount,
  });

  factory ReelAudio.fromJson(Map<String, dynamic> json) {
    final String audioUrl =
        (json['preferredSignedUrl'] as String?)?.trim().isNotEmpty == true
            ? json['preferredSignedUrl']
            : (json['nativeSignedUrl'] as String? ?? '');
            
    final uploadedUser = json['uploadedUser'] as Map<String, dynamic>?;

    return ReelAudio(
      id: json['jamId']?.toString() ?? '',
      title: json['title_text_gcp_path']?.toString() ?? 'Untitled',
      audioUrl: audioUrl,
      imagePath: json['image_gcp_path']?.toString() ?? '',
      username: uploadedUser?['username']?.toString() ?? 'Unknown',
      likesCount: (json['likesCount'] as int?) ?? 0,
      listensCount: (json['listensCount'] as int?) ?? 0,
    );
  }
}
