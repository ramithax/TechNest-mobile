import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/storage/token_storage.dart';
import '../../models/cart_item.dart';
import '../../models/order_model.dart';
import '../../models/pc_build_model.dart';
import '../../providers/cart_provider.dart';
import '../../services/order_service.dart';
import '../../services/pc_build_service.dart';
import '../order/order_success_page.dart';

class CheckoutPage extends StatefulWidget {
  final List<CartItem> items;
  final bool clearCartAfterOrder;
  final int? pcBuildId;

  const CheckoutPage({
    super.key,
    required this.items,
    this.clearCartAfterOrder = false,
    this.pcBuildId,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final OrderService _orderService = OrderService();
  final PcBuildService _pcBuildService = PcBuildService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  final TextEditingController _cardNameController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  bool _isLoading = false;
  bool _isBuildLoading = false;

  PcBuildModel? _pcBuild;

  double get _total {
    if (widget.pcBuildId != null) {
      return (_pcBuild?.items ?? []).fold(
        0,
        (total, item) => total + item.totalPrice,
      );
    }

    return widget.items.fold(0, (total, item) => total + item.totalPrice);
  }

  @override
  void initState() {
    super.initState();

    if (widget.pcBuildId != null) {
      _loadPcBuild();
    }
  }

  Future<void> _loadPcBuild() async {
    setState(() {
      _isBuildLoading = true;
    });

    try {
      final build = await _pcBuildService.getBuild(widget.pcBuildId!);

      if (!mounted) return;

      setState(() {
        _pcBuild = build;
        _isBuildLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isBuildLoading = false;
      });

      _showMessage(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cardNameController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _addressController.text.trim().isEmpty) {
      _showMessage('Please fill in all delivery details.');
      return;
    }

    if (!_isValidEmail(_emailController.text.trim())) {
      _showMessage('Please enter a valid email address.');
      return;
    }

    final phone = _phoneController.text.trim();

    if (!RegExp(r'^\d{10}$').hasMatch(phone)) {
      _showMessage('Contact number must contain exactly 10 digits.');
      return;
    }

    if (_cardNameController.text.trim().isEmpty) {
      _showMessage('Please enter the cardholder name.');
      return;
    }

    final cardNumber = _cardNumberController.text.replaceAll(' ', '');

    if (!RegExp(r'^\d{16}$').hasMatch(cardNumber)) {
      _showMessage('Card number must contain exactly 16 digits.');
      return;
    }

    final expiry = _expiryController.text.replaceAll('/', '');

    if (!RegExp(r'^\d{4}$').hasMatch(expiry)) {
      _showMessage('Expiry date must be in MM/YY format.');
      return;
    }

    final month = int.tryParse(expiry.substring(0, 2));

    if (month == null || month < 1 || month > 12) {
      _showMessage('Please enter a valid expiry month.');
      return;
    }

    if (_cvvController.text.trim().length != 3 ||
        !RegExp(r'^\d{3}$').hasMatch(_cvvController.text.trim())) {
      _showMessage('CVV must contain exactly 3 digits.');
      return;
    }

    if (widget.items.isEmpty && widget.pcBuildId == null) {
      _showMessage('There are no items to checkout.');
      return;
    }

    if (widget.pcBuildId != null &&
        (_pcBuild == null || _pcBuild!.items.isEmpty)) {
      _showMessage('Unable to load the PC build.');
      return;
    }

    // Show simulated payment BEFORE creating the order.
    final paymentSuccessful = await _showPaymentDialog();

    if (!paymentSuccessful) {
      return;
    }

    await _createOrder();
  }

  Future<bool> _showPaymentDialog() async {
    if (!mounted) return false;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Row(
            children: [
              Icon(Icons.credit_card_outlined, color: AppColors.primary),
              SizedBox(width: 10),
              Text(
                'Confirm Payment',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your payment is being simulated for this project.',
                style: TextStyle(fontSize: 13, color: Color(0xFF636E72)),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F9F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Color(0xFFE5E5E5)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Payment Amount',
                      style: TextStyle(fontSize: 13, color: Color(0xFF636E72)),
                    ),
                    Text(
                      formatPrice(_total),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Choose "Pay Now" to complete the simulated payment or "Cancel" to return without creating an order.',
                style: TextStyle(fontSize: 11, color: Color(0xFF7B7B7B)),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF636E72)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.dark,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Pay Now',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );

    return result == true;
  }

  Future<void> _createOrder() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final tokenStorage = TokenStorage();

      final accessToken = await tokenStorage.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        _showMessage('Please login again.');
        return;
      }

      final userId = _getUserIdFromToken(accessToken);

      if (userId == null) {
        _showMessage('Unable to identify your account.');
        return;
      }

      final OrderModel order;

      // PC BUILD CHECKOUT
      if (widget.pcBuildId != null) {
        debugPrint('PC Build ID: ${widget.pcBuildId}');

        order = await _orderService.createPcBuildOrder(
          pcBuildId: widget.pcBuildId!,
          customerName: _nameController.text.trim(),
          customerEmail: _emailController.text.trim(),
          shippingAddress: _addressController.text.trim(),
          contactNumber: _phoneController.text.trim(),
        );
      }
      // NORMAL PRODUCT CHECKOUT
      else {
        final orderItems = widget.items.map((item) {
          return {'productId': item.product.id, 'quantity': item.quantity};
        }).toList();

        debugPrint('Checkout User ID: $userId');
        debugPrint('Order Items: $orderItems');

        order = await _orderService.createOrder(
          userId: userId,
          customerName: _nameController.text.trim(),
          customerEmail: _emailController.text.trim(),
          shippingAddress: _addressController.text.trim(),
          contactNumber: _phoneController.text.trim(),
          orderType: 'Product',
          items: orderItems,
        );
      }

      if (!mounted) return;

      if (widget.clearCartAfterOrder) {
        context.read<CartProvider>().clearCart();
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OrderSuccessPage(order: order)),
      );
    } on DioException catch (e) {
      debugPrint('Create order error: ${e.response?.data}');

      String message = 'Failed to place order.';

      final data = e.response?.data;

      if (data != null) {
        if (data is String && data.isNotEmpty) {
          message = data;
        } else if (data is Map) {
          if (data['message'] != null) {
            message = data['message'].toString();
          } else if (data['title'] != null) {
            message = data['title'].toString();
          } else if (data['errors'] != null) {
            message = data['errors'].toString();
          }
        }
      }

      if (mounted) {
        _showMessage(message);
      }
    } catch (e) {
      debugPrint('Create order error: $e');

      if (mounted) {
        _showMessage(e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  int? _getUserIdFromToken(String token) {
    try {
      final parts = token.split('.');

      if (parts.length != 3) {
        debugPrint('Invalid JWT token.');
        return null;
      }

      final payload = parts[1];

      final normalizedPayload = base64Url.normalize(payload);
      final decodedBytes = base64Url.decode(normalizedPayload);
      final decodedString = utf8.decode(decodedBytes);

      final Map<String, dynamic> decodedToken = jsonDecode(decodedString);

      debugPrint('JWT claims: $decodedToken');

      const userIdClaim =
          'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier';

      final userId = decodedToken[userIdClaim];

      if (userId == null) {
        debugPrint('User ID claim not found in JWT.');
        return null;
      }

      final parsedUserId = int.tryParse(userId.toString());

      debugPrint('Parsed User ID: $parsedUserId');

      return parsedUserId;
    } catch (e) {
      debugPrint('JWT decode error: $e');
      return null;
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: const TextStyle(fontSize: 13))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: Color(0xFF2D3436),
          ),
          onPressed: _isLoading
              ? null
              : () {
                  Navigator.pop(context);
                },
        ),
        title: const Text(
          'Checkout',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3436),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(
              'Delivery Information',
              'Enter your delivery details',
            ),
            const SizedBox(height: 16),
            _buildLabel('Full Name'),
            const SizedBox(height: 7),
            _buildTextField(
              controller: _nameController,
              hint: 'Enter your full name',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 14),
            _buildLabel('Email'),
            const SizedBox(height: 7),
            _buildTextField(
              controller: _emailController,
              hint: 'Enter your email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 14),
            _buildLabel('Contact Number'),
            const SizedBox(height: 7),
            _buildTextField(
              controller: _phoneController,
              hint: '07XXXXXXXX',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 14),
            _buildLabel('Shipping Address'),
            const SizedBox(height: 7),
            _buildTextField(
              controller: _addressController,
              hint: 'Enter your shipping address',
              icon: Icons.location_on_outlined,
              maxLines: 2,
            ),
            const SizedBox(height: 30),
            _buildSectionTitle(
              'Payment Information',
              'Enter your card details',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        height: 38,
                        width: 38,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: const Icon(
                          Icons.credit_card_outlined,
                          color: Colors.white,
                          size: 21,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Card Payment',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D3436),
                          ),
                        ),
                      ),
                      Icon(
                        Icons.lock_outline,
                        size: 17,
                        color: Colors.grey.shade500,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _buildLabel('Cardholder Name'),
                  const SizedBox(height: 7),
                  _buildTextField(
                    controller: _cardNameController,
                    hint: 'Name on card',
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 14),
                  _buildLabel('Card Number'),
                  const SizedBox(height: 7),
                  _buildTextField(
                    controller: _cardNumberController,
                    hint: '1234 5678 9012 3456',
                    icon: Icons.credit_card_outlined,
                    keyboardType: TextInputType.number,
                    maxLength: 16,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Expiry Date'),
                            const SizedBox(height: 7),
                            _buildTextField(
                              controller: _expiryController,
                              hint: 'MM/YY',
                              icon: Icons.calendar_today_outlined,
                              keyboardType: TextInputType.number,
                              maxLength: 5,
                              inputFormatters: [ExpiryDateFormatter()],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('CVV'),
                            const SizedBox(height: 7),
                            _buildTextField(
                              controller: _cvvController,
                              hint: '123',
                              icon: Icons.lock_outline,
                              keyboardType: TextInputType.number,
                              maxLength: 3,
                              obscureText: true,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 15,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Payment processing is currently simulated.',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            _buildSectionTitle(
              'Order Summary',
              'Review your order before placing it',
            ),
            const SizedBox(height: 14),
            _buildOrderSummary(),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading || _isBuildLoading ? null : _placeOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.dark,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  disabledBackgroundColor: AppColors.darkTertiary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Place Order',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    if (_isBuildLoading) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const Center(
          child: SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
        ),
      );
    }

    if (widget.pcBuildId != null) {
      return _buildPcOrderSummary();
    }

    return _buildNormalOrderSummary();
  }

  Widget _buildNormalOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          ...widget.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 13),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      '${item.product.name} x${item.quantity}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF2D3436),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    formatPrice(item.totalPrice),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3436),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(color: Colors.grey.shade300),
          const SizedBox(height: 5),
          _buildTotalRow(),
        ],
      ),
    );
  }

  Widget _buildPcOrderSummary() {
    final items = _pcBuild?.items ?? [];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 13),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      '${item.productName} x${item.quantity}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF2D3436),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    formatPrice(item.totalPrice),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3436),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(color: Colors.grey.shade300),
          const SizedBox(height: 5),
          _buildTotalRow(),
        ],
      ),
    );
  }

  Widget _buildTotalRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Total',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3436),
          ),
        ),
        Text(
          formatPrice(_total),
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3436),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Color(0xFF2D3436),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    int? maxLength,
    bool obscureText = false,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: obscureText ? 1 : maxLines,
      maxLength: maxLength,
      obscureText: obscureText,
      inputFormatters: inputFormatters,
      style: const TextStyle(fontSize: 13, color: Color(0xFF2D3436)),
      decoration: InputDecoration(
        counterText: '',
        hintText: hint,
        hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
        prefixIcon: Icon(icon, size: 20, color: Colors.grey.shade500),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(11)),
          borderSide: BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }
}

class ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (digitsOnly.length > 4) {
      digitsOnly = digitsOnly.substring(0, 4);
    }

    String formattedText = '';

    if (digitsOnly.length > 2) {
      formattedText =
          '${digitsOnly.substring(0, 2)}/${digitsOnly.substring(2)}';
    } else {
      formattedText = digitsOnly;
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
