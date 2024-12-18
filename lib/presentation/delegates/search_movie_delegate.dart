import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:cinemapedia/config/helpers/human_formats.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/movie.dart';

typedef SearchMoviesCallback = Future<List<Movie>> Function(String query);

class SearchMovieDelegate extends SearchDelegate<Movie?> {
  final SearchMoviesCallback searchMovies;
  List<Movie> initialMovies;

  StreamController<List<Movie>> debouncedMovies = StreamController.broadcast();

  StreamController<bool> isLoadingStream = StreamController.broadcast();

  Timer? _debounceTimer;

  SearchMovieDelegate(
      {required this.initialMovies, required this.searchMovies});

  void clearStream() {
    debouncedMovies.close();
  }

  void _onQueryChange(String query) {
    isLoadingStream.add(true);

    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      // if (query.isEmpty) { debouncedMovies.add([]); return; } Se cambia la condicion en el datasource de infraestructura
      final movies = await searchMovies(query);
      initialMovies = movies;
      debouncedMovies.add(movies);

      isLoadingStream.add(false);
    });
  }

  @override //Sobreescribe el "search" escrito en el buscador
  String get searchFieldLabel => 'Buscar ';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      StreamBuilder(
        initialData: true,
        stream: isLoadingStream.stream,
        builder: (context, snapshot) {
          if (snapshot.data ?? false) {
            return SpinPerfect(
                duration: const Duration(seconds: 5),
                infinite: true,
                animate: query.isNotEmpty,
                child: IconButton(
                    onPressed: () => query = '',
                    icon: const Icon(Icons.refresh_rounded)));
          }
          return FadeIn(
              animate: query.isNotEmpty,
              duration: const Duration(milliseconds: 200),
              child: IconButton(
                  onPressed: () => query = '', icon: const Icon(Icons.clear)));
        },
      )

      // if (query.isNotEmpty)
      // SpinPerfect(
      //     duration: const Duration(seconds: 20),
      //     infinite: true,
      //     animate: query.isNotEmpty,
      //     child: IconButton(
      //         onPressed: () => query = '',
      //         icon: const Icon(Icons.refresh_rounded))),
      // FadeIn(
      //     animate: query.isNotEmpty,
      //     duration: const Duration(milliseconds: 200),
      //     child: IconButton(
      //         onPressed: () => query = '', icon: const Icon(Icons.clear)))
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () {
          clearStream();
          close(context, null);
        },
        icon: const Icon(Icons.arrow_back_ios_new_rounded));
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildResultsAndSuggestions();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    _onQueryChange(query);

    return buildResultsAndSuggestions();
  }

  Widget buildResultsAndSuggestions() {
    return StreamBuilder(
        // return FutureBuilder(
        // future: searchMovies(query),
        initialData: initialMovies,
        stream: debouncedMovies.stream,
        builder: (context, snapshot) {
          final movies = snapshot.data ?? [];
          return ListView.builder(
              itemCount: movies.length,
              itemBuilder: (context, index) => _MovieItem(
                    movie: movies[index],
                    onMovieSelected: (context, movie) {
                      clearStream();
                      close(context, movie);
                    },
                  ));
        });
  }
}

class _MovieItem extends StatelessWidget {
  final Movie movie;
  final Function onMovieSelected;

  const _MovieItem({required this.movie, required this.onMovieSelected});

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme;
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        onMovieSelected(context, movie);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          children: [
            //Image
            SizedBox(
              width: size.width * 0.2,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  movie.posterPath,
                  loadingBuilder: (context, child, loadingProgress) =>
                      FadeIn(child: child),
                ),
              ),
            ),
            //Separacion
            const SizedBox(
              width: 10,
            ),
            //Description
            SizedBox(
              width: size.width * 0.7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: textStyle.titleMedium,
                  ),
                  //acotael overview a 100 caracteres
                  (movie.overview.length > 100)
                      ? Text('${movie.overview.substring(0, 100)}...')
                      : Text(movie.overview),

                  Row(
                    children: [
                      Icon(
                        Icons.star_half_rounded,
                        color: Colors.yellow.shade800,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        HumanFormats.number(movie.voteAverage, 1),
                        style: textStyle.bodyMedium!
                            .copyWith(color: Colors.yellow.shade900),
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
