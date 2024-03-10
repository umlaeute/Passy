import 'package:flutter/material.dart';

import 'package:passy/common/common.dart';
import 'package:passy/passy_data/entry_type.dart';
import 'package:passy/passy_data/identity.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';
import 'package:passy/screens/common.dart';
import 'package:passy/screens/identity_screen.dart';

import 'main_screen.dart';
import 'search_screen.dart';
import 'edit_identity_screen.dart';

class IdentitiesScreen extends StatefulWidget {
  const IdentitiesScreen({Key? key}) : super(key: key);

  static const routeName = '${MainScreen.routeName}/identities';

  @override
  State<StatefulWidget> createState() => _IdentitiesScreen();
}

class _IdentitiesScreen extends State<IdentitiesScreen> {
  final _account = data.loadedAccount!;
  List<String> _tags = [];

  void _onAddPressed() =>
      Navigator.pushNamed(context, EditIdentityScreen.routeName);

  void _onSearchPressed({String? tag}) {
    Navigator.pushNamed(context, SearchScreen.routeName,
        arguments: SearchScreenArgs(
            notSelectedTags: _tags.toList()..remove(tag),
            selectedTags: tag == null ? [] : [tag],
            builder:
                (String terms, List<String> tags, void Function() rebuild) {
              final List<IdentityMeta> _found = [];
              final List<String> _terms = terms.trim().toLowerCase().split(' ');
              for (IdentityMeta _identity
                  in _account.identitiesMetadata.values) {
                {
                  bool testIdentity(IdentityMeta value) =>
                      _identity.key == value.key;

                  if (_found.any(testIdentity)) continue;
                }
                {
                  bool _tagMismatch = false;
                  for (String tag in tags) {
                    if (_identity.tags.contains(tag)) continue;
                    _tagMismatch = true;
                  }
                  if (_tagMismatch) continue;
                  int _positiveCount = 0;
                  for (String _term in _terms) {
                    if (_identity.firstAddressLine
                        .toLowerCase()
                        .contains(_term)) {
                      _positiveCount++;
                      continue;
                    }
                    if (_identity.nickname.toLowerCase().contains(_term)) {
                      _positiveCount++;
                      continue;
                    }
                  }
                  if (_positiveCount == _terms.length) {
                    _found.add(_identity);
                  }
                }
              }
              if (_found.isEmpty) {
                return CustomScrollView(
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Column(
                        children: [
                          const Spacer(flex: 7),
                          Text(
                            localizations.noSearchResults,
                            textAlign: TextAlign.center,
                          ),
                          const Spacer(flex: 7),
                        ],
                      ),
                    ),
                  ],
                );
              }
              return IdentityButtonListView(
                identities: _found,
                shouldSort: true,
                onPressed: (identity) => Navigator.pushNamed(
                  context,
                  IdentityScreen.routeName,
                  arguments: _account.getIdentity(identity.key),
                ),
                popupMenuItemBuilder: identityPopupMenuBuilder,
              );
            }));
  }

  Future<void> _load() async {
    List<String> newTags;
    try {
      newTags = await _account.identitiesTags;
    } catch (_) {
      return;
    }
    if (mounted) {
      setState(() {
        _tags = newTags;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _load();
    List<IdentityMeta> _identities = [];
    try {
      _identities = _account.identitiesMetadata.values.toList();
    } catch (_) {}
    return Scaffold(
      appBar: EntriesScreenAppBar(
          entryType: EntryType.identity,
          title: Center(child: Text(localizations.identities)),
          onSearchPressed: _onSearchPressed,
          onAddPressed: _onAddPressed),
      body: _identities.isEmpty
          ? CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    children: [
                      const Spacer(flex: 7),
                      Text(
                        localizations.noIdentities,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      FloatingActionButton(
                          child: const Icon(Icons.add_rounded),
                          onPressed: () => Navigator.pushNamed(
                              context, EditIdentityScreen.routeName)),
                      const Spacer(flex: 7),
                    ],
                  ),
                ),
              ],
            )
          : IdentityButtonListView(
              topWidgets: [
                PassyPadding(
                  ThreeWidgetButton(
                    left: const Icon(Icons.add_rounded),
                    center: Text(
                      localizations.addIdentity,
                      textAlign: TextAlign.center,
                    ),
                    right: const Icon(Icons.arrow_forward_ios_rounded),
                    onPressed: () => Navigator.pushNamed(
                        context, EditIdentityScreen.routeName),
                  ),
                ),
                if (_tags.isNotEmpty)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(
                          top: PassyTheme.passyPadding.top / 2,
                          bottom: PassyTheme.passyPadding.bottom / 2),
                      child: EntryTagList(
                        notSelected: _tags,
                        onAdded: (tag) => setState(() {
                          _onSearchPressed(tag: tag);
                        }),
                      ),
                    ),
                  ),
              ],
              identities: _identities,
              shouldSort: true,
              onPressed: (identity) => Navigator.pushNamed(
                context,
                IdentityScreen.routeName,
                arguments: _account.getIdentity(identity.key),
              ),
              popupMenuItemBuilder: identityPopupMenuBuilder,
            ),
    );
  }
}
