import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:motion/home.dart';
import 'package:motion/inbox.dart';
import 'package:motion/models.dart';
import 'package:motion/style.dart';
import 'package:motion/widgets.dart';
import 'package:provider/provider.dart';

class MailViewRouterDelegate extends RouterDelegate<void>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin {
  MailViewRouterDelegate({required this.drawerController});

  final AnimationController drawerController;

  @override
  Widget build(BuildContext context) {
    bool handlePopPage(Route<dynamic> route, dynamic result) {
      return false;
    }

    return Selector<EmailStore, String>(
      selector: (context, emailStore) => emailStore.currentlySelectedInbox,
      builder: (context, currentlySelectedInbox, child) {
        return Navigator(
          key: navigatorKey,
          onPopPage: handlePopPage,
          pages: [
            // TODO: Add Fade through transition between mailbox pages (Motion)
            CustomTransitionPage(
              transitionKey: ValueKey(currentlySelectedInbox),
              screen: InboxPage(
                destination: currentlySelectedInbox,
              ),
            )
          ],
        );
      },
    );
  }

  @override
  GlobalKey<NavigatorState> get navigatorKey => mobileMailNavKey;

  @override
  Future<bool> popRoute() {
    var emailStore =
        Provider.of<EmailStore>(navigatorKey.currentContext!, listen: false);
    bool onCompose = emailStore.onCompose;

    bool onMailView = emailStore.onMailView;

    // Handles the back button press when we are on the HomePage. When the
    // drawer is visible reverse the drawer and do nothing else. If the drawer
    // is not visible then we check if we are on the main mailbox. If we are on
    // main mailbox then our app will close, if not then it will set the
    // mailbox to the main mailbox.
    if (!(onMailView || onCompose)) {
      if (emailStore.bottomDrawerVisible) {
        drawerController.reverse();
        return SynchronousFuture<bool>(true);
      }

      if (emailStore.currentlySelectedInbox != 'Inbox') {
        emailStore.currentlySelectedInbox = 'Inbox';
        return SynchronousFuture<bool>(true);
      }
      return SynchronousFuture<bool>(false);
    }

    // Handles the back button when on the [ComposePage].
    if (onCompose) {
      // TODO: Add Container Transform from FAB to compose email page (Motion)
      emailStore.onCompose = false;
      return SynchronousFuture<bool>(false);
    }

    // Handles the back button when the bottom drawer is visible on the
    // MailView. Dismisses the drawer on back button press.
    if (emailStore.bottomDrawerVisible && onMailView) {
      drawerController.reverse();
      return SynchronousFuture<bool>(true);
    }

    // Handles the back button press when on the MailView. If there is a route
    // to pop then pop it, and reset the currentlySelectedEmailId to -1
    // to notify listeners that we are no longer on the MailView.
    if (navigatorKey.currentState!.canPop()) {
      navigatorKey.currentState!.pop();
      Provider.of<EmailStore>(navigatorKey.currentContext!, listen: false)
          .currentlySelectedEmailId = -1;
      return SynchronousFuture<bool>(true);
    }

    return SynchronousFuture<bool>(false);
  }

  @override
  Future<void> setNewRoutePath(void configuration) {
    // This function will never be called.
    throw UnimplementedError();
  }
}

// TODO: Add Fade through transition between mailbox pages (Motion)

class MailPreviewCard extends StatelessWidget {
  const MailPreviewCard({
    Key? key,
    required this.id,
    required this.email,
    required this.onDelete,
    required this.onStar,
  }) : super(key: key);

  final int id;
  final Email email;
  final VoidCallback onDelete;
  final VoidCallback onStar;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final currentEmailStarred = Provider.of<EmailStore>(
      context,
      listen: false,
    ).isEmailStarred(email);

    final colorScheme = theme.colorScheme;
    final mailPreview = _MailPreview(
      id: id,
      email: email,
      onStar: onStar,
      onDelete: onDelete,
    );
    final onStarredInbox = Provider.of<EmailStore>(
          context,
          listen: false,
        ).currentlySelectedInbox ==
        'Starred';

    // TODO: Add Container Transform transition from email list to email detail page (Motion)
    return Material(
      color: theme.cardColor,
      child: InkWell(
        onTap: () {
          Provider.of<EmailStore>(
            context,
            listen: false,
          ).currentlySelectedEmailId = id;

          mobileMailNavKey.currentState!.push(
            PageRouteBuilder(
              pageBuilder: (BuildContext context, Animation<double> animation,
                  Animation<double> secondaryAnimation) {
                return MailViewPage(id: id, email: email);
              },
            ),
          );
        },
        child: Dismissible(
          key: ObjectKey(email),
          dismissThresholds: const {
            DismissDirection.startToEnd: 0.8,
            DismissDirection.endToStart: 0.4,
          },
          onDismissed: (direction) {
            switch (direction) {
              case DismissDirection.endToStart:
                if (onStarredInbox) {
                  onStar();
                }
                break;
              case DismissDirection.startToEnd:
                onDelete();
                break;
              default:
            }
          },
          background: _DismissibleContainer(
            icon: 'twotone_delete',
            backgroundColor: colorScheme.primary,
            iconColor: ReplyColors.blue50,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsetsDirectional.only(start: 20),
          ),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.endToStart) {
              if (onStarredInbox) {
                return true;
              }
              onStar();
              return false;
            } else {
              return true;
            }
          },
          secondaryBackground: _DismissibleContainer(
            icon: 'twotone_star',
            backgroundColor: currentEmailStarred
                ? colorScheme.secondary
                : theme.scaffoldBackgroundColor,
            iconColor: currentEmailStarred
                ? colorScheme.onSecondary
                : colorScheme.onBackground,
            alignment: Alignment.centerRight,
            padding: const EdgeInsetsDirectional.only(end: 20),
          ),
          child: mailPreview,
        ),
      ),
    );
  }
}

