part of 'gallary_bloc.dart';

@immutable
abstract class GallaryState {}

class GallaryInitial extends GallaryState {}

class GallaryLoadingState extends GallaryState {}

class GallaryLoadedState extends GallaryState {
  final List<AlbumModel> albums;
  final List<VideoFIles> videos;

  GallaryLoadedState({required this.albums, required this.videos});
}

class GallaryStorageErrorState extends GallaryState{
  final String errorMessage;

  GallaryStorageErrorState(this.errorMessage);
}