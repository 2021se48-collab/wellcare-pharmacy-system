import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<void> init() async {
    print('Notification Service Initialized');
  }

  Future<void> showNotification(String title, String body) async {
    print('Notification: $title - $body');
    // In a real app, this would show actual notifications
  }

  Future<void> showLowStockAlert(String medicineName, int stock) async {
    await showNotification('Low Stock Alert', '$medicineName has only $stock units left!');
  }

  Future<void> showSaleCompletedAlert(double total) async {
    await showNotification('Sale Completed', 'Total amount: ₨${total.toStringAsFixed(2)}');
  }
}