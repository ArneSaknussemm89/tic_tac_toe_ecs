import 'package:meta/meta.dart';
import 'package:flutter/material.dart';
import 'package:entitas_ff/entitas_ff.dart';

import '../components/components.dart';

class Tile extends StatelessWidget {
  final Entity tile;
  final bool disabled;

  Tile({Key key, @required this.tile, this.disabled = false}) : super(key: key);

  Widget _buildMarker(Team team) {
    return Center(
      child: Text(
        team.toString().split('.').last,
        style: TextStyle(
          fontSize: 36.0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterial(context));
    final EntityManager em = EntityManagerProvider.of(context).entityManager;
    Team team = tile.get<TeamComponent>()?.value;
    var currentTurn = em.getUniqueEntity<TurnComponent>();

    return Container(
      child: Material(
        elevation: 1.0,
        child: InkWell(
          onTap: () {
            if (!tile.has(TeamComponent) && !disabled) {
              tile + TeamComponent(currentTurn.get<TurnComponent>().value);
              em.setUnique(ChangeTurnComponent());
            }
          },
          child: team != null ? _buildMarker(team) : null,
        ),
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black,
          width: 2.0,
        ),
      ),
    );
  }
}
