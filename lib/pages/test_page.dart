import 'package:flutter/material.dart';
import 'package:multitests/classes/tests_registry.dart';
import 'package:multitests/pages/page_404.dart';
import 'package:multitests/utils/utils.dart';
import 'package:multitests/widgets/actions_builder_widget.dart';
import 'package:multitests/widgets/categories_wrap.dart';
import 'package:share_plus_dialog/share_plus_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class TestPage extends StatelessWidget {
  const TestPage(this.testID, {super.key});

  final String testID;

  @override
  Widget build(BuildContext context) {
    Test test;
    try {
      test = TestRegistry.registeredTests.firstWhere(
        (element) => element.id == testID,
      );
    } on StateError {
      return const Page404(
        errorText: 'It seems this test does not exist.',
      );
    }
    return Title(
      title: 'MultiTests - ${test.testName}',
      color: Theme.of(context).colorScheme.primary,
      child: IconTheme(
        data: Theme.of(context).iconTheme.copyWith(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
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
                      icon: Icons.share_rounded,
                      onTap: (context, inMenu) {
                        ShareDialog.share(
                          context,
                          test.testUrl,
                          platforms: SharePlatform.defaults,
                          isUrl: true,
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
                    Padding(
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
                                  style:
                                      Theme.of(context).textTheme.headlineSmall,
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
                                    pushInsteadOfGo: true,
                                  ),
                                ),
                              ),
                              ListTile(
                                title: const Text('Data collection'),
                                subtitle: DataCollectionWidget(
                                    test.testDataCollections),
                                trailing: const Tooltip(
                                  margin: EdgeInsets.all(16),
                                  preferBelow: false,
                                  triggerMode: TooltipTriggerMode.tap,
                                  message:
                                      'Some tests might collect informations for public reports',
                                  child: Icon(
                                    Icons.help_outline_rounded,
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
                    // About doing the test
                    Padding(
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
                                  style:
                                      Theme.of(context).textTheme.headlineSmall,
                                ),
                              ),
                              ListTile(
                                title: const Text('Number of questions'),
                                subtitle: Text(test.questionsNumber.toString()),
                              ),
                              ListTile(
                                title: const Text('Estimated time'),
                                subtitle:
                                    Text(printDuration(test.testDuration)),
                              ),
                              if (test.testSuggestions.isNotEmpty)
                                ListTile(
                                  title: Text('Suggestions'),
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
                    // About result card
                    Padding(
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
                                  style:
                                      Theme.of(context).textTheme.headlineSmall,
                                ),
                              ),
                              const ListTile(
                                title: Text(
                                    'I really have no clue what exactly to put in here'),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        child: ListTile(
                          onTap: () {
                            launchUrl(Uri.parse(test.testAuthor.authorWebpage));
                          },
                          title:
                              Text('Test provided by ${test.testAuthor.name}'),
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
                    padding: const EdgeInsets.only(
                      top: 32,
                      bottom: 32,
                      right: 150,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            'Press this button to start the test',
                            style: Theme.of(context).textTheme.bodySmall,
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
            onPressed: () {},
            label: const Text('Start test'),
            icon: const Icon(Icons.play_arrow_rounded),
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