// TODO: Add Container Transform transition from email list to email detail page (Motion)

class _DismissibleContainer extends StatelessWidget {
  const _DismissibleContainer({
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    required this.alignment,
    required this.padding,
  });

  final String icon;
  final Color backgroundColor;
  final Color iconColor;
  final Alignment alignment;
  final EdgeInsetsDirectional padding;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      alignment: alignment,
      color: backgroundColor,
      curve: standardEasing,
      duration: kThemeAnimationDuration,
      padding: padding,
      child: Material(
        color: Colors.transparent,
        child: ImageIcon(
          AssetImage(
            'reply/icons/$icon.png',
            package: 'flutter_gallery_assets',
          ),
          size: 36,
          color: iconColor,
        ),
      ),
    );
  }
}

class _MailPreview extends StatelessWidget {
  const _MailPreview({
    required this.id,
    required this.email,
    this.onStar,
    this.onDelete,
  });

  final int id;
  final Email email;
  final VoidCallback? onStar;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    var emailStore = Provider.of<EmailStore>(
      context,
      listen: false,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: constraints.maxHeight),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            '${email.sender} - ${email.time}',
                            style: textTheme.bodySmall,
                          ),
                          const SizedBox(height: 4),
                          Text(email.subject, style: textTheme.headlineSmall),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                    _MailPreviewActionBar(
                      avatar: email.avatar,
                      isStarred: emailStore.isEmailStarred(email),
                      onStar: onStar,
                      onDelete: onDelete,
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    end: 20,
                  ),
                  child: Text(
                    email.message,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: textTheme.bodyMedium,
                  ),
                ),
                if (email.containsPictures) ...[
                  Flexible(
                    fit: FlexFit.loose,
                    child: Column(
                      children: const [
                        SizedBox(height: 20),
                        _PicturePreview(),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PicturePreview extends StatelessWidget {
  const _PicturePreview();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: ListView.builder(
        itemCount: 4,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsetsDirectional.only(end: 4),
            child: Image.asset(
              'reply/attachments/paris_${index + 1}.jpg',
              gaplessPlayback: true,
              package: 'flutter_gallery_assets',
            ),
          );
        },
      ),
    );
  }
}

class _MailPreviewActionBar extends StatelessWidget {
  const _MailPreviewActionBar({
    required this.avatar,
    required this.isStarred,
    this.onStar,
    this.onDelete,
  });

  final String avatar;
  final bool isStarred;
  final VoidCallback? onStar;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ProfileAvatar(avatar: avatar),
      ],
    );
  }
}

class MailViewPage extends StatelessWidget {
  const MailViewPage({Key? key, required this.id, required this.email})
      : super(key: key);

  final int id;
  final Email email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SizedBox(
          height: double.infinity,
          child: Material(
            color: Theme.of(context).cardColor,
            child: SingleChildScrollView(
              padding: const EdgeInsetsDirectional.only(
                top: 42,
                start: 20,
                end: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _MailViewHeader(email: email),
                  const SizedBox(height: 32),
                  _MailViewBody(message: email.message),
                  if (email.containsPictures) ...[
                    const SizedBox(height: 28),
                    const _PictureGrid(),
                  ],
                  const SizedBox(height: kToolbarHeight),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MailViewHeader extends StatelessWidget {
  const _MailViewHeader({
    required this.email,
  });

  final Email email;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                email.subject,
                style: textTheme.headlineMedium!.copyWith(height: 1.1),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.keyboard_arrow_down),
              onPressed: () {
                Provider.of<EmailStore>(
                  context,
                  listen: false,
                ).currentlySelectedEmailId = -1;
                Navigator.pop(context);
              },
              splashRadius: 20,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('${email.sender} - ${email.time}'),
                const SizedBox(height: 4),
                Text(
                  'To ${email.recipients},',
                  style: textTheme.bodySmall!.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.64),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 4),
              child: ProfileAvatar(avatar: email.avatar),
            ),
          ],
        ),
      ],
    );
  }
}

class _MailViewBody extends StatelessWidget {
  const _MailViewBody({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 16),
    );
  }
}

class _PictureGrid extends StatelessWidget {
  const _PictureGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Image.asset(
          'reply/attachments/paris_${index + 1}.jpg',
          gaplessPlayback: true,
          package: 'flutter_gallery_assets',
          fit: BoxFit.fill,
        );
      },
    );
  }
}
