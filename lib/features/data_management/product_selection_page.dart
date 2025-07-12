import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../provider/theme.dart';
import '../../shared_widgets/index.dart';
import '../../domain/models/shop_type.dart';
import '../../domain/models/sample_product.dart';
import '../../services/shop_type_service.dart';
import '../../resources/index.dart';
import 'widgets/sample_product_card.dart';

class ProductSelectionPage extends ConsumerStatefulWidget {
  final ShopType shopType;

  const ProductSelectionPage({
    super.key,
    required this.shopType,
  });

  @override
  ConsumerState<ProductSelectionPage> createState() => _ProductSelectionPageState();
}

class _ProductSelectionPageState extends ConsumerState<ProductSelectionPage> {
  List<SampleProduct> _products = [];
  List<SampleProduct> _selectedProducts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final products = await ShopTypeService.loadSampleProductsForShopType(widget.shopType);
      
      setState(() {
        _products = products;
        _selectedProducts = List.from(products); // Select all by default
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _toggleProduct(SampleProduct product) {
    setState(() {
      if (_selectedProducts.contains(product)) {
        _selectedProducts.remove(product);
      } else {
        _selectedProducts.add(product);
      }
    });
  }

  void _selectAll() {
    setState(() {
      _selectedProducts = List.from(_products);
    });
  }

  void _deselectAll() {
    setState(() {
      _selectedProducts.clear();
    });
  }

  Future<void> _saveSelectedProducts() async {
    if (_selectedProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ít nhất một sản phẩm'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      // TODO: Implement save to database logic here
      await Future<void>.delayed(const Duration(seconds: 1)); // Simulate save

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã lưu ${_selectedProducts.length} sản phẩm thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi lưu dữ liệu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return Scaffold(
      appBar: CustomAppBar(
        title: widget.shopType.name,
        actions: [
          if (!_isLoading && _error == null) ...[
            IconButton(
              onPressed: _selectedProducts.length == _products.length ? _deselectAll : _selectAll,
              icon: Icon(
                _selectedProducts.length == _products.length 
                  ? HugeIcons.strokeRoundedCancel01
                  : HugeIcons.strokeRoundedCheckmarkSquare02,
                color: theme.colorPrimary,
              ),
              tooltip: _selectedProducts.length == _products.length ? 'Bỏ chọn tất cả' : 'Chọn tất cả',
            ),
          ],
        ],
      ),
      body: _buildBody(theme),
      bottomNavigationBar: _buildBottomBar(theme),
    );
  }

  Widget _buildBody(AppThemeData theme) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              HugeIcons.strokeRoundedAlert01,
              size: 64,
              color: theme.colorError,
            ),
            const SizedBox(height: 16),
            Text(
              'Có lỗi xảy ra',
              style: theme.headingSemibold20Default,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: theme.textRegular14Default,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            AppButton.primary(
              title: 'Thử lại',
              onPressed: _loadProducts,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            slivers: [
              // Header section as sliver
              SliverToBoxAdapter(
                child: _buildHeader(theme),
              ),
              // Product list
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final product = _products[index];
                      final isSelected = _selectedProducts.contains(product);

                      return AnimatedScale(
                        scale: isSelected ? 1.0 : 0.98,
                        duration: const Duration(milliseconds: 200),
                        child: SampleProductCard(
                          product: product,
                          isSelected: isSelected,
                          onTap: () => _toggleProduct(product),
                          onCheckboxChanged: (_) => _toggleProduct(product),
                        ),
                      );
                    },
                    childCount: _products.length,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(AppThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[300]!,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: theme.colorPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    widget.shopType.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.shopType.name,
                      style: theme.headingSemibold20Default,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.shopType.description,
                      style: theme.textRegular14Default,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey[300]!,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  theme,
                  'Tổng SP',
                  '${_products.length}',
                  HugeIcons.strokeRoundedPackage,
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: Colors.grey[400],
                ),
                _buildStatItem(
                  theme,
                  'Đã chọn',
                  '${_selectedProducts.length}',
                  HugeIcons.strokeRoundedCheckmarkSquare02,
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: Colors.grey[400],
                ),
                _buildStatItem(
                  theme,
                  'Tổng SL',
                  '${_selectedProducts.fold<int>(0, (sum, product) => sum + product.quantity)}',
                  HugeIcons.strokeRoundedCube,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(AppThemeData theme, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: theme.colorPrimary,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: theme.colorPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textRegular12Default,
        ),
      ],
    );
  }

  Widget _buildBottomBar(AppThemeData theme) {
    if (_isLoading || _error != null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey[300]!,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: AppButton.primary(
          title: _selectedProducts.isEmpty 
            ? 'Chọn ít nhất 1 sản phẩm'
            : 'Hoàn thành (${_selectedProducts.length})',
          onPressed: _selectedProducts.isNotEmpty ? _saveSelectedProducts : null,
        ),
      ),
    );
  }
}
