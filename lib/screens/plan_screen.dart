import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/meal_planner_bloc.dart';
//import '../models/meal.dart';
import '../widgets/plan_day_card.dart';
import 'browse_meals_screen.dart';

// Design tokens
const kPrimary = Color(0xFF1A1F3A);
const kAccent = Color(0xFFF5A623);
const kBackground = Color(0xFFF4F5F9);
const kSurface = Colors.white;
const kTextDim = Color(0xFF8A8FA8);

class PlanScreen extends StatelessWidget {
  const PlanScreen({super.key});

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _slots = ['Breakfast', 'Lunch', 'Snack', 'Dinner'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: const Text('Meal Planner',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20)),
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          BlocBuilder<MealPlannerBloc, MealPlannerState>(
            builder: (ctx, state) => state.plannedMeals.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.delete_sweep_outlined),
                    tooltip: 'Clear Plan',
                    onPressed: () => _confirmClearPlan(ctx),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: BlocBuilder<MealPlannerBloc, MealPlannerState>(
        builder: (ctx, state) {
          if (state.plannedMeals.isEmpty) return _buildEmptyPlan(ctx);
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: _days.length,
            itemBuilder: (_, i) {
              final day = _days[i];
              final dayMeals = {
                for (final slot in _slots)
                  slot: state.plannedMeals
                      .where((p) => p.dayLabel == day && p.mealTime == slot)
                      .firstOrNull,
              };
              return PlanDayCard(
                day: day,
                dayMeals: dayMeals,
                slots: _slots,
                onAdd: (slot) => _openPicker(ctx, day, slot),
                onRemove: (id) => ctx
                    .read<MealPlannerBloc>()
                    .add(RemoveMealFromPlanEvent(id)),
                onReplace: (slot) => _openPicker(ctx, day, slot),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showDaySlotPicker(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Meal',
            style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: kAccent,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
    );
  }

  void _showDaySlotPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: kSurface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _DaySlotPickerSheet(
        days: _days,
        slots: _slots,
        onPick: (day, slot) {
          Navigator.pop(context);
          _openPicker(context, day, slot);
        },
      ),
    );
  }

  void _openPicker(BuildContext context, String day, String slot) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BrowseMealsScreen(targetDay: day, targetSlot: slot),
      ),
    );
  }

  Widget _buildEmptyPlan(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                  color: kPrimary.withOpacity(0.08), shape: BoxShape.circle),
              child: const Icon(Icons.calendar_month_outlined,
                  size: 48, color: kPrimary),
            ),
            const SizedBox(height: 24),
            const Text('Your week is empty',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: kPrimary)),
            const SizedBox(height: 8),
            const Text('Tap "Add Meal" to start building your weekly plan.',
                textAlign: TextAlign.center,
                style: TextStyle(color: kTextDim, fontSize: 15, height: 1.5)),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => _showDaySlotPicker(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Your First Meal'),
              style: FilledButton.styleFrom(
                backgroundColor: kAccent,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                textStyle:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmClearPlan(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear entire plan?',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('All meals will be removed from your weekly plan.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              context.read<MealPlannerBloc>().add(const ClearPlanEvent());
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}

class _DaySlotPickerSheet extends StatefulWidget {
  final List<String> days;
  final List<String> slots;
  final void Function(String day, String slot) onPick;

  const _DaySlotPickerSheet(
      {required this.days, required this.slots, required this.onPick});

  @override
  State<_DaySlotPickerSheet> createState() => _DaySlotPickerSheetState();
}

class _DaySlotPickerSheetState extends State<_DaySlotPickerSheet> {
  String? _selectedDay;
  String? _selectedSlot;

  static const _slotIcons = {
    'Breakfast': Icons.wb_sunny_outlined,
    'Lunch': Icons.lunch_dining_outlined,
    'Snack': Icons.apple_outlined,
    'Dinner': Icons.dinner_dining_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Which day?',
              style: TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 16, color: kPrimary)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.days.map((day) {
              final sel = _selectedDay == day;
              return GestureDetector(
                onTap: () => setState(() => _selectedDay = day),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: sel ? kPrimary : kBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: sel ? kPrimary : Colors.grey.shade300),
                  ),
                  child: Text(day,
                      style: TextStyle(
                          color: sel ? Colors.white : kPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          const Text('Which meal?',
              style: TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 16, color: kPrimary)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.slots.map((slot) {
              final sel = _selectedSlot == slot;
              return GestureDetector(
                onTap: () => setState(() => _selectedSlot = slot),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: sel ? kAccent : kBackground,
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: sel ? kAccent : Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_slotIcons[slot] ?? Icons.restaurant_outlined,
                          size: 16, color: sel ? Colors.white : kTextDim),
                      const SizedBox(width: 6),
                      Text(slot,
                          style: TextStyle(
                              color: sel ? Colors.white : kPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 14)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _selectedDay != null && _selectedSlot != null
                  ? () => widget.onPick(_selectedDay!, _selectedSlot!)
                  : null,
              style: FilledButton.styleFrom(
                backgroundColor: kPrimary,
                disabledBackgroundColor: Colors.grey.shade200,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Browse Meals',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}
