import 'package:entitas_ff/entitas_ff.dart';
import 'package:flutter/material.dart';

import 'components/components.dart';
import 'systems/systems.dart';
import 'ui/tile_board.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final em = EntityManager();
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return EntityManagerProvider(
      entityManager: em,
      systems: RootSystem(em, [
        InitGameSystem(),
        TurnSystem(),
        CheckWinConditionSystem(),
      ]),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blue,
        ),
        home: HomePage(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  Widget _getIcon(GameState state) {
    switch (state) {
      case GameState.active:
        return Icon(Icons.stop);
      case GameState.inactive:
        return Icon(Icons.add);
      default:
        return Icon(Icons.add);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tic-Tac-Toe")),
      body: TileBoard(),
      floatingActionButton: EntityObservingWidget(
        provider: (m) => m.getUniqueEntity<GameStateComponent>(),
        builder: (e, context) {
          final active = e.get<GameStateComponent>().state;
          return FloatingActionButton(
            onPressed: () {
              switch (active) {
                case GameState.inactive:
                  EntityManagerProvider.of(context)
                      .entityManager
                      .setUnique(GameStateComponent(state: GameState.active));
                  break;
                case GameState.active:
                  EntityManagerProvider.of(context)
                      .entityManager
                      .setUnique(GameStateComponent(state: GameState.inactive));
                  break;
              }
            },
            child: _getIcon(active),
          );
        },
      ),
    );
  }
}
