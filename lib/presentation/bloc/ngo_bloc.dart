import 'package:equatable/equatable.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/ngo.dart';
import '../../../domain/entities/donatable_item.dart';

abstract class NgoEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadNgosEvent extends NgoEvent {}

class MatchNgosEvent extends NgoEvent {
  final ItemCategory category;
  MatchNgosEvent(this.category);

  @override
  List<Object?> get props => [category];
}

abstract class NgoState extends Equatable {
  @override
  List<Object?> get props => [];
}

class NgoInitial extends NgoState {}

class NgoLoading extends NgoState {}

class NgoLoaded extends NgoState {
  final List<Ngo> ngos;
  final List<Ngo> matchedNgos;
  NgoLoaded(this.ngos, this.matchedNgos);

  @override
  List<Object?> get props => [ngos, matchedNgos];
}

class NgoError extends NgoState {
  final String message;
  NgoError(this.message);

  @override
  List<Object?> get props => [message];
}

class NgoBloc extends Bloc<NgoEvent, NgoState> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  List<Ngo> _allNgos = [];

  NgoBloc() : super(NgoInitial()) {
    on<LoadNgosEvent>(_onLoadNgos);
    on<MatchNgosEvent>(_onMatchNgos);
  }

  Future<void> _onLoadNgos(LoadNgosEvent event, Emitter<NgoState> emit) async {
    emit(NgoLoading());
    try {
      final snapshot = await _dbRef.child('ngos').get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        _allNgos = data.entries
            .map((e) => Ngo.fromJson(e.key as String, e.value as Map<dynamic, dynamic>))
            .toList();
      } else {
        _allNgos = _getMockNgos();
        for (final ngo in _allNgos) {
          await _dbRef.child('ngos/${ngo.id}').set({
            'name': ngo.name,
            'address': ngo.address,
            'latitude': ngo.latitude,
            'longitude': ngo.longitude,
            'needs': ngo.needs.map((k, v) => MapEntry(k.name, v)),
          });
        }
      }
      emit(NgoLoaded(_allNgos, _allNgos));
    } catch (e) {
      _allNgos = _getMockNgos();
      emit(NgoLoaded(_allNgos, _allNgos));
    }
  }

  void _onMatchNgos(MatchNgosEvent event, Emitter<NgoState> emit) {
    final matched = _allNgos.where((ngo) => ngo.needsCategory(event.category)).toList();
    emit(NgoLoaded(_allNgos, matched));
  }

  List<Ngo> _getMockNgos() {
    return [
      const Ngo(
        id: 'ngo_1',
        name: 'Downtown Shelter',
        address: '123 Main St, San Francisco, CA',
        latitude: 37.7749,
        longitude: -122.4194,
        needs: {
          ItemCategory.clothing: true,
          ItemCategory.electronics: false,
          ItemCategory.books: true,
          ItemCategory.furniture: false,
          ItemCategory.other: false,
        },
      ),
      const Ngo(
        id: 'ngo_2',
        name: 'Community Aid Center',
        address: '456 Oak Ave, San Francisco, CA',
        latitude: 37.7849,
        longitude: -122.4094,
        needs: {
          ItemCategory.clothing: true,
          ItemCategory.electronics: true,
          ItemCategory.books: false,
          ItemCategory.furniture: true,
          ItemCategory.other: true,
        },
      ),
      const Ngo(
        id: 'ngo_3',
        name: 'Westside Food Bank',
        address: '789 Market St, San Francisco, CA',
        latitude: 37.7649,
        longitude: -122.4294,
        needs: {
          ItemCategory.clothing: false,
          ItemCategory.electronics: true,
          ItemCategory.books: true,
          ItemCategory.furniture: false,
          ItemCategory.other: false,
        },
      ),
    ];
  }
}