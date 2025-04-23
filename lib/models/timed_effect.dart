import 'unit.dart';

// Represents a temporary stat modifier applied to a unit (e.g. buff/debuff)
class TimedEffect {
  final Unit target;
  final String stat;
  final int amount;
  final Duration duration;
  final DateTime appliedAt;

  // Creates a new timed effect and records the application time
  TimedEffect({
    required this.target,
    required this.stat,
    required this.amount,
    required this.duration,
  }) : appliedAt = DateTime.now();

  // Applies the effect by modifying the target's stat positively
  void apply() {
    target.applyStatModifier(stat, amount);
  }

  // Reverses the effect by subtracting the amount when the duration expires
  void expire() {
    target.applyStatModifier(stat, -amount);
  }
}
