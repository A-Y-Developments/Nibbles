import 'package:flutter_test/flutter_test.dart';
import 'package:nibbles/src/common/domain/entities/subscription_plan.dart';

void main() {
  group('SubscriptionPlanPeriod.analyticsValue', () {
    test('monthly maps to the snake-case analytics token "monthly"', () {
      expect(SubscriptionPlanPeriod.monthly.analyticsValue, 'monthly');
    });

    test('annual maps to the snake-case analytics token "annual"', () {
      expect(SubscriptionPlanPeriod.annual.analyticsValue, 'annual');
    });

    test('every enum value has a stable analytics token', () {
      for (final period in SubscriptionPlanPeriod.values) {
        expect(period.analyticsValue, isNotEmpty);
      }
    });
  });

  group('SubscriptionPlan defaults', () {
    test('isRecommended defaults to false when omitted', () {
      const plan = SubscriptionPlan(
        id: 'monthly_4_99',
        title: 'Monthly',
        priceLabel: r'$4.99 monthly',
        period: SubscriptionPlanPeriod.monthly,
      );

      expect(plan.isRecommended, isFalse);
    });

    test('holds the opaque package id verbatim for the purchase pipeline', () {
      const plan = SubscriptionPlan(
        id: 'annual_29_99',
        title: 'Annual',
        priceLabel: r'$29.99 yearly',
        period: SubscriptionPlanPeriod.annual,
        isRecommended: true,
      );

      expect(plan.id, 'annual_29_99');
      expect(plan.isRecommended, isTrue);
    });
  });
}
