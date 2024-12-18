// import 'package:cinemapedia/presentation/screens/movies/home_screen.dart';
import 'package:go_router/go_router.dart';
// import 'package:cinemapedia/presentation/views/views.dart';

import '../../presentation/screens/screens.dart';

//Tercer Prueba Actualizada
final appRouter = GoRouter(initialLocation: '/home/0', routes: [
  GoRoute(
      path: '/home/:page',
      name: HomeScreen.name,
      builder: (context, state) {
        final pageIndex = state.pathParameters['page'] ?? '0';
        return HomeScreen(
          pageIndex: int.parse(pageIndex),
        );
      },
      routes: [
        GoRoute(
          path: 'movie/:id',
          name: MovieScreen.name,
          builder: (context, state) {
            final movieId = state.pathParameters['id'] ?? 'no-id';
            return MovieScreen(movieId: movieId);
          },
        ),
        GoRoute(path: '/', redirect: (_, __) => 'home/0')
      ]),
]);


// Primer prueba
// final appRouter = GoRouter(initialLocation: '/', routes: [
 // GoRoute(
  //     path: '/',
  //     name: HomeScreen.name,
  //     builder: (context, state) => const HomeScreen(
  //           childView: HomeView(),
  //         ),
  //     routes: [
  //       GoRoute(
  //         path: 'movie/:id',
  //         name: MovieScreen.name,
  //         builder: (context, state) {
  //           final movieId = state.pathParameters['id'] ?? 'no-id';
  //           return MovieScreen(movieId: movieId);
  //         },
  //       ),
  //     ]),
// ]);



// Segunda Prueba
  
// final appRouter = GoRouter(initialLocation: '/', routes: [
  // ShellRoute(
  //     builder: (context, state, child) {
  //       return HomeScreen(
  //         childView: child,
  //       );
  //     },
  //     routes: [
  //       GoRoute(
  //           path: '/',
  //           builder: (context, state) {
  //             return const HomeView();
  //           },
  //           routes: [
  //             GoRoute(
  //               path: 'movie/:id',
  //               name: MovieScreen.name,
  //               builder: (context, state) {
  //                 final movieId = state.pathParameters['id'] ?? 'no-id';
  //                 return MovieScreen(movieId: movieId);
  //               },
  //             ),
  //           ]),
  //       GoRoute(
  //         path: '/favorites',
  //         builder: (context, state) {
  //           return const FavoritesView();
  //         },
  //       )
  //     ])
// ]);