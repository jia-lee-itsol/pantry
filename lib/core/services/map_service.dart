import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/map/domain/repositories/map_repository.dart';
import '../../features/map/data/datasources/map_google_places_datasource.dart';
import '../../features/map/data/repositories_impl/map_repository_impl.dart';

/// Map Service Provider
///
/// Provides the map repository implementation using dependency injection.
/// This provider creates and manages the map data source and repository
/// for handling location-based services and place searches throughout the application.
///
/// The repository uses Google Places API as the data source for finding
/// nearby stores and locations.
final mapServiceProvider = Provider<MapRepository>((ref) {
  final remoteDataSource = MapGooglePlacesDataSource();
  return MapRepositoryImpl(remoteDataSource);
});

