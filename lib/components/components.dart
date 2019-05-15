import 'package:meta/meta.dart';
import 'package:entitas_ff/entitas_ff.dart';

enum Team { X, O }

enum GameState { active, inactive }

// Track which tile this is.
class IndexComponent extends Component {
  final int value;

  IndexComponent(this.value);
}

// Which team this tile belongs to.
class TeamComponent extends Component {
  final Team value;

  TeamComponent(this.value);
}

// This will keep track of whose turn it is.
class TurnComponent extends UniqueComponent {
  final Team value;

  TurnComponent(this.value);
}

// To alert the system when we figure out if we have a winner!
class GameStateComponent extends UniqueComponent {
  final GameState state;
  final String message;
  final Team winningTeam;

  GameStateComponent({@required this.state, this.message, this.winningTeam});
}

///
/// Events are stored here.
///

// This will change whose turn it is.
class ChangeTurnComponent extends UniqueComponent {}
