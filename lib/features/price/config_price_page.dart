import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/helpers/double_utils.dart';
import '../../core/index.dart';
import '../../domain/entities/get_id.dart';
import '../../domain/entities/order/price.dart';
import '../../domain/entities/product/inventory.dart';
import '../../domain/repositories/order/price_repository.dart';
import '../../provider/index.dart';
import '../../provider/load_list.dart';
import '../../provider/text_search.dart';
import '../../shared_widgets/index.dart';
import '../../shared_widgets/toast.dart';
import '../../shared_widgets/hook/text_controller_hook.dart';
import '../product/product_list_page.dart';
import '../product/provider/product_provider.dart';
import '../product/widget/product_card.dart';

@RoutePage()
class ConfigProductPricePage extends HookConsumerWidget {
  const ConfigProductPricePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Reset search when leaving the page
    useEffect(() {
      return () {
        ref.read(textSearchProvider.notifier).state = '';
        ref.read(isSearchVisibleProvider.notifier).state = false;
      };
    }, []);

    return const Scaffold(
      appBar: ConfigPriceAppBar(),
      body: ProductListView(),
    );
  }
}

// ConfigPriceAppBar with search functionality
class ConfigPriceAppBar extends HookConsumerWidget implements PreferredSizeWidget {
  const ConfigPriceAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchFocusNode = useFocusNode();
    final searchController = useTextEditingController();
    final debouncedSearchText = useDebouncedText(searchController);

    // Trigger search when debounced text changes
    useEffect(() {
      Future(() => ref.read(textSearchProvider.notifier).state = debouncedSearchText);
      return null;
    }, [debouncedSearchText]);

    final isSearchVisible = ref.watch(isSearchVisibleProvider);

    return isSearchVisible
        ? AppBar(
            // Custom search AppBar
            backgroundColor: Theme.of(context).colorScheme.primary,
            leading: InkWell(
              child: const Icon(Icons.close, color: Colors.white),
              onTap: () {
                ref.read(isSearchVisibleProvider.notifier).state = false;
                ref.read(textSearchProvider.notifier).state = '';
                searchController.clear();
              },
            ),
            titleSpacing: 0,
            centerTitle: false,
            title: TextField(
              controller: searchController,
              focusNode: searchFocusNode,
              style: const TextStyle(color: Colors.white),
              cursorColor: Colors.white,
              decoration: InputDecoration(
                  hintText: 'Tìm kiếm sản phẩm...',
                  hintStyle: const TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                  suffix: Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: AnimatedBuilder(
                        animation: searchController,
                        builder: (context, _) {
                          final isNotEmpty = searchController.text.isNotEmpty;
                          if (!isNotEmpty) {
                            return const SizedBox.shrink();
                          }
                          return InkWell(
                            onTap: () {
                              searchController.clear();
                              ref.read(textSearchProvider.notifier).state = '';
                            },
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.clear,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          );
                        }),
                  )),
              autofocus: true,
              textInputAction: TextInputAction.search,
              textAlignVertical: TextAlignVertical.center,
            ),
          )
        : CustomAppBar(
            title: 'Cấu hình giá sản phẩm',
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () {
                  ref.read(isSearchVisibleProvider.notifier).state = true;
                  // Đảm bảo focus vào text field và mở bàn phím
                  Future.delayed(const Duration(milliseconds: 50), () {
                    FocusScope.of(context).requestFocus(searchFocusNode);
                  });
                },
                tooltip: 'Tìm kiếm',
              ),
            ],
          );
  }

  @override
  Size get preferredSize => AppBar().preferredSize;
}

class ProductListView extends HookConsumerWidget {
  const ProductListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use loadProductProvider which already has productFilterProvider inside
    final products = ref.watch(loadProductProvider);
    final theme = context.appTheme;

    if (products.hasError) {
      return Center(child: Text('Lỗi: ${products.error}'));
    } else if (products.isEmpty) {
      return const EmptyItemWidget();
    } else {
      return Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            alignment: Alignment.centerLeft,
            child: Text('Đã tải ${products.data.length}/${products.totalCount} sản phẩm'),
          ),
          Expanded(
            child: LoadMoreList<Product>(
              items: products.data,
              itemBuilder: (context, index) {
                final product = products.data[index];
                return Consumer(builder: (context, ref, child) {
                  // Fetch product price by product ID
                  final productPrice = ref.watch(productPriceByIdProvider(product.id));
                  return GestureDetector(
                    onTap: () {
                      CreateProductPriceBottomSheet(
                        product: product,
                        productPrice: productPrice.valueOrNull,
                      ).show(context);
                    },
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Expanded(child: CustomProductCard(product: product)),
                          const SizedBox(width: 8),
                          productPrice.when(
                            data: (price) {
                              final profitPercentage = price.profitPercentage;

                              return Container(
                                constraints: const BoxConstraints(maxWidth: 120),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    //giá vốn
                                    Text(
                                      'Giá vốn',
                                      style: theme.textRegular13Subtle,
                                    ),
                                    Text(
                                      '${price.purchasePrice?.priceFormat() ?? 'Chưa có'}',
                                      style: theme.textMedium16Default,
                                      textAlign: TextAlign.end,
                                    ),
                                    const SizedBox(height: 8),

                                    Text(
                                      'Giá bán',
                                      style: theme.textRegular13Subtle,
                                    ),
                                    Text(
                                      '${price.sellingPrice?.priceFormat() ?? 'Chưa có'}',
                                      style: theme.textMedium16Default,
                                      textAlign: TextAlign.end,
                                    ),

                                    // Profit percentage display
                                    if (profitPercentage != null) ...[
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Icon(
                                            profitPercentage >= 0 ? Icons.trending_up : Icons.trending_down,
                                            color: profitPercentage >= 0 ? Colors.green : Colors.red,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${profitPercentage >= 0 ? '+' : ''}${profitPercentage.displayFormat()}%',
                                            style: theme.textRegular12Default.copyWith(
                                              color: profitPercentage >= 0 ? Colors.green : Colors.red,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            },
                            loading: () => const SizedBox(),
                            error: (error, stack) => const SizedBox(),
                          ),
                        ],
                      ),
                    ),
                  );
                });
              },
              separatorBuilder: (context, index) => const AppDivider(),
              onLoadMore: () async {
                return Future(
                  () {
                    return ref.read(loadProductProvider.notifier).loadMore();
                  },
                );
              },
              isCanLoadMore: !products.isEndOfList,
            ),
          ),
        ],
      );
    }
  }
}

