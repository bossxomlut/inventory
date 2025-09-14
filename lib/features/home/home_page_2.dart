import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/index.dart';
import '../../provider/theme.dart';
import '../../routes/app_router.dart';
import '../../shared_widgets/index.dart';
import '../authentication/provider/auth_provider.dart';
import 'menu_manager.dart';

@RoutePage()
class HomePage2 extends ConsumerWidget {
  const HomePage2({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider);
    final theme = context.appTheme;
    return user.when(
        authenticated: (User user, DateTime? lastLoginTime) {
          // Sử dụng MenuManager để lấy menu theo role
          List<MenuGroup> menuGroups = MenuManager.getMenuGroupsForRole(user.role);

          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Modern header with greeting
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                theme.colorPrimary.withOpacity(0.08),
                                theme.colorPrimary.withOpacity(0.03),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: theme.colorPrimary.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      theme.colorPrimary,
                                      theme.colorPrimary.withOpacity(0.8),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: theme.colorPrimary.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.person,
                                  size: 28,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Xin chào,',
                                      style: theme.textRegular14Sublest,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      user.username,
                                      style: theme.headingSemibold20Default,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: theme.colorBackground,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: theme.colorBorderSublest,
                                    width: 1,
                                  ),
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.settings_outlined,
                                    color: theme.colorIcon,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    appRouter.goToSetting();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ]),
                    ),
                  ),
                  SliverList.separated(
                    itemBuilder: (BuildContext context, int groupIdx) {
                      final group = menuGroups[groupIdx];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 4, bottom: 10),
                              child: Text(
                                group.title,
                                style: theme.headingSemibold20Primary,
                              ),
                            ),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 1.3,
                              ),
                              itemCount: group.items.length,
                              itemBuilder: (context, index) {
                                final item = group.items[index];
                                return InkWell(
                                  onTap: item.destinationCallback,
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: theme.colorBackground,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: theme.colorBorderSublest,
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: theme.colorPrimary.withOpacity(0.06),
                                          blurRadius: 16,
                                          offset: const Offset(0, 4),
                                          spreadRadius: 0,
                                        ),
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.02),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                          spreadRadius: 0,
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 48,
                                            height: 48,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  theme.colorPrimary.withOpacity(0.1),
                                                  theme.colorPrimary.withOpacity(0.05),
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              borderRadius: BorderRadius.circular(14),
                                              border: Border.all(
                                                color: theme.colorPrimary.withOpacity(0.1),
                                                width: 1,
                                              ),
                                            ),
                                            child: Icon(
                                              item.icon,
                                              size: 24,
                                              color: theme.colorPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Flexible(
                                            child: FittedBox(
                                              child: Text(
                                                item.title,
                                                style: theme.textMedium16Default,
                                                textAlign: TextAlign.center,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) => const SizedBox(
                      height: 12,
                    ),
                    itemCount: menuGroups.length,
                  ),
                ],
              ),
            ),
          );
        },
        unauthenticated: () => Scaffold(
              appBar: AppBar(
                title: const Text('Quản lý kho'),
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Vui lòng đăng nhập để sử dụng ứng dụng.'),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        appRouter.goToLogin();
                      },
                      child: Text('Đăng nhập'),
                    ),
                  ],
                ),
              ),
            ),
        initial: () => const SizedBox());
  }
}
