import 'package:flutter_test/flutter_test.dart';
import 'package:nouri/domain/models.dart';

void main() {
  test('plan item preserves completion state', () {
    const item = PlanItem(
      id: '1',
      date: '2026-07-18',
      slot: MealSlot.lunch,
      recipeId: 'miso_salmon',
      servings: 2,
    );

    final completed = item.copyWith(completed: true);

    expect(completed.completed, isTrue);
    expect(completed.servings, 2);
    expect(PlanItem.fromJson(completed.toJson()).slot, MealSlot.lunch);
  });
}
