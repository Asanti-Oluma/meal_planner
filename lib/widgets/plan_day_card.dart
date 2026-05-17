import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/meal.dart';

const _kPrimary = Color(0xFF1A1F3A);
const _kAccent = Color(0xFFF5A623);
const _kBg = Color(0xFFF4F5F9);
//const _kTextDim  = Color(0xFF8A8FA8);

const _slotColors = {
  'Breakfast': Color(0xFFFFF3E0),
  'Lunch': Color(0xFFE8F5E9),
  'Snack': Color(0xFFFCE4EC),
  'Dinner': Color(0xFFE3F2FD),
};

const _slotIconColors = {
  'Breakfast': Color(0xFFF57C00),
  'Lunch': Color(0xFF2E7D32),
  'Snack': Color(0xFFC2185B),
  'Dinner': Color(0xFF1565C0),
};

const _slotIcons = {
  'Breakfast': Icons.wb_sunny_outlined,
  'Lunch': Icons.lunch_dining_outlined,
  'Snack': Icons.apple_outlined,
  'Dinner': Icons.dinner_dining_outlined,
};

class PlanDayCard extends StatelessWidget {
  final String day;
  final Map<String, PlannedMeal?> dayMeals;
  final List<String> slots;
  final void Function(String slot) onAdd;
  final void Function(String plannedMealId) onRemove;
  final void Function(String slot) onReplace;

  const PlanDayCard({
    super.key,
    required this.day,
    required this.dayMeals,
    required this.slots,
    required this.onAdd,
    required this.onRemove,
    required this.onReplace,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: _kPrimary,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Text(day,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16)),
                const Spacer(),
                Text(
                  '${dayMeals.values.where((v) => v != null).length}/${slots.length} planned',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.6), fontSize: 12),
                ),
              ],
            ),
          ),
          // Slot rows
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: slots.map((slot) {
                final planned = dayMeals[slot];
                return _SlotRow(
                  slot: slot,
                  planned: planned,
                  onAdd: () => onAdd(slot),
                  onRemove: planned != null ? () => onRemove(planned.id) : null,
                  onReplace: () => onReplace(slot),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SlotRow extends StatelessWidget {
  final String slot;
  final PlannedMeal? planned;
  final VoidCallback onAdd;
  final VoidCallback? onRemove;
  final VoidCallback onReplace;

  const _SlotRow({
    required this.slot,
    required this.planned,
    required this.onAdd,
    required this.onRemove,
    required this.onReplace,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = _slotColors[slot] ?? const Color(0xFFF5F5F5);
    final iconColor = _slotIconColors[slot] ?? _kPrimary;
    final icon = _slotIcons[slot] ?? Icons.restaurant_outlined;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Slot label with icon
          Container(
            width: 92,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 13, color: iconColor),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(slot,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: iconColor)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: planned == null
                ? _AddButton(onAdd: onAdd)
                : _PlannedTile(
                    planned: planned!,
                    onRemove: onRemove,
                    onReplace: onReplace,
                  ),
          ),
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final VoidCallback onAdd;
  const _AddButton({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onAdd,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: _kBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline,
                size: 16, color: Colors.grey.shade400),
            const SizedBox(width: 6),
            Text('Add meal',
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _PlannedTile extends StatelessWidget {
  final PlannedMeal planned;
  final VoidCallback? onRemove;
  final VoidCallback onReplace;

  const _PlannedTile({
    required this.planned,
    required this.onRemove,
    required this.onReplace,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: _kPrimary.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kPrimary.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          // Meal thumbnail
          if (planned.meal.strMealThumb != null)
            ClipRRect(
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(11)),
              child: CachedNetworkImage(
                imageUrl: '${planned.meal.strMealThumb}/preview',
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(
                  width: 56,
                  color: Colors.grey.shade200,
                  child: Icon(Icons.restaurant, color: Colors.grey.shade400),
                ),
              ),
            ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              planned.meal.strMeal,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600, color: _kPrimary),
            ),
          ),
          // Replace
          IconButton(
            icon:
                const Icon(Icons.swap_horiz_rounded, size: 18, color: _kAccent),
            onPressed: onReplace,
            tooltip: 'Replace',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          // Remove
          IconButton(
            icon: const Icon(Icons.close_rounded,
                size: 18, color: Colors.redAccent),
            onPressed: onRemove,
            tooltip: 'Remove',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}
