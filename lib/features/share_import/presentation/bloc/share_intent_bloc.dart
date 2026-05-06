import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:finance_app/features/share_import/domain/entities/transaction.dart';
import '../../../../shared/errors/failure.dart';
import '../../../../shared/usecases/usecase.dart';
import '../../domain/usecases/share_intent_usecases.dart';

// Events
abstract class ShareIntentEvent extends Equatable {
  const ShareIntentEvent();

  @override
  List<Object?> get props => [];
}

class ShareIntentStarted extends ShareIntentEvent {
  const ShareIntentStarted();
}

class ShareIntentReceived extends ShareIntentEvent {
  final String content;

  const ShareIntentReceived(this.content);

  @override
  List<Object?> get props => [content];
}

class ShareIntentParseRequested extends ShareIntentEvent {
  final String content;

  const ShareIntentParseRequested(this.content);

  @override
  List<Object?> get props => [content];
}

class ShareIntentSaveRequested extends ShareIntentEvent {
  final Transaction transaction;

  const ShareIntentSaveRequested(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class ShareIntentCleared extends ShareIntentEvent {
  const ShareIntentCleared();
}

// States
abstract class ShareIntentState extends Equatable {
  const ShareIntentState();

  @override
  List<Object?> get props => [];
}

class ShareIntentInitial extends ShareIntentState {
  const ShareIntentInitial();
}

class ShareIntentLoading extends ShareIntentState {
  const ShareIntentLoading();
}

class ShareIntentReceivedState extends ShareIntentState {
  final String content;

  const ShareIntentReceivedState(this.content);

  @override
  List<Object?> get props => [content];
}

class ShareIntentParsedState extends ShareIntentState {
  final Transaction transaction;

  const ShareIntentParsedState(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class ShareIntentSaving extends ShareIntentState {
  final Transaction transaction;

  const ShareIntentSaving(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class ShareIntentSuccess extends ShareIntentState {
  final Transaction savedTransaction;

  const ShareIntentSuccess(this.savedTransaction);

  @override
  List<Object?> get props => [savedTransaction];
}

class ShareIntentFailure extends ShareIntentState {
  final Failure failure;

  const ShareIntentFailure(this.failure);

  @override
  List<Object?> get props => [failure];
}

// BLoC
class ShareIntentBloc extends Bloc<ShareIntentEvent, ShareIntentState> {
  final GetInitialSharedTextUseCase getInitialSharedText;
  final ListenShareIntentUseCase listenShareIntent;
  final ParseSharedContentUseCase parseSharedContent;
  final SaveTransactionUseCase saveTransaction;

  StreamSubscription? _shareIntentSubscription;

  ShareIntentBloc({
    required this.getInitialSharedText,
    required this.listenShareIntent,
    required this.parseSharedContent,
    required this.saveTransaction,
  }) : super(const ShareIntentInitial()) {
    on<ShareIntentStarted>(_onStarted);
    on<ShareIntentReceived>(_onReceived);
    on<ShareIntentParseRequested>(_onParseRequested);
    on<ShareIntentSaveRequested>(_onSaveRequested);
    on<ShareIntentCleared>(_onCleared);
  }

  Future<void> _onStarted(
    ShareIntentStarted event,
    Emitter<ShareIntentState> emit,
  ) async {
    emit(const ShareIntentLoading());

    try {
      final initialText = await getInitialSharedText(const NoParams());

      if (initialText != null && initialText.isNotEmpty) {
        emit(ShareIntentReceivedState(initialText));
      } else {
        emit(const ShareIntentInitial());
      }

      final stream = await listenShareIntent(const NoParams());
      _shareIntentSubscription = stream.listen((content) {
        add(ShareIntentReceived(content));
      });
    } on Failure catch (failure) {
      emit(ShareIntentFailure(failure));
    } catch (e) {
      emit(const ShareIntentFailure(UnknownFailure()));
    }
  }

  Future<void> _onReceived(
    ShareIntentReceived event,
    Emitter<ShareIntentState> emit,
  ) async {
    emit(ShareIntentReceivedState(event.content));
  }

  Future<void> _onParseRequested(
    ShareIntentParseRequested event,
    Emitter<ShareIntentState> emit,
  ) async {
    emit(const ShareIntentLoading());

    try {
      final transaction = await parseSharedContent(event.content);
      emit(ShareIntentParsedState(transaction));
    } on Failure catch (failure) {
      emit(ShareIntentFailure(failure));
    } catch (e) {
      emit(const ShareIntentFailure(UnknownFailure()));
    }
  }

  Future<void> _onSaveRequested(
    ShareIntentSaveRequested event,
    Emitter<ShareIntentState> emit,
  ) async {
    emit(ShareIntentSaving(event.transaction));

    try {
      await saveTransaction(event.transaction);
      emit(ShareIntentSuccess(event.transaction));
    } on Failure catch (failure) {
      emit(ShareIntentFailure(failure));
    } catch (e) {
      emit(const ShareIntentFailure(UnknownFailure()));
    }
  }

  Future<void> _onCleared(
    ShareIntentCleared event,
    Emitter<ShareIntentState> emit,
  ) async {
    emit(const ShareIntentInitial());
  }

  @override
  Future<void> close() {
    _shareIntentSubscription?.cancel();
    return super.close();
  }
}