//create product price bottom sheet
class CreateProductPriceBottomSheet extends HookConsumerWidget with ShowBottomSheet<void> {
  final Product product;
  final ProductPrice? productPrice;

  const CreateProductPriceBottomSheet({
    super.key,
    required this.product,
    this.productPrice,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sellPriceController = useTextEditingController();
    final purchasePriceController = useTextEditingController();

    double? sellingPrice() {
      return double.tryParse(sellPriceController.text);
    }

    double? purchasePrice() {
      return double.tryParse(purchasePriceController.text);
    }

    // Calculate profit percentage
    double? calculateProfitPercentage() {
      // Create temporary ProductPrice object to use the getter
      final tempPrice = ProductPrice(
        id: 0,
        productId: 0,
        productName: '',
        sellingPrice: sellingPrice(),
        purchasePrice: purchasePrice(),
      );
      return tempPrice.profitPercentage;
    }

    bool isValidFields() {
      // Check if the fields are empty or have invalid number format
      final sellPriceText = sellPriceController.text.trim();
      if (sellPriceText.isNotEmpty && double.tryParse(sellPriceText) == null) {
        return false; // Allow empty fields
      }

      final purchasePriceText = purchasePriceController.text.trim();
      if (purchasePriceText.isNotEmpty && double.tryParse(purchasePriceText) == null) {
        return false; // Allow empty fields
      }

      return true; // All fields are valid or empty
    }

    useEffect(() {
      if (productPrice != null) {
        sellPriceController.text = productPrice!.sellingPrice?.inputFormat() ?? '';
        purchasePriceController.text = productPrice!.purchasePrice?.inputFormat() ?? '';
      }
      return null;
    }, [productPrice]);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomProductCard(product: product),
          const SizedBox(height: 16),

          // Profit percentage display
          AnimatedBuilder(
            animation: Listenable.merge([sellPriceController, purchasePriceController]),
            builder: (BuildContext context, Widget? child) {
              final profitPercentage = calculateProfitPercentage();

              if (profitPercentage == null) {
                return const SizedBox.shrink();
              }

              final isProfit = profitPercentage >= 0;
              final color = isProfit ? Colors.green : Colors.red;
              final prefix = isProfit ? '+' : '';

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      isProfit ? Icons.trending_up : Icons.trending_down,
                      color: color,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Lợi nhuận: ',
                      style: context.appTheme.textRegular14Default,
                    ),
                    Text(
                      '${prefix}${profitPercentage.displayFormat()}%',
                      style: context.appTheme.textMedium16Default.copyWith(color: color),
                    ),
                    const Spacer(),
                    if (sellingPrice() != null && purchasePrice() != null)
                      Text(
                        '${prefix}${(sellingPrice()! - purchasePrice()!).priceFormat()}',
                        style: context.appTheme.textRegular13Subtle.copyWith(color: color),
                      ),
                  ],
                ),
              );
            },
          ),

          //Gía bán
          TitleBlockWidget.widget(
            titleWidget: AnimatedBuilder(
              animation: sellPriceController,
              builder: (BuildContext context, Widget? child) {
                return Text(
                  'Giá bán: ${sellingPrice() != null ? sellingPrice()?.priceFormat() : ''}',
                  style: context.appTheme.textRegular13Subtle,
                );
              },
            ),
            child: CustomTextField(
              controller: sellPriceController,
              label: 'Giá bán',
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
            ),
          ),
          const SizedBox(height: 16),
          //Giá vốn
          TitleBlockWidget.widget(
            titleWidget: AnimatedBuilder(
              animation: purchasePriceController,
              builder: (BuildContext context, Widget? child) {
                return Text(
                  'Giá vốn: ${purchasePrice() != null ? purchasePrice()!.priceFormat() : ''}',
                  style: context.appTheme.textRegular13Subtle,
                );
              },
            ),
            child: CustomTextField(
              controller: purchasePriceController,
              label: 'Giá vốn',
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
            ),
          ),

          // Add yo
          BottomButtonBar(
            padding: EdgeInsets.only(top: 16),
            onSave: () async {
              if (!isValidFields()) {
                showError(message: 'Vui lòng nhập đúng định dạng số');
                return;
              }

              final priceRepository = ref.read(priceRepositoryProvider);
              if (productPrice != null) {
                // Update existing price
                await priceRepository.update(
                  productPrice!.copyWith(
                    sellingPrice: sellingPrice(), // Replace with actual value
                    purchasePrice: purchasePrice(), // Replace with actual value
                  ),
                );
              } else {
                // Create new price
                await priceRepository.create(
                  ProductPrice(
                    id: undefinedId,
                    productName: product.name,
                    productId: product.id,
                    sellingPrice: sellingPrice(), // Replace with actual value
                    purchasePrice: purchasePrice(), // Replace with actual value
                  ),
                );
              }

              ref.invalidate(productPriceByIdProvider(product.id));
              // Handle save action
              Navigator.pop(context);
            },
            onCancel: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
