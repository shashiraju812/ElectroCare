// utils/app_strings.dart
// Application strings with multi-language support

import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../services/language_service.dart';

class AppStrings {
  // ── Common ──────────────────────────────────────────────────────
  static String appTitle(BuildContext context) =>
      context.read<LanguageService>().translate('app_title');
  static String home(BuildContext context) =>
      context.read<LanguageService>().translate('home');
  static String products(BuildContext context) =>
      context.read<LanguageService>().translate('products');
  static String services(BuildContext context) =>
      context.read<LanguageService>().translate('services');
  static String orders(BuildContext context) =>
      context.read<LanguageService>().translate('orders');
  static String profile(BuildContext context) =>
      context.read<LanguageService>().translate('profile');
  static String cart(BuildContext context) =>
      context.read<LanguageService>().translate('cart');
  static String search(BuildContext context) =>
      context.read<LanguageService>().translate('search');
  static String settings(BuildContext context) =>
      context.read<LanguageService>().translate('settings');
  static String logout(BuildContext context) =>
      context.read<LanguageService>().translate('logout');
  
  // ── Auth ────────────────────────────────────────────────────────
  static String login(BuildContext context) =>
      context.read<LanguageService>().translate('login');
  static String signup(BuildContext context) =>
      context.read<LanguageService>().translate('signup');
  static String email(BuildContext context) =>
      context.read<LanguageService>().translate('email');
  static String password(BuildContext context) =>
      context.read<LanguageService>().translate('password');
  static String phone(BuildContext context) =>
      context.read<LanguageService>().translate('phone');
  static String address(BuildContext context) =>
      context.read<LanguageService>().translate('address');
  
  // ── Actions ─────────────────────────────────────────────────────
  static String save(BuildContext context) =>
      context.read<LanguageService>().translate('save');
  static String cancel(BuildContext context) =>
      context.read<LanguageService>().translate('cancel');
  static String delete(BuildContext context) =>
      context.read<LanguageService>().translate('delete');
  static String edit(BuildContext context) =>
      context.read<LanguageService>().translate('edit');
  
  // ── Status ──────────────────────────────────────────────────────
  static String loading(BuildContext context) =>
      context.read<LanguageService>().translate('loading');
  static String error(BuildContext context) =>
      context.read<LanguageService>().translate('error');
  static String success(BuildContext context) =>
      context.read<LanguageService>().translate('success');
  static String welcome(BuildContext context) =>
      context.read<LanguageService>().translate('welcome');
  
  // ── Shop ────────────────────────────────────────────────────────
  static String electricalProducts(BuildContext context) =>
      context.read<LanguageService>().translate('electrical_products');
  static String bestSellers(BuildContext context) =>
      context.read<LanguageService>().translate('best_sellers');
  static String newArrivals(BuildContext context) =>
      context.read<LanguageService>().translate('new_arrivals');
  static String addToCart(BuildContext context) =>
      context.read<LanguageService>().translate('add_to_cart');
  static String price(BuildContext context) =>
      context.read<LanguageService>().translate('price');
  static String quantity(BuildContext context) =>
      context.read<LanguageService>().translate('quantity');
  static String total(BuildContext context) =>
      context.read<LanguageService>().translate('total');
  
  // ── Orders ──────────────────────────────────────────────────────
  static String checkout(BuildContext context) =>
      context.read<LanguageService>().translate('checkout');
  static String deliveryAddress(BuildContext context) =>
      context.read<LanguageService>().translate('delivery_address');
  static String paymentMethod(BuildContext context) =>
      context.read<LanguageService>().translate('payment_method');
  static String orderStatus(BuildContext context) =>
      context.read<LanguageService>().translate('order_status');
  static String trackOrder(BuildContext context) =>
      context.read<LanguageService>().translate('track_order');
  
  // ── Reviews ─────────────────────────────────────────────────────
  static String rating(BuildContext context) =>
      context.read<LanguageService>().translate('rating');
  static String reviews(BuildContext context) =>
      context.read<LanguageService>().translate('reviews');
  static String writeReview(BuildContext context) =>
      context.read<LanguageService>().translate('write_review');
}
