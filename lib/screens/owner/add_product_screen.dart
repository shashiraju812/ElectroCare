// screens/owner/add_product_screen.dart
// ─────────────────────────────────────────────────────────────────
// UPGRADED: Supports both ADD and EDIT modes
// Proper validation, category picker, discount price field
// ─────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../services/product_service.dart';
import '../../services/auth_service.dart';
import '../../models/product_model.dart';
import '../../utils/app_colors.dart';
import '../../widgets/cached_product_image.dart';

class AddProductScreen extends StatefulWidget {
  /// If provided, opens in EDIT mode
  final Product? existingProduct;

  const AddProductScreen({super.key, this.existingProduct});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _discountCtrl;
  late final TextEditingController _imageUrlCtrl;
  late final TextEditingController _stockCtrl;
  late String _selectedCategory;
  bool _isLoading = false;

  bool get isEditMode => widget.existingProduct != null;

  static const List<String> _categories = [
    'Lighting', 'Electrical', 'Wiring', 'Accessories',
    'Appliances', 'Protection', 'Tools', 'Smart Home',
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.existingProduct;
    _nameCtrl     = TextEditingController(text: p?.name ?? '');
    _descCtrl     = TextEditingController(text: p?.description ?? '');
    _priceCtrl    = TextEditingController(text: p?.price.toString() ?? '');
    _discountCtrl = TextEditingController(text: p?.discountPrice?.toString() ?? '');
    _imageUrlCtrl = TextEditingController(text: p?.imageUrl ?? '');
    _stockCtrl    = TextEditingController(text: p?.stock.toString() ?? '10');
    _selectedCategory = p?.category ?? _categories[0];
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _descCtrl.dispose(); _priceCtrl.dispose();
    _discountCtrl.dispose(); _imageUrlCtrl.dispose(); _stockCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          isEditMode ? 'Edit Product' : 'Add Product',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Preview image
              if (_imageUrlCtrl.text.isNotEmpty)
                Center(
                  child: Container(
                    height: 140, width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F4FF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: CachedProductImage(
                      imageUrl: _imageUrlCtrl.text,
                      height: 140,
                      fit: BoxFit.contain,
                      backgroundColor: const Color(0xFFF0F4FF),
                    ),
                  ),
                ),

              _buildField('Product Name *', _nameCtrl,
                validator: (v) => v!.trim().isEmpty ? 'Name is required' : null),
              _buildField('Description *', _descCtrl, maxLines: 3,
                validator: (v) => v!.trim().isEmpty ? 'Description is required' : null),

              // Category Dropdown
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Category *',
                    labelStyle: GoogleFonts.outfit(color: AppColors.textGrey),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat, style: GoogleFonts.outfit()))).toList(),
                  onChanged: (val) => setState(() => _selectedCategory = val!),
                ),
              ),

              Row(children: [
                Expanded(child: _buildField('MRP Price (₹) *', _priceCtrl, keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v!.isEmpty) return 'Required';
                    if (double.tryParse(v) == null) return 'Invalid number';
                    return null;
                  })),
                const SizedBox(width: 12),
                Expanded(child: _buildField('Sale Price (₹)', _discountCtrl, keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.isEmpty) return null;
                    final d = double.tryParse(v);
                    final p = double.tryParse(_priceCtrl.text);
                    if (d == null) return 'Invalid number';
                    if (p != null && d >= p) return 'Must be less than MRP';
                    return null;
                  })),
              ]),

              _buildField('Stock Quantity *', _stockCtrl, keyboardType: TextInputType.number,
                validator: (v) {
                  if (v!.isEmpty) return 'Required';
                  if (int.tryParse(v) == null) return 'Must be a whole number';
                  return null;
                }),

              _buildField('Image URL', _imageUrlCtrl,
                hint: 'https://example.com/image.jpg',
                onChanged: (_) => setState(() {})), // Refresh preview

              const SizedBox(height: 8),

              SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      : Text(
                          isEditMode ? 'Save Changes' : 'Add Product',
                          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    String? hint,
    void Function(String)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        onChanged: onChanged,
        style: GoogleFonts.outfit(),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: GoogleFonts.outfit(color: AppColors.textGrey, fontSize: 13),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
          ),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red)),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final auth = context.read<AuthService>();
    final productService = context.read<ProductService>();

    final product = Product(
      id: widget.existingProduct?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      price: double.parse(_priceCtrl.text),
      discountPrice: _discountCtrl.text.isEmpty ? null : double.parse(_discountCtrl.text),
      imageUrl: _imageUrlCtrl.text.trim(),
      category: _selectedCategory,
      stock: int.parse(_stockCtrl.text),
      ownerId: auth.userId,
    );

    if (isEditMode) {
      await productService.updateProduct(product);
    } else {
      await productService.addProduct(product);
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        isEditMode ? '✅ Product updated!' : '✅ Product added!',
        style: GoogleFonts.outfit(color: Colors.white),
      ),
      backgroundColor: Colors.green,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));

    Navigator.pop(context);
  }
}
