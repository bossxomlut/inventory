import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../provider/current_index.dart';
import '../../provider/load_list.dart';
import '../../shared_widgets/index.dart';
import 'provider/user_provider.dart';
import 'widgets/user_card.dart';

@RoutePage()
class UserPage extends HookConsumerWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
// Use TextEditingController for search input
    final searchController = useTextEditingController();

    // Track search text reactively
    final searchText = useState('');

    // Listen to controller changes
    useEffect(() {
      void onTextChanged() {
        searchText.value = searchController.text;
      }

      searchController.addListener(onTextChanged);
      return () => searchController.removeListener(onTextChanged); // Cleanup
    }, [searchController]);

    // Debounce the search text
    final debouncedSearchText = useDebounced(searchText.value, Duration(milliseconds: 500));

    // Trigger search when debounced text changes
    useEffect(() {
      Future(
        () {
          ref.read(loadUserProvider.notifier).search(debouncedSearchText ?? '');
        },
      );
      return null; // No cleanup needed for search call
    }, [debouncedSearchText]);

    final user = ref.watch(loadUserProvider);

    final showSearchState = useState(false);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Quản lý người dùng',
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearchState.value = true;
              // Show search bar or perform search action
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // SearchBar(
          //   controller: searchController,
          // ),
          Expanded(
            child: Builder(
              builder: (BuildContext context) {
                if (user.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (user.isEmpty) {
                  return const Center(child: Text('No users found'));
                }

                return ListView.separated(
                  itemCount: user.data.length,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  itemBuilder: (context, index) {
                    return ProviderScope(
                      overrides: [
                        currentIndexProvider.overrideWithValue(index),
                      ],
                      child: const UserCard(),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 4),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// class _UserPageState extends ConsumerState<UserPage> {
//   @override
//   void initState() {
//     super.initState();
//
//     // //add frame callback to load data
//     // WidgetsBinding.instance.addPostFrameCallback((_) {
//     //   ref.read(loadUserProvider.notifier).loadData(
//     //         query: LoadListQuery(
//     //           page: 1,
//     //           pageSize: 10,
//     //           search: '',
//     //         ),
//     //       );
//     // });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final user = ref.watch(loadUserProvider);
//
//     useEffect(() {
//       ref.read(loadUserProvider.notifier).loadData(
//             query: LoadListQuery(
//               page: 1,
//               pageSize: 10,
//               search: '',
//             ),
//           );
//       return;
//     }, []);
//
//     //
//     // useEffect(() {
//     //   ref.read(loadUserProvider.notifier).loadData(
//     //         query: LoadListQuery(
//     //           page: 1,
//     //           pageSize: 10,
//     //           search: '',
//     //         ),
//     //       );
//     //   return null;
//     // });
//     //
//     final searchController = useTextEditingController();
//     //
//     final searchText = useDebounced(searchController.text, Duration(milliseconds: 500));
//     // //
//     // useEffect(
//     //   () {
//     //     ref.read(loadUserProvider.notifier).search(
//     //           query: LoadListQuery(
//     //             page: 1,
//     //             pageSize: 10,
//     //             search: searchText,
//     //           ),
//     //         );
//     //     return null;
//     //   },
//     //   [searchText],
//     // );
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('User Page'),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           // Invalidate the provider to trigger a reload
//           ref.refresh(loadUserProvider);
//           // Alternatively, use ref.refresh(dataProvider) to get the new value immediately
//         },
//         child: const Icon(Icons.add),
//       ),
//       body: Column(
//         children: [
//           SearchBar(
//             controller: searchController,
//           ),
//           Expanded(
//             child: Builder(
//               builder: (BuildContext context) {
//                 if (user.isLoading) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//
//                 if (user.isEmpty) {
//                   return const Center(child: Text('No users found'));
//                 }
//
//                 return ListView.builder(
//                   itemCount: user.data.length,
//                   itemBuilder: (context, index) {
//                     final userItem = user.data[index];
//                     return ListTile(
//                       title: Text(userItem.username),
//                       subtitle: Text(userItem.role.name),
//                       onTap: () {
//                         // Handle user item tap
//                       },
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
