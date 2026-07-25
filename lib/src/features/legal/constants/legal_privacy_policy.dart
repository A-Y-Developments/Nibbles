// Bullet items must be single-line string literals: `no_adjacent_strings_in_list`
// forbids wrapping them across lines and `prefer_adjacent_string_concatenation`
// forbids joining them with `+`. Some legal sentences are simply longer than 80
// characters, so the width rule is waived for this data-only file.
// ignore_for_file: lines_longer_than_80_chars

import 'package:nibbles/src/features/legal/constants/legal_document.dart';

/// Nibbles Privacy Policy — verbatim from the source document.
///
/// The `[INSERT …]` placeholders are reproduced exactly as drafted. They are
/// the reason [kPrivacyPolicyPublished] is still false; see that constant for
/// the full list of what must be resolved before this page goes live.
const LegalDocument legalPrivacyPolicyDocument = LegalDocument(
  slug: kLegalPrivacyPolicySlug,
  title: 'Privacy Policy',
  blocks: [
    LegalParagraph('Effective date: [INSERT DATE]'),
    LegalParagraph('Last updated: [INSERT DATE]'),

    LegalHeading('1. About this Privacy Policy'),
    LegalParagraph(
      'First Nibbles Pty Ltd ABN [INSERT ABN] trading as Nibbles ("Nibbles", '
      '"First Nibbles", "we", "us" or "our") respects your privacy and '
      'understands the importance of carefully protecting information about '
      'you and your child.',
    ),
    LegalParagraph(
      'This Privacy Policy explains how we collect, hold, use, disclose, store '
      'and protect personal information when you:',
    ),
    LegalBullets([
      'Use the Nibbles mobile application.',
      'Visit the Nibbles website.',
      'Create or manage a Nibbles account.',
      'Create or manage a child profile.',
      'Subscribe to a Nibbles service or communication.',
      'Contact our customer support team.',
      'Participate in a survey, promotion or research activity.',
      'Otherwise interact with First Nibbles Pty Ltd.',
    ]),
    LegalParagraph(
      'We handle personal information in accordance with applicable Australian '
      'privacy laws, including the Privacy Act 1988 (Cth), the Australian '
      'Privacy Principles, the Health Records and Information Privacy Act 2002 '
      '(NSW) where applicable, and other applicable privacy, health-record and '
      'data-protection requirements.',
    ),
    LegalParagraph(
      'This Privacy Policy should be read together with our Terms of Use and '
      'Medical & Safety Disclaimer.',
    ),

    LegalHeading('2. Who Nibbles is designed for'),
    LegalParagraph(
      'Nibbles is designed for parents, legal guardians and authorised adult '
      'caregivers.',
    ),
    LegalParagraph(
      'Users must be at least 18 years old or otherwise have legal capacity to '
      'create an account and accept our Terms of Use.',
    ),
    LegalParagraph(
      'Nibbles is not designed for children to create or independently manage '
      'their own accounts. Information about a child should only be entered by '
      "the child's parent, legal guardian or another person who is legally "
      'authorised to provide the information.',
    ),
    LegalParagraph(
      'By creating a child profile or providing information about a child, you '
      'confirm that:',
    ),
    LegalBullets([
      "You are the child's parent, legal guardian or authorised caregiver.",
      "You have authority to provide the child's information to us.",
      "You have authority to provide any required consent on the child's behalf.",
      'The information you provide is accurate to the best of your knowledge.',
    ]),
    LegalParagraph(
      'Contact us promptly if you believe information about a child has been '
      'provided without appropriate authority.',
    ),

    LegalHeading('3. Meaning of personal and sensitive information'),
    LegalParagraph(
      'Personal information is information or an opinion about an identified '
      'individual or an individual who is reasonably identifiable.',
    ),
    LegalParagraph(
      'Sensitive information is a category of personal information that '
      'receives additional legal protection. It includes health information '
      "and certain information about a person's racial or ethnic origin, "
      'religious beliefs and other protected matters.',
    ),
    LegalParagraph(
      "Information about a child's allergies, medical conditions, development, "
      'growth, feeding difficulties, swallowing ability, dietary requirements '
      'or reactions to food may be health information or sensitive '
      'information.',
    ),

    LegalHeading('4. Information we may collect'),
    LegalParagraph(
      'The information we collect depends on how you use Nibbles and which '
      'information you choose to provide.',
    ),

    LegalHeading('4.1 Account and contact information'),
    LegalParagraph('We may collect:'),
    LegalBullets([
      'Your name.',
      'Email address.',
      'Telephone number, where provided.',
      'Username or account identifier.',
      'Password or authentication information in secured form.',
      'Country, region, language and time zone.',
      'Communication preferences.',
      'Subscription status.',
      'Records of your acceptance of our Terms of Use, disclaimers and privacy consents.',
    ]),

    LegalHeading('4.2 Information about your child'),
    LegalParagraph('You may choose to provide information such as:'),
    LegalBullets([
      "The child's first name, nickname or profile name.",
      'Date of birth or age.',
      'Developmental stage.',
      'Feeding stage and feeding abilities.',
      'Readiness-check responses.',
      'Head, neck, sitting, grasping and oral-motor readiness information.',
      'Foods and textures introduced.',
      'Allergens introduced.',
      'Known or suspected allergies and intolerances.',
      'Previous or suspected reactions to foods.',
      'Dietary requirements or preferences.',
      'Foods accepted, refused or being explored.',
      'Feeding progress and feeding history.',
      'Saved recipes, meal plans, checklists and favourites.',
      'Information about gagging, chewing, swallowing or feeding difficulties.',
      'Information about prematurity, development, growth or medical concerns that you voluntarily provide.',
      "Notes or other information you choose to enter into the child's profile.",
    ]),
    LegalParagraph(
      'We will seek to collect only information that is reasonably necessary '
      'to provide the relevant Nibbles feature.',
    ),
    LegalParagraph(
      'You should not provide detailed medical records, medical reports, '
      'government identification numbers or information that Nibbles has not '
      'requested.',
    ),

    LegalHeading('4.3 Subscription and transaction information'),
    LegalParagraph(
      'Where you purchase a subscription or service, we may receive:',
    ),
    LegalBullets([
      'The product or subscription purchased.',
      'Subscription start, renewal, expiry or cancellation information.',
      'Transaction identifier.',
      'Purchase status.',
      'Currency and approximate location of purchase.',
      'Refund or billing-support information.',
    ]),
    LegalParagraph(
      'Payments may be processed by Apple, Google or another authorised '
      'payment provider. We generally do not receive or store your full '
      'debit-card or credit-card details when payment is processed by those '
      'providers.',
    ),
    LegalParagraph(
      'Your payment provider handles payment information under its own privacy '
      'policy and terms.',
    ),

    LegalHeading('4.4 Device and technical information'),
    LegalParagraph(
      'When you use Nibbles, we may automatically collect information such as:',
    ),
    LegalBullets([
      'Device type and model.',
      'Operating system and app version.',
      'Device or app identifiers.',
      'Internet Protocol address.',
      'Language and regional settings.',
      'Time zone.',
      'Mobile network or internet service information.',
      'Login dates and times.',
      'App session information.',
      'Error logs, diagnostic data and crash reports.',
      'Security and authentication events.',
      'Push-notification token.',
      'General location inferred from an IP address, where applicable.',
    ]),
    LegalParagraph(
      'We will not access precise device location, contacts, photographs, '
      'camera, microphone or other restricted device information unless the '
      'relevant feature requires it and you grant permission.',
    ),

    LegalHeading('4.5 Usage information'),
    LegalParagraph(
      'We may collect information about how Nibbles is used, including:',
    ),
    LegalBullets([
      'Screens and features accessed.',
      'Recipes viewed, saved or completed.',
      'Search terms entered.',
      'Filters and preferences selected.',
      'Links or buttons selected.',
      'Checklist and meal-planning activity.',
      'Notification engagement.',
      'Approximate session duration.',
      'Feature performance.',
      'Referral or acquisition source.',
    ]),
    LegalParagraph(
      'We use this information to operate, secure, understand and improve '
      'Nibbles.',
    ),

    LegalHeading('4.6 Communications and support information'),
    LegalParagraph('When you communicate with us, we may collect:'),
    LegalBullets([
      'Your contact details.',
      'The date and content of your communication.',
      'Support requests.',
      'Feedback and complaints.',
      'Screenshots or attachments you provide.',
      'Records of our response.',
      'Information required to verify your identity or account ownership.',
    ]),
    LegalParagraph(
      'Please avoid including unnecessary health information or other '
      'sensitive information in general support messages.',
    ),

    LegalHeading('4.7 Surveys, promotions and research'),
    LegalParagraph('Where you voluntarily participate, we may collect:'),
    LegalBullets([
      'Survey responses.',
      'Product feedback.',
      'Competition or promotion entries.',
      'Testimonials.',
      'Interview or research responses.',
      'Demographic information you choose to provide.',
    ]),
    LegalParagraph(
      'We will provide additional information or seek additional consent where '
      'a survey, promotion, testimonial or research activity involves a new '
      'use of sensitive information.',
    ),

    LegalHeading('4.8 Marketing information'),
    LegalParagraph(
      'Where you choose to receive marketing communications, we may collect:',
    ),
    LegalBullets([
      'Your email address.',
      'Marketing consent.',
      'Communication preferences.',
      'Email delivery, opening and link-selection information.',
      'Unsubscribe records.',
    ]),
    LegalParagraph(
      "We do not use a child's health information to send targeted marketing "
      'without separate, express consent.',
    ),

    LegalHeading('5. How we collect information'),
    LegalParagraph('We may collect information:'),
    LegalBullets([
      'Directly from you during onboarding or account creation.',
      'When you create or update a child profile.',
      'When you use Nibbles features.',
      'When you contact us.',
      'When you complete a survey or promotion.',
      'Automatically through the app, website and associated technology.',
      'From app stores, payment providers and authentication providers.',
      'From analytics, hosting, security and customer-support providers acting on our behalf.',
      'From another authorised account holder or caregiver where shared-profile functionality is offered.',
      'From another source where you have consented or where collection is permitted by law.',
    ]),
    LegalParagraph(
      'Where reasonable and practical, we collect personal information '
      "directly from the person to whom it relates or from that person's "
      'authorised representative.',
    ),

    LegalHeading('6. Why we collect and use information'),
    LegalParagraph(
      'We may collect, hold, use and disclose personal information to:',
    ),
    LegalBullets([
      'Create and manage user accounts.',
      'Create and manage child profiles.',
      'Provide the Nibbles app and its features.',
      "Personalise content to a child's age, feeding stage, preferences and information provided.",
      'Filter or flag content based on allergens and dietary information.',
      'Provide readiness checklists and general educational results.',
      'Generate meal ideas, recipe suggestions, feeding checklists and reminders.',
      'Save progress, preferences, recipes and meal plans.',
      'Process and manage subscriptions.',
      'Authenticate users and maintain account security.',
      'Respond to support requests and complaints.',
      'Communicate important service, safety, security or account information.',
      'Send marketing communications where permitted and requested.',
      'Understand how Nibbles is used.',
      'Diagnose errors and improve app reliability.',
      'Develop, test and improve our content, services and features.',
      'Prevent fraud, misuse and unauthorised access.',
      'Protect users, children, First Nibbles and third parties.',
      'Meet legal, accounting, taxation, insurance and regulatory requirements.',
      'Establish, exercise or defend legal claims.',
      'Manage a proposed or completed business transaction.',
      'Perform another purpose that is disclosed to you and to which you consent.',
      'Perform another activity permitted or required by law.',
    ]),
    LegalParagraph(
      'We will not use sensitive information for a purpose unrelated to the '
      'purpose for which it was collected unless we obtain additional consent '
      'or the use is otherwise permitted or required by law.',
    ),

    LegalHeading('7. Health and sensitive information'),
    LegalParagraph(
      'We may collect health or sensitive information about a child where:',
    ),
    LegalBullets([
      'The information is reasonably necessary to provide a requested Nibbles feature.',
      "The child's parent, legal guardian or authorised caregiver has provided express consent.",
      'Collection is otherwise permitted or required by law.',
    ]),
    LegalParagraph(
      'We do not require users to provide every category of child information '
      'listed in this policy. However, certain personalised features may not '
      'work properly without the relevant information.',
    ),
    LegalParagraph(
      'You may withdraw consent for future handling of optional sensitive '
      'information by:',
    ),
    LegalBullets([
      'Updating or removing information within your account.',
      'Deleting the relevant child profile.',
      'Deleting your account.',
      'Contacting us using the details at the end of this policy.',
    ]),
    LegalParagraph(
      'Withdrawal of consent will not necessarily require us to delete '
      'information that we are legally required or permitted to retain. '
      'Withdrawing consent may also prevent us from continuing to provide '
      'personalised features that rely on that information.',
    ),

    LegalHeading('8. Automated personalisation and recommendations'),
    LegalParagraph(
      'Nibbles may use rules-based or automated processes to organise, filter '
      'or recommend content.',
    ),
    LegalParagraph("For example, Nibbles may use information about a child's:"),
    LegalBullets([
      'Age.',
      'Developmental or feeding stage.',
      'Readiness-check responses.',
      'Allergies or dietary requirements.',
      'Foods previously introduced.',
      'Saved recipes and preferences.',
      'Use of Nibbles features.',
    ]),
    LegalParagraph('These processes may be used to:'),
    LegalBullets([
      'Display age- or stage-relevant content.',
      'Exclude or flag recipes containing identified allergens.',
      'Recommend recipes, textures or feeding resources.',
      'Create checklists, meal plans or reminders.',
      'Display general readiness results.',
      'Personalise the order or presentation of content.',
    ]),
    LegalParagraph(
      'Automated recommendations are general educational tools. They do not '
      'diagnose a medical condition, confirm developmental or medical '
      'readiness, replace professional advice or make legally binding '
      'decisions.',
    ),
    LegalParagraph(
      'Users remain responsible for deciding whether any recommendation is '
      'appropriate for their child.',
    ),
    LegalParagraph(
      'You may contact us to ask about the information used to generate a '
      'recommendation, correct inaccurate information or request that a '
      'particular child profile be deleted.',
    ),
    LegalParagraph(
      'Unless we obtain separate, express consent, we will not use identifiable '
      'child health information to train a publicly available or '
      'general-purpose artificial intelligence model.',
    ),

    LegalHeading('9. De-identified and aggregated information'),
    LegalParagraph(
      'We may create statistical, aggregated or de-identified information from '
      'personal information.',
    ),
    LegalParagraph('We may use properly de-identified information to:'),
    LegalBullets([
      'Understand general feeding trends.',
      'Measure product performance.',
      'Improve recipes and educational content.',
      'Test and develop features.',
      'Conduct internal research.',
      'Prepare non-identifying reports.',
    ]),
    LegalParagraph(
      'We will take reasonable steps to reduce the risk that de-identified '
      'information can be re-identified.',
    ),
    LegalParagraph(
      'Information that has been effectively de-identified so that no '
      'individual is reasonably identifiable may no longer be personal '
      'information. We will not attempt to re-identify it except where '
      'permitted by law or required to test the effectiveness of our '
      'de-identification processes.',
    ),

    LegalHeading('10. When we may disclose information'),
    LegalParagraph(
      'We may disclose personal information to the following categories of '
      'recipients where reasonably necessary.',
    ),

    LegalHeading('10.1 Service providers'),
    LegalParagraph('These may include providers of:'),
    LegalBullets([
      'Cloud hosting and database services.',
      'Account authentication.',
      'Data storage and backup.',
      'App development and maintenance.',
      'Analytics and performance monitoring.',
      'Crash reporting and diagnostics.',
      'Cybersecurity and fraud prevention.',
      'Customer support.',
      'Email and communication services.',
      'Push notifications.',
      'Subscription and payment processing.',
      'Survey and feedback tools.',
      'Professional document storage.',
      'Business administration.',
    ]),
    LegalParagraph(
      'Service providers may only receive the information reasonably required '
      'to perform their services. We seek to require providers to protect the '
      'information and to use it only for authorised purposes.',
    ),

    LegalHeading('10.2 App stores and payment providers'),
    LegalParagraph(
      'We may exchange transaction, subscription and account information with '
      'Apple, Google or another payment provider to:',
    ),
    LegalBullets([
      'Process purchases.',
      'Verify subscription status.',
      'Manage renewals and cancellations.',
      'Process refunds.',
      'Prevent fraud.',
      'Resolve billing issues.',
    ]),

    LegalHeading('10.3 Professional advisers'),
    LegalParagraph(
      'We may disclose information to professional advisers such as:',
    ),
    LegalBullets([
      'Lawyers.',
      'Accountants.',
      'Auditors.',
      'Insurers.',
      'Cybersecurity specialists.',
      'Business consultants.',
    ]),
    LegalParagraph(
      'We will limit the disclosure to information reasonably necessary for '
      'the relevant professional service.',
    ),

    LegalHeading('10.4 Legal and regulatory disclosures'),
    LegalParagraph(
      'We may disclose information where we reasonably believe disclosure is '
      'necessary to:',
    ),
    LegalBullets([
      'Comply with a law, court order, warrant or enforceable regulatory request.',
      'Respond to an authorised government agency.',
      'Protect the safety of a child or another person.',
      'Prevent or investigate fraud, abuse or unlawful conduct.',
      'Protect our legal rights.',
      'Establish, exercise or defend a legal claim.',
      'Respond to an emergency or serious threat where disclosure is permitted by law.',
    ]),

    LegalHeading('10.5 Business transactions'),
    LegalParagraph(
      'If First Nibbles is involved in a proposed or completed merger, '
      'acquisition, investment, financing, restructuring, insolvency or sale '
      'of all or part of its business or assets, relevant information may be '
      'disclosed to advisers and potential transaction parties.',
    ),
    LegalParagraph(
      'We will take reasonable steps to protect information during any '
      'transaction and require the recipient to handle personal information '
      'consistently with applicable privacy obligations.',
    ),

    LegalHeading('10.6 With consent'),
    LegalParagraph(
      'We may disclose information to another person or organisation where you '
      'have provided consent or asked us to make the disclosure.',
    ),

    LegalHeading('11. Selling information and advertising'),
    LegalParagraph('We do not sell or rent personal information.'),
    LegalParagraph(
      "We do not sell or rent a child's health, allergy, development or "
      'feeding information.',
    ),
    LegalParagraph(
      "We do not use a child's sensitive information for third-party targeted "
      'advertising without separate, express consent.',
    ),
    LegalParagraph(
      'We do not permit advertisers to access an identifiable child profile '
      'through Nibbles.',
    ),
    LegalParagraph(
      'Any future introduction of advertising or materially different tracking '
      'practices will require an update to this policy and, where required, '
      'additional notice or consent.',
    ),

    LegalHeading('12. Analytics, cookies and similar technologies'),
    LegalParagraph(
      'Our website or app may use cookies, software development kits, local '
      'storage, analytics tools, pixels or similar technologies to:',
    ),
    LegalBullets([
      'Keep users signed in.',
      'Remember preferences.',
      'Maintain security.',
      'Measure app performance.',
      'Diagnose errors.',
      'Understand general usage.',
      'Improve Nibbles.',
      'Measure the effectiveness of communications or campaigns.',
    ]),
    LegalParagraph(
      'We will not intentionally place child health information inside '
      'advertising tags, tracking pixels or analytics event names.',
    ),
    LegalParagraph(
      'The analytics and technology providers currently used by Nibbles are:',
    ),
    LegalBullets([
      '[INSERT HOSTING OR DATABASE PROVIDER]',
      '[INSERT ANALYTICS PROVIDER]',
      '[INSERT CRASH-REPORTING PROVIDER]',
      '[INSERT AUTHENTICATION PROVIDER]',
      '[INSERT EMAIL OR CUSTOMER-SUPPORT PROVIDER]',
      '[INSERT OTHER SOFTWARE DEVELOPMENT KITS]',
    ]),
    LegalParagraph(
      'You may be able to control certain technologies through device '
      'settings, browser settings or Nibbles privacy settings. Disabling '
      'essential technology may prevent some features from operating '
      'correctly.',
    ),

    LegalHeading('13. Direct marketing'),
    LegalParagraph(
      'We may send information about Nibbles products, recipes, updates, '
      'offers or services where:',
    ),
    LegalBullets([
      'You have requested those communications.',
      'You have provided consent.',
      'The communication is otherwise permitted by law.',
    ]),
    LegalParagraph('You may opt out at any time by:'),
    LegalBullets([
      'Selecting the unsubscribe option in an email.',
      'Changing your communication settings.',
      'Disabling optional promotional notifications.',
      'Contacting us.',
    ]),
    LegalParagraph(
      'Service-related communications, such as security alerts, material terms '
      'updates, subscription messages and important account notices, are not '
      'marketing communications and may continue while your account remains '
      'active.',
    ),
    LegalParagraph(
      'We will not use sensitive information for direct marketing without the '
      'consent required by law.',
    ),

    LegalHeading('14. Overseas storage and disclosure'),
    LegalParagraph(
      'Some service providers may store or process personal information '
      'outside Australia.',
    ),
    LegalParagraph('Our current providers may process information in:'),
    LegalBullets([
      'Australia.',
      '[INSERT EVERY OTHER RELEVANT COUNTRY, FOR EXAMPLE THE UNITED STATES, SINGAPORE, IRELAND OR OTHER EUROPEAN UNION COUNTRIES].',
      '[INSERT ANY ADDITIONAL COUNTRIES].',
    ]),
    LegalParagraph(
      'The countries involved may depend on the provider, the service used and '
      'the location of its data centres and support personnel.',
    ),
    LegalParagraph(
      'Before disclosing personal information to an overseas recipient, we '
      'take reasonable steps required by applicable law to ensure that the '
      'information is handled appropriately. However, overseas recipients may '
      'be subject to the laws of their own country.',
    ),
    LegalParagraph(
      'Contact us for current information about the likely countries in which '
      'your information may be processed.',
    ),

    LegalHeading('15. How we store and protect information'),
    LegalParagraph('We may store information:'),
    LegalBullets([
      'In secured cloud infrastructure.',
      'In databases operated by us or our contracted providers.',
      'On secured business systems.',
      'In encrypted backups.',
      'In limited circumstances, in secured administrative or legal records.',
    ]),
    LegalParagraph(
      'We use administrative, technical and organisational safeguards designed '
      'to protect personal information from misuse, interference, loss, '
      'unauthorised access, modification and disclosure.',
    ),
    LegalParagraph(
      'Depending on the system and information involved, safeguards may '
      'include:',
    ),
    LegalBullets([
      'Access controls and authentication.',
      'Role-based access restrictions.',
      'Encryption during transmission.',
      'Encryption of stored information where appropriate.',
      'Secure password handling.',
      'Logging and system monitoring.',
      'Software updates and vulnerability management.',
      'Backup and recovery procedures.',
      'Staff and contractor confidentiality obligations.',
      'Vendor security reviews.',
      'Incident-response procedures.',
      'Limiting access to people who require it for their work.',
    ]),
    LegalParagraph(
      'No electronic system or method of transmission is completely secure. We '
      'cannot guarantee that a security incident will never occur, but we take '
      'reasonable steps appropriate to the nature and sensitivity of the '
      'information we hold.',
    ),
    LegalParagraph(
      'You are responsible for protecting your password, device and account '
      'credentials and for notifying us promptly if you suspect unauthorised '
      'access.',
    ),

    LegalHeading('16. Retention of information'),
    LegalParagraph(
      'We retain personal information only for as long as reasonably necessary '
      'for the purposes described in this policy or as required or permitted '
      'by law.',
    ),
    LegalParagraph('Retention periods may depend on:'),
    LegalBullets([
      'Whether your account remains active.',
      'The type and sensitivity of the information.',
      'The reason the information was collected.',
      'Legal, accounting and taxation requirements.',
      'Insurance and dispute requirements.',
      'Fraud-prevention and security needs.',
      'Backup and disaster-recovery cycles.',
      'Any applicable health-record retention obligations.',
    ]),
    LegalParagraph(
      'Subject to applicable legal requirements, our intended retention '
      'periods are:',
    ),
    LegalBullets([
      'Active account and child-profile information: retained while the account or relevant profile remains active.',
      'Deleted child profiles: removed from active user-facing systems within [INSERT PERIOD, RECOMMENDED 30 DAYS].',
      'Deleted accounts: removed from active systems within [INSERT PERIOD, RECOMMENDED 30 DAYS].',
      'Backup copies: progressively overwritten or deleted within [INSERT PERIOD, RECOMMENDED 90 DAYS].',
      'Subscription and financial records: retained for the period required by taxation, accounting and corporate laws.',
      'Consent and Terms-acceptance records: retained for as long as reasonably necessary to demonstrate the consent or agreement obtained and manage legal obligations.',
      'Security and fraud-prevention records: retained for as long as reasonably necessary to protect users and our service.',
      'Complaints and legal records: retained for as long as necessary to manage the matter and applicable limitation periods.',
    ]),
    LegalParagraph(
      'Where a law requires health information to be retained for a longer '
      'period, the legally required period will apply.',
    ),
    LegalParagraph(
      'We may retain properly de-identified or aggregated information where it '
      'no longer identifies an individual.',
    ),
    LegalParagraph(
      'When personal information is no longer required, we will take '
      'reasonable steps to delete it or de-identify it, subject to legal '
      'retention obligations and technical backup cycles.',
    ),

    LegalHeading('17. Accessing your information'),
    LegalParagraph(
      'You may request access to personal information we hold about you or a '
      'child for whom you are legally authorised to act.',
    ),
    LegalParagraph(
      'You may be able to access much of this information directly through '
      'your Nibbles account.',
    ),
    LegalParagraph(
      'For other information, contact our Privacy Officer using the details '
      'below.',
    ),
    LegalParagraph('We may need to verify:'),
    LegalBullets([
      'Your identity.',
      'Your account ownership.',
      'Your relationship to the child.',
      'Your authority to access the requested information.',
    ]),
    LegalParagraph(
      'We will respond within a reasonable period, generally within 30 days.',
    ),
    LegalParagraph(
      'Access may be limited or refused where permitted by law, including '
      'where access would:',
    ),
    LegalBullets([
      "Unreasonably affect another person's privacy.",
      "Create a serious threat to a person's life, health or safety.",
      'Reveal commercially sensitive evaluative information.',
      'Prejudice an investigation.',
      'Be unlawful.',
      'Relate to anticipated or existing legal proceedings where the information would not otherwise be accessible.',
    ]),
    LegalParagraph(
      'Where we refuse access, we will generally provide written reasons and '
      'available complaint options unless the law permits or requires '
      'otherwise.',
    ),
    LegalParagraph(
      'We will not charge a fee for making an access request. A reasonable '
      'administrative fee may apply for providing access where legally '
      'permitted. We will notify you before charging a fee.',
    ),

    LegalHeading('18. Correcting information'),
    LegalParagraph(
      'We take reasonable steps to ensure that personal information is '
      'accurate, current, complete, relevant and not misleading.',
    ),
    LegalParagraph(
      'You can update certain information directly through your Nibbles '
      'account.',
    ),
    LegalParagraph(
      'You may also contact us to request correction of information.',
    ),
    LegalParagraph(
      'We may ask for information reasonably required to confirm the '
      'correction. We will respond within a reasonable period, generally '
      'within 30 days.',
    ),
    LegalParagraph(
      'Where we do not make a requested correction, we will generally explain '
      'why and tell you how to make a complaint. Where required, you may ask '
      'us to associate a statement with the information explaining that you '
      'consider it inaccurate, out of date, incomplete, irrelevant or '
      'misleading.',
    ),

    LegalHeading('19. Deleting information and accounts'),
    LegalParagraph('You may request deletion of:'),
    LegalBullets([
      'Your account.',
      'A child profile.',
      'Optional profile information.',
      'Saved preferences.',
      'Other personal information, where deletion is legally available.',
    ]),
    LegalParagraph(
      'Deletion may be available through the app or by contacting us.',
    ),
    LegalParagraph('After a valid deletion request:'),
    LegalBullets([
      'We will remove or de-identify information from active systems within our stated processing period.',
      'Some information may remain temporarily in secured backups until the relevant backup cycle expires.',
      'We may retain information where required or permitted for legal, safety, fraud-prevention, accounting, dispute or regulatory purposes.',
      'We may retain a minimal record of the request and its completion.',
      'Properly de-identified information may be retained.',
    ]),
    LegalParagraph(
      'Deleting a child profile or withdrawing consent may prevent '
      'personalised Nibbles features from operating.',
    ),
    LegalParagraph(
      'Deleting the Nibbles app from a device does not necessarily delete the '
      'account or information held in our systems. You must use the '
      'account-deletion process or contact us.',
    ),

    LegalHeading('20. Shared profiles and multiple caregivers'),
    LegalParagraph(
      'Where Nibbles allows a child profile to be shared with another '
      'caregiver:',
    ),
    LegalBullets([
      'The account holder is responsible for inviting only authorised caregivers.',
      'Invited caregivers may be able to view or update child-profile information.',
      'The account holder should ensure that each caregiver understands their responsibilities.',
      'Access should be removed when a caregiver is no longer authorised.',
      'Nibbles may keep records of invitations, access and profile changes for security purposes.',
    ]),
    LegalParagraph(
      'Do not share login credentials. Use official profile-sharing features '
      'where available.',
    ),

    LegalHeading('21. Data breaches'),
    LegalParagraph(
      'We maintain processes for responding to suspected loss, unauthorised '
      'access, disclosure or other misuse of personal information.',
    ),
    LegalParagraph('Where an incident occurs, we may:'),
    LegalBullets([
      'Investigate and contain the incident.',
      'Take steps to reduce possible harm.',
      'Reset credentials or restrict access.',
      'Contact affected users.',
      'Notify service providers, insurers, law-enforcement bodies or regulators.',
      'Notify the Office of the Australian Information Commissioner and affected individuals where required by the Notifiable Data Breaches scheme.',
      'Take steps designed to prevent recurrence.',
    ]),
    LegalParagraph(
      'We encourage you to contact us immediately if you believe your account '
      'or information has been compromised.',
    ),

    LegalHeading('22. Anonymity and pseudonyms'),
    LegalParagraph(
      'Where practical, you may interact with us anonymously or using a '
      'pseudonym.',
    ),
    LegalParagraph(
      'For example, certain general website or educational content may be '
      'available without creating an account.',
    ),
    LegalParagraph(
      'We may need identifying information where it is impractical to provide '
      'a feature anonymously, including where we need to:',
    ),
    LegalBullets([
      'Create an account.',
      'Manage a paid subscription.',
      'Secure a child profile.',
      'Respond to an account-specific request.',
      'Verify authority over child information.',
      'Meet a legal obligation.',
    ]),
    LegalParagraph(
      "You may use a child's nickname rather than their full legal name unless "
      'a specific feature requires otherwise.',
    ),

    LegalHeading('23. Unsolicited information'),
    LegalParagraph(
      'If we receive personal or sensitive information that we did not '
      'request, we will consider whether we could lawfully have collected it.',
    ),
    LegalParagraph(
      'Where we could not have lawfully collected it and it is not contained '
      'in a legally protected record, we will take reasonable steps to delete '
      'or de-identify it.',
    ),
    LegalParagraph(
      'Do not send us detailed medical records, identity documents or other '
      'unnecessary sensitive information unless we have specifically requested '
      'them through a secure process.',
    ),

    LegalHeading('24. Government-related identifiers'),
    LegalParagraph(
      'We do not generally request Medicare numbers, passport numbers, '
      'driver-licence numbers, tax file numbers or other government-related '
      'identifiers.',
    ),
    LegalParagraph(
      'Please do not provide these identifiers unless we specifically request '
      'them for a lawful and necessary purpose.',
    ),
    LegalParagraph(
      'We will not adopt a government-related identifier as our own account '
      'identifier except where permitted by law.',
    ),

    LegalHeading('25. Third-party websites and services'),
    LegalParagraph(
      'Nibbles may contain links to third-party websites, products, resources '
      'or services.',
    ),
    LegalParagraph(
      'Third parties are responsible for their own privacy practices. This '
      'Privacy Policy does not apply to information handled independently by '
      'those third parties.',
    ),
    LegalParagraph(
      "We encourage you to review a third party's privacy policy before "
      'providing information or using its service.',
    ),
    LegalParagraph(
      'The inclusion of a link does not necessarily mean that First Nibbles '
      "endorses the third party's privacy or security practices.",
    ),

    LegalHeading('26. International users'),
    LegalParagraph(
      'First Nibbles Pty Ltd is based in Australia, and information may be '
      'handled in Australia and the overseas locations identified in this '
      'policy.',
    ),
    LegalParagraph(
      'Users outside Australia may have additional rights under the laws of '
      'their country or region.',
    ),
    LegalParagraph(
      'Nothing in this policy limits a privacy or data-protection right that '
      'cannot lawfully be limited.',
    ),
    LegalParagraph(
      'Before actively offering Nibbles in another jurisdiction, we may '
      'provide additional notices or regional terms where required.',
    ),

    LegalHeading('27. Changes to this Privacy Policy'),
    LegalParagraph('We may update this Privacy Policy to reflect:'),
    LegalBullets([
      'Changes to Nibbles.',
      'New features or data practices.',
      'Changes to service providers.',
      'Changes to applicable law.',
      'Regulatory guidance.',
      'Security or operational improvements.',
    ]),
    LegalParagraph(
      'The current version will display its effective date and last-updated '
      'date.',
    ),
    LegalParagraph(
      'Where a change is material, we will take reasonable steps to provide '
      'notice through the app, website, email or another appropriate method.',
    ),
    LegalParagraph(
      'Where legally required, we will obtain new consent before applying a '
      'materially different practice to previously collected sensitive '
      'information.',
    ),
    LegalParagraph(
      'We may retain previous versions of this policy for record-keeping and '
      'transparency.',
    ),

    LegalHeading('28. Privacy complaints'),
    LegalParagraph(
      'You may contact our Privacy Officer if you believe we have mishandled '
      'personal information or breached an applicable privacy requirement.',
    ),
    LegalParagraph('Please include:'),
    LegalBullets([
      'Your name and contact details.',
      'A description of the issue.',
      'Relevant dates.',
      'The account or child profile involved.',
      'The outcome you are seeking.',
      'Any relevant supporting information.',
    ]),
    LegalParagraph('We will:'),
    LegalBullets([
      'Acknowledge the complaint within [INSERT PERIOD, RECOMMENDED 7 DAYS].',
      'Investigate the complaint fairly.',
      'Request further information where necessary.',
      'Aim to provide a substantive response within [INSERT PERIOD, RECOMMENDED 30 DAYS].',
      'Explain any delay.',
      'Explain the outcome and available escalation options.',
    ]),
    LegalParagraph(
      'If you are not satisfied with our response, you may be entitled to '
      'complain to:',
    ),
    LegalBullets([
      'The Office of the Australian Information Commissioner.',
      'The Information and Privacy Commission NSW, where the matter falls within its jurisdiction.',
      'Another applicable privacy or consumer regulator.',
    ]),
    LegalParagraph(
      'We encourage you to contact us first so that we have an opportunity to '
      'resolve the matter.',
    ),

    LegalHeading('29. Contact us'),
    LegalParagraph(
      'Questions, privacy requests and complaints may be directed to:',
    ),
    LegalParagraph('Privacy Officer\nFirst Nibbles Pty Ltd'),
    LegalParagraph(
      'Email: [INSERT PRIVACY EMAIL]\n'
      'Postal address: [INSERT BUSINESS OR POSTAL ADDRESS]\n'
      'Telephone: [INSERT TELEPHONE NUMBER, IF OFFERED]',
    ),
    LegalParagraph('Website: [INSERT WEBSITE]'),
    LegalParagraph(
      'Please write "Privacy Request" or "Privacy Complaint" in the subject '
      'line where appropriate.',
    ),
  ],
);
