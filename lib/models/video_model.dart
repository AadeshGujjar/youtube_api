class Video{
  final String id;
  final String title;
  final String thumbnailUrl;
  final String channelTitle;

  Video({
   this.id,
   this.title,
   this.thumbnailUrl,
   this.channelTitle,
});

  //passing in our decoder JSON data adn read out the values of videoId,videoTitle,thumbnail,channelTitle.
  factory Video.fromMap(Map<String,dynamic> snippet){
    return Video(
      id: snippet['resourceId']['videoId'],
      title: snippet['title'],
      thumbnailUrl: snippet['thumbnails']['high']['url'],
      channelTitle: snippet['channelTitle'],
    );
  }
}