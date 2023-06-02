import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gallarybloc/Bloc/gallary_bloc.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class FirstScreen extends StatefulWidget {
  const FirstScreen({Key? key}) : super(key: key);

  @override
  State<FirstScreen> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  @override
  void initState() {
    super.initState();
    context.read<GallaryBloc>().add(FetchStorageDataEvent());
  }
  int index = 0;
  int selectedIndex = -1;


  Future<String?> getImage(thumbnail) async {
    final thumb = await VideoThumbnail.thumbnailFile(video: thumbnail);
    return thumb;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Gallary", style: ThemeData.light().textTheme.labelSmall),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.photo),
                child: Text("videos File"),
              ),
              Tab(
                icon: Icon(Icons.videocam_sharp),
                child: Text("Photos File"),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            PhotosFiles(),
            VideosFiles()
          ],
        ),
      ),
    );
  }


  Widget VideosFiles() {
    return BlocBuilder<GallaryBloc,GallaryState>(
      builder: (context, state) {
        if(state is GallaryLoadingState){
          return Center(child: CircularProgressIndicator(),);
        }
        else if(state is GallaryLoadedState){
          final videos = state.videos;
          return Padding(
            padding: const EdgeInsets.all(14.0),
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: videos.length,
                  itemBuilder: (context, index) {
                    final video = videos[index];
                    return GestureDetector(
                      onTap: () {
                        // setState(() {
                        //   selectedIndex = index;
                        // });
                        // Navigator.push(context, MaterialPageRoute(
                        //   builder: (context) {
                        //     return AlbumVideo1(videos: video);
                        //   },
                        // ));
                      },
                      child:Stack(
                        children: [
                          FutureBuilder<String?>(
                            future: getImage(video.files!.first.path),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Center(child: const Icon(Icons.error,size: 30,color: Colors.blue,));
                              } else if (snapshot.hasData) {
                                return Image.file(
                                  File(snapshot.data!),
                                  fit: BoxFit.cover,
                                );
                              } else {
                                return const Icon(Icons.image_not_supported);
                              }
                            },
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              width: double.infinity,
                              color: index == selectedIndex
                                  ? Colors.blue.withOpacity(0.5)
                                  : Colors.transparent,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  video.folderName!,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
              ),
            ),
          );
        }
        else if(state is GallaryStorageErrorState){
          return Center(child: Text(state.errorMessage),);
        }
        else{
          return Center(child: Text("Unknown State"),);
        }
      },);
  }

  Widget PhotosFiles() {
    return BlocBuilder<GallaryBloc,GallaryState>(
      builder:  (context, state) {
        if(state is GallaryLoadingState){
          return Center(child: CircularProgressIndicator(),);
        }
        else if(state is GallaryLoadedState){
          final albums = state.albums;
          return  Padding(
            padding: const EdgeInsets.all(14.0),
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: albums.length,
                itemBuilder: (context, index) {
                  final album = albums[index];
                  print(album.toString());
                  return GestureDetector(
                    onTap: () {
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          image: DecorationImage(
                              image: FileImage(File(album.files![0])),
                              fit: BoxFit.cover)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            album.folderName ?? 'Unknown',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${album.files?.length ?? 0} images',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        }
        else if(state is GallaryStorageErrorState){
          return Center(child: Text(state.errorMessage),);
        }
        else{
          return Center(child: Text("Unknown State"),);
        }
      },);
  }
}
