// import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cinemapedia/domain/entities/movie.dart';

import '../../providers/providers.dart';

class MovieScreen extends ConsumerStatefulWidget {
  static const name = 'movie-screen';
  final String movieId;

  const MovieScreen({super.key, required this.movieId});

  @override
  // State<MovieScreen> createState() => _MovieScreenState(); como se cambio aConsumer se cmbia esto

  MovieScreenState createState() => MovieScreenState();
}

class MovieScreenState extends ConsumerState<MovieScreen> {
  @override
  void initState() {
    super.initState;

    ref.read(movieInfoProvider.notifier).loadMovie(widget.movieId);

    ref.read(actorsByMovieProvider.notifier).loadActors(widget.movieId);
  }

  @override
  Widget build(BuildContext context) {
    final Movie? movie = ref.watch(movieInfoProvider)[widget.movieId];
    if (movie == null) {
      return const Scaffold(
        body: Center(
            child: CircularProgressIndicator(
          strokeWidth: 2,
        )),
      );
    }
    return Scaffold(
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(), //Evita el rebote de la pantalla
        slivers: [
          _CustomSliverAppBar(movie: movie),
          SliverList(
              delegate: SliverChildBuilderDelegate(
                  (context, index) => _MovieDetails(movie: movie),
                  childCount: 1))
        ],
      ),
    );
  }
}

class _MovieDetails extends StatelessWidget {
  final Movie movie;
  const _MovieDetails({required this.movie});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final textStyles = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  movie.posterPath,
                  width: size.width * 0.3,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              //Descripcion
              SizedBox(
                width: (size.width - 40) * 0.7,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      style: textStyles.titleLarge,
                    ),
                    Text(
                      movie.overview,
                    )
                  ],
                ),
              )
            ],
          ),
        ),
        //Categorias de pelicula
        Padding(
          padding: const EdgeInsets.all(8),
          child: Wrap(
            children: [
              ...movie.genreIds.map((gender) => Container(
                    margin: const EdgeInsets.only(right: 10),
                    child: Chip(
                      label: Text(gender),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                  ))
            ],
          ),
        ),

        //Actores y actrices
        _ActorsByMovie(movieId: movie.id.toString()),

        //Espacio paa scroll
        const SizedBox(
          height: 50,
        )
      ],
    );
  }
}

class _ActorsByMovie extends ConsumerWidget {
  final String movieId;
  const _ActorsByMovie({required this.movieId});

  @override
  Widget build(BuildContext context, ref) {
    final actorByMovie = ref.watch(actorsByMovieProvider);
    if (actorByMovie[movieId] == null) {
      return const CircularProgressIndicator(
        strokeWidth: 2,
      );
    }
    final actors = actorByMovie[movieId]!;
    return SizedBox(
      height: 300,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: actors.length,
        itemBuilder: (context, index) {
          final actor = actors[index];

          return Container(
            padding: const EdgeInsets.all(8.0),
            width: 135,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeInRight(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      actor.profilePath,
                      height: 180,
                      width: 135,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                //Separacion
                const SizedBox(
                  height: 5,
                ),
                //Nombres e informacion
                Text(
                  actor.name,
                  maxLines: 2,
                ),
                Text(
                  actor.character ?? '',
                  maxLines: 2,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CustomSliverAppBar extends ConsumerWidget {
  final Movie movie;
  const _CustomSliverAppBar({required this.movie});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    return SliverAppBar(
      backgroundColor: Colors.black,
      expandedHeight: size.height * 0.7,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
            onPressed: () {
              ref.watch(localStorageRepositoryProvider).toggleFavorite(movie);
            },
            icon: const Icon(
              Icons.favorite_border,
            )
            // icon: const Icon(
            //   Icons.favorite_rounded,
            //   color: Colors.red,
            // )
            )
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        // title: Text(
        //   movie.title,
        //   style: const TextStyle(fontSize: 20, color: Colors.white),
        //   textAlign: TextAlign.start,
        // ),
        background: Stack(
          children: [
            SizedBox.expand(
              child: Image.network(
                movie.backdropPath,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress != null) return const SizedBox();
                  return FadeIn(child: child);
                },
              ),
            ),
            //Linea de abajo
            const _CustomGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                stops: [
                  0.0,
                  0.2
                ],
                colors: [
                  Colors.black87,
                  Colors.transparent,
                ]), ///////////////////////////
            //Corazon
            const _CustomGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [
                  0.8,
                  1.0
                ],
                colors: [
                  Colors.transparent,
                  Colors.black54,
                ]),
            //Flecha
            const _CustomGradient(
                begin: Alignment.topLeft,
                stops: [0.0, 0.3],
                colors: [Colors.black87, Colors.transparent]),
          ],
        ),
      ),
    );
  }
}

class _CustomGradient extends StatelessWidget {
  final List<Color> colors;

  final AlignmentGeometry end;

  final AlignmentGeometry begin;

  final List<double> stops;

  const _CustomGradient(
      {required this.colors,
      this.end = Alignment.centerLeft,
      this.begin = Alignment.centerRight,
      required this.stops});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: DecoratedBox(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: begin, stops: stops, end: end, colors: colors))),
    );
  }
}
