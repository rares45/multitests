import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:multitests/classes/multi_icons_icons.dart';
import 'package:multitests/classes/tests_registry.dart';
import 'package:multitests/pages/page_404.dart';
import 'package:multitests/utils/utils.dart';
import 'package:multitests/widgets/actions_builder_widget.dart';
import 'package:multitests/widgets/categories_wrap.dart';
import 'package:multitests/widgets/centering_widget.dart';
import 'package:share_plus_dialog/share_plus_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class TestPage extends StatelessWidget {
  const TestPage(this.testID, {super.key});

  final String testID;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Test test;
    try {
      test = TestRegistry.registeredTests.firstWhere(
        (element) => element.id == testID,
      ); // TODO: move to future loading
    } on StateError {
      return const Page404(
        errorText: 'It seems this test does not exist.',
      );
    }
    return Title(
      title: 'MultiTests - ${test.testName}',
      color: theme.colorScheme.primary,
      child: IconTheme(
        data: theme.iconTheme.copyWith(
          color: theme.colorScheme.onPrimaryContainer,
        ),
        child: Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar.large(
                title: Text(test.testName),
                actions: ActionsLayout.list(
                  [
                    ActionItem(
                      actionTitle: 'Share test',
                      icon: MultiIcons.share,
                      onTap: (context, inMenu) {
                        ShareDialog.share(
                          context,
                          test.testUrl,
                          platforms: SharePlatform.defaults,
                          isUrl: true,
                        );
                        FirebaseAnalytics.instance.logShare(
                          contentType: 'test',
                          itemId: test.id,
                          method: 'platform share',
                        );
                      },
                    ),
                  ],
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  <Widget>[
                    // About test card
                    CenterWidget(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 16, top: 16),
                                  child: Text(
                                    'About test',
                                    style: theme.textTheme.headlineSmall,
                                  ),
                                ),
                                ListTile(
                                  title: const Text('Description'),
                                  subtitle: Text(test.testDescription),
                                ),
                                ListTile(
                                  title: const Text('Categories'),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: CategoriesWrap(
                                      testCategories: test.testCategories,
                                    ),
                                  ),
                                ),
                                ListTile(
                                  title: const Text('Data collection'),
                                  subtitle: DataCollectionWidget(
                                      test.testDataCollections),
                                  trailing: Tooltip(
                                    margin: const EdgeInsets.all(16),
                                    preferBelow: false,
                                    triggerMode: TooltipTriggerMode.tap,
                                    message:
                                        'Some tests might collect data for public statistics',
                                    child: Icon(
                                      MultiIcons.help,
                                    ),
                                  ),
                                ),
                                ListTile(
                                  title: const Text('Test version'),
                                  subtitle: Text(test.version),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    // About doing the test
                    CenterWidget(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 16, top: 16),
                                  child: Text(
                                    'Doing the test',
                                    style: theme.textTheme.headlineSmall,
                                  ),
                                ),
                                ListTile(
                                  title: const Text('Number of questions'),
                                  subtitle:
                                      Text(test.questionsNumber.toString()),
                                ),
                                ListTile(
                                  title: const Text('Estimated time'),
                                  subtitle:
                                      Text(printDuration(test.testDuration)),
                                ),
                                if (test.testSuggestions.isNotEmpty)
                                  ListTile(
                                    title: const Text('Suggestions'),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        for (var s in test.testSuggestions)
                                          Text('• $s'),
                                      ],
                                    ),
                                  )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    // About result card
                    CenterWidget(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 16, top: 16),
                                  child: Text(
                                    'Results',
                                    style: theme.textTheme.headlineSmall,
                                  ),
                                ),
                                if (test.testResultDescriber.possibleValues !=
                                    null)
                                  ListTile(
                                    title: const Text(
                                      'Possible values',
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        for (var s in test.testResultDescriber
                                            .possibleValues!)
                                          Text('• $s'),
                                      ],
                                    ),
                                  ),
                                if (test.testResultDescriber.minValue != null)
                                  ListTile(
                                    title: const Text('Minimum value possible'),
                                    subtitle: Text(
                                      test.testResultDescriber.minValue!
                                          .toString(),
                                    ),
                                  ),
                                if (test.testResultDescriber.maxValue != null)
                                  ListTile(
                                    title: const Text('Maximum value possible'),
                                    subtitle: Text(
                                      test.testResultDescriber.maxValue!
                                          .toString(),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    CenterWidget(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          child: ListTile(
                            onTap: () {
                              launchUrl(
                                Uri.parse(test.testAuthor.authorWebpage),
                                mode: LaunchMode.externalNonBrowserApplication,
                                webOnlyWindowName: '_blank',
                              );
                            },
                            title: Text(
                                'Test provided by ${test.testAuthor.name}'),
                            trailing: Icon(MultiIcons.external_link),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SliverFillRemaining(
                hasScrollBody: false,
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 32,
                      bottom: 32 + MediaQuery.of(context).viewPadding.bottom,
                      right: 150,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            'Press this button to start the test',
                            style: theme.textTheme.bodySmall,
                            textAlign: TextAlign.end,
                            softWrap: true,
                            maxLines: 2,
                          ),
                        ),
                        const Icon(Icons.arrow_right_rounded),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              context.go('/test/${test.id}/run');
              FirebaseAnalytics.instance.logEvent(
                name: 'test_start',
                parameters: {
                  'test_id': test.id,
                  'test_version': test.version,
                },
              );
            },
            label: const Text('Start test'),
            icon: Icon(MultiIcons.start),
          ),
        ),
      ),
    );
  }
}

class DataCollectionWidget extends StatelessWidget {
  const DataCollectionWidget(this.list, {super.key});

  final List<TestDataCollection> list;

  @override
  Widget build(BuildContext context) {
    TextStyle style = DefaultTextStyle.of(context).style;

    if (list.isEmpty) {
      return const Text('None');
    } else {
      return Text.rich(
        TextSpan(
          text: 'This test collects your data about ',
          style: style,
          children: [
            for (int i = 0; i < list.length; i++)
              TooltipSpan(
                message: list[i].longDescription,
                inlineSpan: TextSpan(
                  text: i == list.length - 1
                      ? '${list[i].shortDescrption}.'
                      : '${list[i].shortDescrption}, ',
                  style: style.copyWith(
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
              ),
          ],
        ),
      );
    }
  }
}

class TooltipSpan extends WidgetSpan {
  TooltipSpan({
    required String message,
    required InlineSpan inlineSpan,
  }) : super(
          child: Tooltip(
            margin: const EdgeInsets.all(16),
            triggerMode: TooltipTriggerMode.tap,
            message: message,
            child: RichText(
              text: inlineSpan,
            ),
          ),
        );
}
