import 'package:entitas_ff/entitas_ff.dart';

import '../components/components.dart';

class WinConditions {
  static List<Set<int>> conditions = [
    Set.of([0, 1, 2]),
    Set.of([0, 4, 8]),
    Set.of([0, 3, 6]),
    Set.of([1, 4, 7]),
    Set.of([2, 4, 6]),
    Set.of([2, 5, 8]),
    Set.of([3, 4, 5]),
    Set.of([6, 7, 8])
  ];
}

class InitGameSystem extends EntityManagerSystem implements InitSystem {
  @override
  init() {
    // Create the tiles.
    for (int i = 0; i < 9; i++) {
      entityManager.createEntity()..set(IndexComponent(i));
    }

    // Set turn to be X.
    entityManager.setUnique(TurnComponent(Team.X));

    // Set "state"
    entityManager.setUnique(GameStateComponent(state: GameState.inactive));
  }
}

class TurnSystem extends ReactiveSystem {
  @override
  GroupChangeEvent get event => GroupChangeEvent.addedOrUpdated;
  @override
  EntityMatcher get matcher => EntityMatcher(all: [ChangeTurnComponent]);

  @override
  executeWith(List<Entity> entities) {
    final turn = entityManager.getUnique<TurnComponent>().value;
    entityManager.setUnique(TurnComponent(turn == Team.X ? Team.O : Team.X));
  }
}

class CheckWinConditionSystem extends ReactiveSystem {
  @override
  GroupChangeEvent get event => GroupChangeEvent.any;

  @override
  EntityMatcher get matcher =>
      EntityMatcher(all: [IndexComponent], any: [TeamComponent]);

  @override
  executeWith(List<Entity> entities) {
    // Let's find out the score.

    /// We in theory have a board represented by tile indexes and teams.
    /// For the standard 3x3 board the indexes match up to:
    ///
    ///  0 | 1 | 2
    /// ---+---+---
    ///  3 | 4 | 5
    /// ---+---+---
    ///  6 | 7 | 8
    ///
    /// Now to figure out if someone has won, we have a list of "wins":
    /// var wins = [
    ///   [0, 1, 2]
    ///   [0, 4, 8]
    ///   [0, 3, 6]
    ///   [1, 4, 7]
    ///   [2, 4 ,6]
    ///   [2, 5, 8]
    ///   [3, 4, 5]
    ///   [6, 7, 8]
    /// ]

    // Let's fetch all the "Tiles"
    List<Entity> tiles =
        entityManager.group(all: [IndexComponent, TeamComponent]).entities;

    Set<int> selectionX = Set();
    Set<int> selectionO = Set();
    Team winningTeam;

    tiles.forEach((Entity e) {
      if (e.has(TeamComponent)) {
        switch (e.get<TeamComponent>().value) {
          case Team.O:
            selectionO.add(e.get<IndexComponent>().value);
            break;
          case Team.X:
            selectionX.add(e.get<IndexComponent>().value);
            break;
        }
      }
    });

    // Now let's see if a team's selection matches any win condition.
    WinConditions.conditions.forEach((Set<int> condition) {
      if (selectionO.containsAll(condition)) {
        // O team has indexes that are one of the win conditions
        // it's possible to get two matches at once, so if we have
        // already set the winning team we will just pass on.
        if (winningTeam == null) {
          winningTeam = Team.O;
        }
      }

      if (selectionX.containsAll(condition)) {
        // X team has indexes that are one of the win conditions
        // exit loop
        if (winningTeam == null) {
          winningTeam = Team.X;
        }
      }
    });

    if (winningTeam != null) {
      // I like enum's; but we gotta get around a small weirdness
      final String team = winningTeam.toString().split('.').last;

      entityManager.setUnique(GameStateComponent(
        state: GameState.active,
        message: "$team wins!",
        winningTeam: winningTeam,
      ));

      // Delete all tiles
      tiles.forEach((e) => e.destroy());
    }
  }
}
