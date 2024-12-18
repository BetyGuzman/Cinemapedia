import 'package:flutter/material.dart';

// import '../../views/views.dart';
import '../../views/views.dart';
import '../../widgets/widgets.dart';

class HomeScreen extends StatelessWidget {
  static const name = 'home-screen';
  final int pageIndex;

  // final Widget childView;
  const HomeScreen(
      {super.key,
      // required this.childView,
      required this.pageIndex});

  final viewRoutes = const <Widget>[
    HomeView(),
    SizedBox(), //Catgorias
    FavoritesView()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: pageIndex,
        children: viewRoutes,
      ),
      // body: childView,
      bottomNavigationBar:  CustomBottomNavigation(
        currentIndex: pageIndex
      ),
    );
  }
}
