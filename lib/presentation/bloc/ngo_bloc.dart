import 'package:equatable/equatable.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
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

class UpdateNgoNeedsEvent extends NgoEvent {
  final String ngoId;
  final Map<ItemCategory, bool> updatedNeeds;
  
  UpdateNgoNeedsEvent(this.ngoId, this.updatedNeeds);

  @override
  List<Object?> get props => [ngoId, updatedNeeds];
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
  DatabaseReference get _dbRef => FirebaseDatabase.instance.ref();
  List<Ngo> _allNgos = [];

  NgoBloc() : super(NgoInitial()) {
    on<LoadNgosEvent>(_onLoadNgos);
    on<MatchNgosEvent>(_onMatchNgos);
    on<UpdateNgoNeedsEvent>(_onUpdateNgoNeeds);
  }

  Future<void> _onLoadNgos(LoadNgosEvent event, Emitter<NgoState> emit) async {
    emit(NgoLoading());
    try {
      Position? currentPosition;
      try {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (serviceEnabled) {
          LocationPermission permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission();
          }
          if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
            currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low).timeout(const Duration(seconds: 3));
          }
        }
      } catch (_) {
        // ignore location errors to prevent crashing the flow
      }

      final snapshot = await _dbRef.child('ngos').get().timeout(const Duration(seconds: 3));
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        _allNgos = data.entries
            .map((e) => Ngo.fromJson(e.key as String, e.value as Map<dynamic, dynamic>))
            .toList();
            
        // If we loaded from Firebase but have a dynamic location, offset the DB coordinates
        if (currentPosition != null) {
          _allNgos = _allNgos.asMap().entries.map((entry) {
            final idx = entry.key;
            final ngo = entry.value;
            return Ngo(
              id: ngo.id,
              name: ngo.name,
              address: 'Dynamic Local Address',
              latitude: currentPosition!.latitude + (idx * 0.005) - 0.002,
              longitude: currentPosition!.longitude + (idx * 0.005) - 0.002,
              needs: ngo.needs,
            );
          }).toList();
        }
      } else {
        _allNgos = _getMockNgos(currentPosition);
        for (final ngo in _allNgos) {
          try {
            await _dbRef.child('ngos/${ngo.id}').set({
              'name': ngo.name,
              'address': ngo.address,
              'latitude': ngo.latitude,
              'longitude': ngo.longitude,
              'needs': ngo.needs.map((k, v) => MapEntry(k.name, v)),
            }).timeout(const Duration(seconds: 2));
          } catch (_) {
            // Ignore write timeouts on mock data seeding
          }
        }
      }
      emit(NgoLoaded(_allNgos, _allNgos));
    } catch (e) {
      _allNgos = _getMockNgos(null);
      emit(NgoLoaded(_allNgos, _allNgos));
    }
  }

  void _onMatchNgos(MatchNgosEvent event, Emitter<NgoState> emit) {
    final matched = _allNgos.where((ngo) => ngo.needsCategory(event.category)).toList();
    emit(NgoLoaded(_allNgos, matched));
  }

  Future<void> _onUpdateNgoNeeds(UpdateNgoNeedsEvent event, Emitter<NgoState> emit) async {
    try {
      final needsMap = event.updatedNeeds.map((k, v) => MapEntry(k.name, v));
      try {
        await _dbRef.child('ngos/${event.ngoId}/needs').update(needsMap).timeout(const Duration(seconds: 2));
      } catch (_) {
        // Ignore timeout on save so local state still updates instantly
      }
      
      final ngoIndex = _allNgos.indexWhere((ngo) => ngo.id == event.ngoId);
      if (ngoIndex != -1) {
        final oldNgo = _allNgos[ngoIndex];
        _allNgos[ngoIndex] = Ngo(
          id: oldNgo.id,
          name: oldNgo.name,
          address: oldNgo.address,
          latitude: oldNgo.latitude,
          longitude: oldNgo.longitude,
          needs: event.updatedNeeds,
        );
      }
      
      emit(NgoLoaded(_allNgos, _allNgos));
    } catch (e) {
      emit(NgoError(e.toString()));
      emit(NgoLoaded(_allNgos, _allNgos)); // fallback to loaded
    }
  }

  List<Ngo> _getMockNgos(Position? position) {
    // If no position, fallback to Chennai coordinates
    double lat = position?.latitude ?? 13.0604;
    double lon = position?.longitude ?? 80.2496;
    
    return [
      Ngo(
        id: 'ngo_1',
        name: 'Downtown Shelter',
        address: position != null ? 'Local Neighborhood Area' : '123 Anna Salai, Chennai, TN',
        latitude: lat + 0.002,
        longitude: lon + 0.002,
        needs: {
          ItemCategory.clothing: true,
          ItemCategory.electronics: false,
          ItemCategory.books: true,
          ItemCategory.furniture: false,
          ItemCategory.other: false,
        },
      ),
      Ngo(
        id: 'ngo_2',
        name: 'Community Aid Center',
        address: position != null ? 'Nearby Community Hub' : '456 T Nagar, Chennai, TN',
        latitude: lat - 0.005,
        longitude: lon + 0.003,
        needs: {
          ItemCategory.clothing: true,
          ItemCategory.electronics: true,
          ItemCategory.books: false,
          ItemCategory.furniture: true,
          ItemCategory.other: true,
        },
      ),
      Ngo(
        id: 'ngo_3',
        name: 'Local Food Bank',
        address: position != null ? 'City Center District' : '789 Adyar, Chennai, TN',
        latitude: lat + 0.004,
        longitude: lon - 0.004,
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