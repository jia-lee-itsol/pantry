import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/map/domain/repositories/map_repository.dart';
import '../../features/map/data/datasources/map_google_places_datasource.dart';
import '../../features/map/data/repositories_impl/map_repository_impl.dart';

final mapServiceProvider = Provider<MapRepository>((ref) {
  final remoteDataSource = MapGooglePlacesDataSource();
  return MapRepositoryImpl(remoteDataSource);
});

