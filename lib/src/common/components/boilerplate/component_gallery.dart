import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/components.dart';

/// Dev-only visual QA showcase rendering every shared component.
///
/// Not wired into the production GoRouter — push it manually from a dev entry
/// point (e.g. `Navigator.push(... ComponentGallery())`) to eyeball fidelity.
class ComponentGallery extends StatefulWidget {
  const ComponentGallery({super.key});

  @override
  State<ComponentGallery> createState() => _ComponentGalleryState();
}

class _ComponentGalleryState extends State<ComponentGallery> {
  int _segIndex = 0;
  bool _switchOn = true;
  bool _checked = true;
  int _radioIndex = 0;
  int _dayIndex = 0;
  bool _shopBought = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(title: const Text('Component Gallery')),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.sp20),
        children: [
          _section('Pill buttons', [
            const AppPillButton(label: 'Primary', onPressed: _noop),
            const SizedBox(height: AppSizes.sm),
            const AppPillButton(
              label: 'Secondary',
              onPressed: _noop,
              variant: AppPillButtonVariant.secondary,
            ),
            const SizedBox(height: AppSizes.sm),
            const AppPillButton(
              label: 'Ghost',
              onPressed: _noop,
              variant: AppPillButtonVariant.ghost,
            ),
            const SizedBox(height: AppSizes.sm),
            const AppPillButton(
              label: 'Destructive',
              onPressed: _noop,
              variant: AppPillButtonVariant.destructive,
            ),
            const SizedBox(height: AppSizes.sm),
            const AppPillButton(label: 'Disabled', onPressed: null),
            const SizedBox(height: AppSizes.sm),
            const Row(
              children: [
                AppPillButton(
                  label: 'Small',
                  onPressed: _noop,
                  size: AppPillButtonSize.small,
                  expand: false,
                ),
              ],
            ),
          ]),
          _section('Round buttons', [
            const Row(
              children: [
                AppRoundButton(icon: Icon(Icons.arrow_back), onPressed: _noop),
                SizedBox(width: AppSizes.sm),
                AppRoundButton(
                  icon: Icon(Icons.more_horiz),
                  onPressed: _noop,
                  tone: AppRoundButtonTone.ghost,
                ),
                SizedBox(width: AppSizes.sm),
                AppRoundButton(
                  icon: Icon(Icons.add),
                  onPressed: _noop,
                  tone: AppRoundButtonTone.green,
                ),
                SizedBox(width: AppSizes.sm),
                AppRoundButton(
                  icon: Icon(Icons.close),
                  onPressed: _noop,
                  size: AppRoundButtonSize.small,
                ),
              ],
            ),
          ]),
          _section('Cards', [
            const AppCard(child: Text('Plain white card')),
            const SizedBox(height: AppSizes.sm),
            const AppCard(
              variant: AppCardVariant.soft,
              child: Text('Soft butter card'),
            ),
            const SizedBox(height: AppSizes.sm),
            const AppCard(
              variant: AppCardVariant.dashed,
              child: Text('Dashed card'),
            ),
            const SizedBox(height: AppSizes.sm),
            const TipCard(
              title: 'Getting Started Tips',
              body:
                  'Start with single-ingredient purees and introduce one new '
                  'food every 3-5 days.',
            ),
          ]),
          _section('Chips', [
            const Wrap(
              spacing: AppSizes.sm,
              runSpacing: AppSizes.sm,
              children: [
                AppChip(label: 'Neutral'),
                AppChip(label: 'Safe', tone: AppChipTone.safe),
                AppChip(label: 'Warn', tone: AppChipTone.warn),
                AppChip(label: 'Flag', tone: AppChipTone.flag),
                AppChip(label: 'Mute', tone: AppChipTone.mute),
                AppChip(label: 'Butter', tone: AppChipTone.butter),
                AppChip(label: 'Green', tone: AppChipTone.green),
                AppChip(label: 'Fruit', emoji: '🍎'),
              ],
            ),
          ]),
          _section('Inputs', [
            const AppTextField(label: 'First Name', hintText: 'Asther'),
            const SizedBox(height: AppSizes.sm),
            const AppTextField(
              label: 'Password',
              obscureText: true,
              errorText: 'Must be at least 8 characters.',
            ),
            const SizedBox(height: AppSizes.sm),
            const AppSearchField(hintText: 'Search recipes...'),
          ]),
          _section('Controls', [
            AppSegmentedControl(
              segments: const ['List', 'Bought'],
              selectedIndex: _segIndex,
              onChanged: (i) => setState(() => _segIndex = i),
            ),
            const SizedBox(height: AppSizes.md),
            Row(
              children: [
                AppSwitch(
                  value: _switchOn,
                  onChanged: (v) => setState(() => _switchOn = v),
                ),
                const SizedBox(width: AppSizes.md),
                AppCheckbox(
                  value: _checked,
                  onChanged: (v) => setState(() => _checked = v),
                ),
                const SizedBox(width: AppSizes.md),
                RadioPill(
                  label: 'Yes',
                  selected: _radioIndex == 0,
                  onTap: () => setState(() => _radioIndex = 0),
                ),
                const SizedBox(width: AppSizes.sm),
                RadioPill(
                  label: 'No',
                  selected: _radioIndex == 1,
                  onTap: () => setState(() => _radioIndex = 1),
                ),
              ],
            ),
          ]),
          _section('Calendar', [
            WeekStrip(
              days: _sampleWeek(_dayIndex),
              onDaySelected: (i) => setState(() => _dayIndex = i),
            ),
          ]),
          _section('Header', [
            const AppHeader(
              title: 'Nibbles',
              leading: AppRoundButton(
                icon: Icon(Icons.arrow_back),
                onPressed: _noop,
              ),
              trailing: AppRoundButton(
                icon: Icon(Icons.person_outline),
                onPressed: _noop,
              ),
              subline: 'Oliver is 6 months 12 days today!',
            ),
            const SizedBox(height: AppSizes.sm),
            const AppHeader(title: 'Recipes', wash: AppHeaderWash.cream),
          ]),
          _section('Progress', [
            const Row(
              children: [
                AppProgressRing(value: 1, max: 11),
                SizedBox(width: AppSizes.lg),
                Expanded(
                  child: Column(
                    children: [
                      AppLinearProgress(value: 0.66),
                      SizedBox(height: AppSizes.sm),
                      AppLinearProgress(
                        value: 0.42,
                        variant: AppLinearProgressVariant.green,
                      ),
                      SizedBox(height: AppSizes.sm),
                      AppLinearProgress(
                        value: 0.8,
                        variant: AppLinearProgressVariant.butter,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ]),
          _section('Shop rows', [
            ShopRow(
              label: 'Bananas',
              isBought: _shopBought,
              onToggle: () => setState(() => _shopBought = !_shopBought),
              onDelete: () {},
            ),
            const SizedBox(height: AppSizes.sm),
            ShopRow(
              label: 'A really long ingredient name that should ellipsize',
              isBought: false,
              onToggle: () {},
              onDelete: () {},
            ),
            const SizedBox(height: AppSizes.sm),
            ShopRow(
              label: 'Whole-wheat pasta',
              isBought: true,
              onToggle: () {},
              onDelete: () {},
            ),
          ]),
          _section('Empty state', [
            EmptyState(
              title: "You don't have any list yet",
              subtitle: 'Add an ingredient to start your shopping list.',
              ctaLabel: '+ Add ingredient',
              onCtaPressed: () {},
            ),
          ]),
          _section('Brand', [const Center(child: Quatrefoil(size: 120))]),
        ],
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: AppSizes.sm),
          ...children,
        ],
      ),
    );
  }

  static List<WeekDay> _sampleWeek(int selected) {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return List.generate(labels.length, (i) {
      final DayChipState state;
      if (i == selected) {
        state = DayChipState.selected;
      } else if (i == 3 || i == 5) {
        state = DayChipState.filled;
      } else {
        state = DayChipState.idle;
      }
      return WeekDay(dayOfWeek: labels[i], date: '${18 + i} Apr', state: state);
    });
  }
}

void _noop() {}
