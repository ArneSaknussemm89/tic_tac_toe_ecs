import 'package:flutter/material.dart';
import 'package:entitas_ff/entitas_ff.dart';

import '../components/components.dart';
import 'tile.dart';

class TileBoard extends StatelessWidget {
  Widget _buildGrid(
      BuildContext context, List<Entity> entities, GameStateComponent state) {
    return Container(
      child: Center(
        child: state.winningTeam == null
            ? GridView.count(
                padding: EdgeInsets.all(8.0),
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
                crossAxisCount: 3,
                children: entities
                    .map((tile) => Tile(
                        tile: tile,
                        disabled: state.state == GameState.inactive))
                    .toList(),
              )
            : Center(
                child: Text(
                  state.message,
                  style: TextStyle(
                      fontSize:
                          Theme.of(context).primaryTextTheme.display3.fontSize),
                ),
              ),
      ),
    );
  }

  Widget _buildBottomRow(BuildContext context, String team) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Text(
          "TURN:",
          style: TextStyle(
              fontSize: Theme.of(context).primaryTextTheme.display1.fontSize),
        ),
        Container(
          padding: EdgeInsets.only(left: 8.0),
        ),
        Text(
          team,
          style: TextStyle(
              fontSize: Theme.of(context).primaryTextTheme.display1.fontSize),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return EntityObservingWidget(
      provider: (m) => m.getUniqueEntity<GameStateComponent>(),
      builder: (e, context) {
        GameStateComponent state = e.get<GameStateComponent>();

        return Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            // First let's render a centered title
            if (state.state == GameState.active) ...[
              Expanded(
                child: Container(
                  child: GroupObservingWidget(
                    matcher:
                        EntityMatcher(any: [IndexComponent, TeamComponent]),
                    builder: (group, context) =>
                        _buildGrid(context, group.entities, state),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: EntityObservingWidget(
                    provider: (m) => m.getUniqueEntity<TurnComponent>(),
                    builder: (e, context) {
                      final turn = e.get<TurnComponent>().value;

                      // I like enum's; but we gotta get around a small weirdness
                      final String team = turn.toString().split('.').last;

                      return Container(
                        padding: EdgeInsets.only(top: 32.0, bottom: 32.0),
                        child: _buildBottomRow(context, team),
                      );
                    },
                  ),
                ),
              ),
            ],
            if (state.state == GameState.inactive)
              Expanded(
                child: Center(
                  child: const Text(
                    "Click the circular button to start a match!",
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
