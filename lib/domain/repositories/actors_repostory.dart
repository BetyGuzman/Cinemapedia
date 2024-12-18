import 'package:cinemapedia/domain/entities/actor.dart';

abstract class ActorsRepostory {
  Future<List<Actor>> getActorsByMovie(String movieId);
}
