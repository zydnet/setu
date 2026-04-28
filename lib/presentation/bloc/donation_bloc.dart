import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/donation_request.dart';

// Events
abstract class DonationEvent {}

class AddDonationEvent extends DonationEvent {
  final DonationRequest donation;
  AddDonationEvent(this.donation);
}

class RemoveDonationEvent extends DonationEvent {
  final String donationId;
  RemoveDonationEvent(this.donationId);
}

// State
class DonationState {
  final List<DonationRequest> donations;
  DonationState(this.donations);
}

// Bloc
class DonationBloc extends Bloc<DonationEvent, DonationState> {
  DonationBloc() : super(DonationState(_initialMocks)) {
    on<AddDonationEvent>((event, emit) {
      final updatedList = List<DonationRequest>.from(state.donations);
      updatedList.insert(0, event.donation);
      emit(DonationState(updatedList));
    });

    on<RemoveDonationEvent>((event, emit) {
      final updatedList = state.donations.where((d) => d.id != event.donationId).toList();
      emit(DonationState(updatedList));
    });
  }

  static final List<DonationRequest> _initialMocks = [
    DonationRequest(id: '1', donorName: 'Alice Johnson', itemName: 'Office Chair', category: 'Furniture', distance: '1.2 miles away', time: '10 mins ago', deliveryPreference: 'Pickup Requested'),
    DonationRequest(id: '2', donorName: 'Marcus Smith', itemName: 'Winter Coats', category: 'Clothing', distance: '3.4 miles away', time: '1 hour ago', deliveryPreference: 'Donor Delivering'),
    DonationRequest(id: '3', donorName: 'Sarah Connor', itemName: 'Microwave Oven', category: 'Electronics', distance: '0.8 miles away', time: '2 hours ago', deliveryPreference: 'Pickup Requested'),
    DonationRequest(id: '4', donorName: 'David Chen', itemName: 'Children Books', category: 'Books', distance: '5.1 miles away', time: '5 hours ago', deliveryPreference: 'Donor Delivering'),
  ];
}
