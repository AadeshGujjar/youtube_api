import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:youtube_api/models/channel_model.dart';
import 'package:youtube_api/models/video_model.dart';
import 'package:youtube_api/utilities/keys.dart';

class APIService{

  //to keep track of nextPageToken throughout the lifetime of our app we create this singelton class
  APIService._instantiate();

  static final APIService instance=APIService._instantiate();

  //first part of the url that we request data from.
  final String _baseUrl='www.googleapis.com';

  //stores the string value used to identify the next batch of videos when batchinating our data/
  String _nextPageToken='';

  Future<Channel> fetchChannel({String channelId}) async{
    Map<String,String> parameters={
      'part': 'snippet,contentDetails,statistics',
      'id': channelId,
      'key': API_KEY,
    };

    //parameters specify the data that we want to recieve from the API like snippet, content details, statistics
    //it contains the id of the channel we want to view and our API key to authenticate our get request
    Uri uri=Uri.https(_baseUrl, 'youtube/v3/channels',parameters);

    //contents of out header variables ensures that our get request return a JSON object
    Map<String,String> headers={
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    //Getting Channel, To get the response from our get request
    var response= await http.get(uri,headers: headers);

    if(response.statusCode==200){
      Map<String,dynamic> data=jsonDecode(response.body)['items'][0];
      Channel channel= Channel.fromMap(data);

      //Fetch first batch of videos from upload playlist
      channel.videos= await fetchVideosFromPlaylist(
        playlistId: channel.uploadPlayListId,
      );
      return channel;
    }
    else{
      throw jsonDecode(response.body)['error']['message'];
    }

  }

  Future<List<Video>> fetchVideosFromPlaylist({String playlistId}) async {
    Map<String,String> parameters={
      'part':'snippet',
      'playlistId': playlistId,
      'maxResults': '8',
      'pageToken': _nextPageToken,
      'key':API_KEY,
    };

    Uri uri= Uri.https(_baseUrl,'youtube/v3/playlistItems',parameters);

    Map<String,String> headers={
      HttpHeaders.contentTypeHeader:'application/json',
    };

    //Get Playlist Videos

    var response=await http.get(uri,headers: headers);
    if(response.statusCode==200)
      {
        var data=jsonDecode(response.body);
        _nextPageToken=data['nextPageTokes']??'';
        List<dynamic> videosJson=data['items'];

        //Fetch first eight videos from uploads playlist
        List<Video> videos=[];
        videosJson.forEach(
            (json)=>videos.add(Video.fromMap(json['snippet']),
            ),
        );
        return videos;
    }

    else{
      throw jsonDecode(response.body)['error']['message'];
      }

  }


}