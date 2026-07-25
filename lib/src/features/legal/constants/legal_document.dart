import 'package:flutter/foundation.dart';
import 'package:nibbles/src/features/legal/constants/legal_disclaimer.dart';
import 'package:nibbles/src/features/legal/constants/legal_privacy_policy.dart';

/// Static content model for the in-app legal pages.
///
/// Copy is verbatim from the source documents owned by First Nibbles Pty Ltd —
/// the Medical and Safety Disclaimer and the Nibbles Privacy Policy. Do not
/// reword, condense or "fix" anything here; these are legal instruments and the
/// app must render exactly what was drafted.
@immutable
class LegalDocument {
  const LegalDocument({
    required this.slug,
    required this.title,
    required this.blocks,
  });

  /// Path segment for `/legal/:slug`.
  final String slug;

  /// Header title.
  final String title;

  final List<LegalBlock> blocks;
}

/// Sealed base for every renderable block inside a [LegalDocument].
@immutable
sealed class LegalBlock {
  const LegalBlock();
}

/// Numbered section title, e.g. "4. Parent and caregiver responsibility".
class LegalHeading extends LegalBlock {
  const LegalHeading(this.text);

  final String text;
}

/// Free-form paragraph.
class LegalParagraph extends LegalBlock {
  const LegalParagraph(this.text);

  final String text;
}

/// Unordered list rendered as bullet rows.
class LegalBullets extends LegalBlock {
  const LegalBullets(this.items);

  final List<String> items;
}

const String kLegalDisclaimerSlug = 'medical-safety-disclaimer';
const String kLegalPrivacyPolicySlug = 'privacy-policy';

/// Whether the Privacy Policy page is reachable.
///
/// The source document still carries unfilled `[INSERT …]` placeholders. Until
/// they are resolved the page must not be linked from anywhere in the app —
/// shipping visibly unfinished legal text is worse than shipping none.
///
/// Before flipping this to `true`, fill in:
///   - Effective date and last-updated date (section header)
///   - ABN (section 1)
///   - Analytics, hosting, crash-reporting, authentication and email/support
///     providers (section 12)
///   - Overseas processing countries (section 14)
///   - Child-profile, account and backup retention periods (section 16)
///   - Complaint acknowledgement and response periods (section 28)
///   - Privacy email, postal address, telephone and website (section 29)
const bool kPrivacyPolicyPublished = false;

const List<LegalDocument> kLegalDocuments = [
  legalDisclaimerDocument,
  legalPrivacyPolicyDocument,
];

/// Resolves a document by slug. Returns null for an unknown slug so the screen
/// can render a not-found fallback instead of crashing on a malformed deeplink.
LegalDocument? legalDocumentForSlug(String slug) {
  for (final document in kLegalDocuments) {
    if (document.slug == slug) return document;
  }
  return null;
}
