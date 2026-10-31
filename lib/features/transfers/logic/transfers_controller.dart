import 'package:flutter/foundation.dart';
import '../../../core/services/api_service.dart';
import '../../../models/transfer_model.dart';

class TransferController extends ChangeNotifier {
  List<TransferModel> results = [];
  bool isLoading = false;
  TransferModel? selectedTransfer;

  String fromLocation = '';
  String toLocation = '';
  DateTime? date;
  int passengers = 1;

  Future<void> search() async {
    if (fromLocation.isEmpty || toLocation.isEmpty) return;
    isLoading = true;
    notifyListeners();
    final rides = await ApiService.instance.searchTransfers(
      from: fromLocation,
      to: toLocation,
      date: date,
      passengers: passengers,
    );
    results = rides
        .where((ride) => ride.maxPassengers >= passengers)
        .map((ride) => ride.copyWith(
              pickupLocation: fromLocation,
              dropoffLocation: toLocation,
              pickupTime: date,
            ))
        .toList()
      ..sort((a, b) => a.priceUSD.compareTo(b.priceUSD));
    isLoading = false;
    notifyListeners();
  }

  void selectTransfer(TransferModel t) {
    selectedTransfer = t;
    notifyListeners();
  }
}
