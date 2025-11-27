import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../resources/index.dart';
import '../../provider/index.dart';
import '../../shared_widgets/index.dart';

@RoutePage()
class UserGuidePage extends StatelessWidget {
  const UserGuidePage({super.key});

  static const String _fbGroupUrl = '';
  static const String _youtubeUrl = '';

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final sections = _guideSections();

    return Scaffold(
      appBar: CustomAppBar(
        title: LKey.settingUserGuide.tr(context: context),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _GuideHero(theme: theme),
            const SizedBox(height: 12),
            _GuideActionCard(
              icon: Icons.groups_outlined,
              title: LKey.guideActionCommunityTitle,
              description: LKey.guideActionCommunityDescription,
              url: _fbGroupUrl,
              color: theme.colorPrimary.withOpacity(0.08),
              iconColor: theme.colorPrimary,
            ),
            const SizedBox(height: 12),
            _GuideActionCard(
              icon: HugeIcons.strokeRoundedPlayCircle,
              title: LKey.guideActionYoutubeTitle,
              description: LKey.guideActionYoutubeDescription,
              url: _youtubeUrl,
              color: theme.colorTextSupportBlue.withOpacity(0.08),
              iconColor: theme.colorTextSupportBlue,
            ),
            const SizedBox(height: 16),
            _GuideSequenceCard(theme: theme),
            const SizedBox(height: 20),
            Text(
              LKey.guideTextTitle.tr(context: context),
              style: theme.headingSemibold20Default,
            ),
            const SizedBox(height: 4),
            Text(
              LKey.guideTextSubtitle.tr(context: context),
              style: theme.textRegular14Subtle,
            ),
            const SizedBox(height: 12),
            ...sections.map(
              (section) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _GuideTextSection(section: section),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  List<_GuideSection> _guideSections() {
    return [
      _GuideSection(
        titleKey: LKey.guideSectionSetupTitle,
        descriptionKey: LKey.guideSectionSetupDescription,
        bulletKeys: const [
          LKey.guideSectionSetupBullet1,
          LKey.guideSectionSetupBullet2,
          LKey.guideSectionSetupBullet3,
        ],
      ),
      _GuideSection(
        titleKey: LKey.guideSectionProductTitle,
        descriptionKey: LKey.guideSectionProductDescription,
        bulletKeys: const [
          LKey.guideSectionProductBullet1,
          LKey.guideSectionProductBullet2,
          LKey.guideSectionProductBullet3,
        ],
      ),
      _GuideSection(
        titleKey: LKey.guideSectionPriceOrderTitle,
        descriptionKey: LKey.guideSectionPriceOrderDescription,
        bulletKeys: const [
          LKey.guideSectionPriceOrderBullet1,
          LKey.guideSectionPriceOrderBullet2,
          LKey.guideSectionPriceOrderBullet3,
        ],
      ),
      _GuideSection(
        titleKey: LKey.guideSectionAdminDataTitle,
        descriptionKey: LKey.guideSectionAdminDataDescription,
        bulletKeys: const [
          LKey.guideSectionAdminDataBullet1,
          LKey.guideSectionAdminDataBullet2,
          LKey.guideSectionAdminDataBullet3,
        ],
      ),
      _GuideSection(
        titleKey: LKey.guideSectionReminderTitle,
        descriptionKey: null,
        bulletKeys: const [
          LKey.guideSectionReminderBullet1,
          LKey.guideSectionReminderBullet2,
          LKey.guideSectionReminderBullet3,
        ],
      ),
    ];
  }
}

class _GuideHero extends StatelessWidget {
  const _GuideHero({required this.theme});

  final AppThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorPrimary.withOpacity(0.12),
            theme.colorPrimary.withOpacity(0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorPrimary.withOpacity(0.16)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: theme.colorPrimary.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              HugeIcons.strokeRoundedBookBookmark01,
              color: theme.colorPrimary,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LKey.guideHeroTitle.tr(context: context),
                  style: theme.headingSemibold20Default,
                ),
                const SizedBox(height: 6),
                Text(
                  LKey.guideHeroSubtitle.tr(context: context),
                  style: theme.textRegular14Subtle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GuideActionCard extends StatelessWidget {
  const _GuideActionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.url,
    required this.color,
    required this.iconColor,
  });

  final IconData icon;
  final String title;
  final String description;
  final String url;
  final Color color;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final hasLink = url.isNotEmpty;

    return InkWell(
      onTap: () => _openLink(context, url),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.tr(context: context),
                    style: theme.textMedium16Default,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description.tr(context: context),
                    style: theme.textRegular14Subtle,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        hasLink ? Icons.open_in_new : Icons.timelapse,
                        color: iconColor,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        hasLink
                            ? LKey.guideLinkOpen.tr(context: context)
                            : LKey.guideLinkComingSoon.tr(context: context),
                        style: theme.textMedium14Primary
                            .copyWith(color: iconColor),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openLink(BuildContext context, String url) async {
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LKey.guideLinkComingSoon.tr(context: context)),
        ),
      );
      return;
    }

    final uri = Uri.tryParse(url);
    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LKey.guideLinkOpenError.tr(context: context)),
        ),
      );
      return;
    }

    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LKey.guideLinkOpenError.tr(context: context)),
        ),
      );
    }
  }
}

class _GuideSequenceCard extends StatelessWidget {
  const _GuideSequenceCard({required this.theme});

  final AppThemeData theme;

  @override
  Widget build(BuildContext context) {
    final steps = [
      LKey.guideSequenceStep1.tr(context: context),
      LKey.guideSequenceStep2.tr(context: context),
      LKey.guideSequenceStep3.tr(context: context),
      LKey.guideSequenceStep4.tr(context: context),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorDivider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  HugeIcons.strokeRoundedListView,
                  color: theme.colorPrimary,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                LKey.guideSequenceTitle.tr(context: context),
                style: theme.textMedium16Default,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(
            steps.length,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StepBadge(
                    index: index + 1,
                    color: theme.colorPrimary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      steps[index],
                      style: theme.textRegular14Default,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepBadge extends StatelessWidget {
  const _StepBadge({
    required this.index,
    required this.color,
  });

  final int index;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Center(
        child: Text(
          index.toString(),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _GuideSection {
  const _GuideSection({
    required this.titleKey,
    this.descriptionKey,
    required this.bulletKeys,
  });

  final String titleKey;
  final String? descriptionKey;
  final List<String> bulletKeys;
}

class _GuideTextSection extends StatelessWidget {
  const _GuideTextSection({required this.section});

  final _GuideSection section;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorDivider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorBackgroundField,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.check_circle_outline),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  section.titleKey.tr(context: context),
                  style: theme.textMedium16Default,
                ),
              ),
            ],
          ),
          if (section.descriptionKey != null) ...[
            const SizedBox(height: 8),
            Text(
              section.descriptionKey!.tr(context: context),
              style: theme.textRegular14Subtle,
            ),
          ],
          const SizedBox(height: 10),
          ...section.bulletKeys.map(
            (key) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.brightness_1,
                    size: 8,
                    color: Colors.black54,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      key.tr(context: context),
                      style: theme.textRegular14Default,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
