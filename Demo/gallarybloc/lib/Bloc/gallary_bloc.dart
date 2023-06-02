import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:gallarybloc/Model/ModelGallary.dart';
import 'package:meta/meta.dart';
import 'package:flutter_storage_path/flutter_storage_path.dart';
part 'gallary_event.dart';
part 'gallary_state.dart';

class GallaryBloc extends Bloc<GallaryEvent, GallaryState> {
  GallaryBloc() : super(GallaryInitial()) {
    on<FetchStorageDataEvent>((event, emit) async {
      emit(GallaryLoadingState());

      try {
        final response = await StoragePath.imagesPath;
        final albumJson = jsonDecode(response!) as List<dynamic>;
        final album = albumJson.map((album) => AlbumModel.fromJson(album)).toList();

        final videoResponse = await StoragePath.videoPath;
        final videoJson = jsonDecode(videoResponse!) as List<dynamic>;
        final video =
        videoJson.map((video) => VideoFIles.fromJson(video)).toList();
        emit(GallaryLoadedState(albums: album, videos: video));
      } catch (e) {
        emit(GallaryStorageErrorState("Failed to Fetch Storage Data"));
      }
    });
  }
}
