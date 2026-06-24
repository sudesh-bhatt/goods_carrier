import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/network/api_exception_mapper.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../../shared/domain/entities/notification_item.dart';
import '../../../../shared/domain/enums/session_phase.dart';
import '../../../../shared/domain/repositories/i_notifications_repository.dart';

class NotificationsState {
  const NotificationsState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.hasMore = true,
    this.currentPage = 0,
  });

  final List<NotificationItem> items;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final bool hasMore;
  final int currentPage;

  NotificationsState copyWith({
    List<NotificationItem>? items,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    bool? hasMore,
    int? currentPage,
    bool clearError = false,
  }) =>
      NotificationsState(
        items: items ?? this.items,
        isLoading: isLoading ?? this.isLoading,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        error: clearError ? null : (error ?? this.error),
        hasMore: hasMore ?? this.hasMore,
        currentPage: currentPage ?? this.currentPage,
      );

  int get unreadCount => items.where((n) => !n.isRead).length;
}

class NotificationsNotifier extends StateNotifier<NotificationsState> {
  NotificationsNotifier(this._repo, this._ref)
      : super(const NotificationsState()) {
    _listenAuth();
    _loadIfReady();
  }

  static const _perPage = 20;

  final INotificationsRepository _repo;
  final Ref _ref;
  bool _hasLoadedOnce = false;

  void _listenAuth() {
    _ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.sessionPhase != SessionPhase.authenticated) return;
      final becameAuthenticated =
          previous?.sessionPhase != SessionPhase.authenticated;
      if (!_hasLoadedOnce || becameAuthenticated) {
        refresh();
      }
    });
  }

  void _loadIfReady() {
    final auth = _ref.read(authProvider);
    if (auth.sessionPhase != SessionPhase.authenticated) return;
    refresh();
  }

  Future<void> loadForTab() async {
    final auth = _ref.read(authProvider);
    if (auth.sessionPhase != SessionPhase.authenticated) return;
    await refresh(showLoadingIndicator: state.items.isEmpty);
  }

  Future<void> refresh({bool showLoadingIndicator = true}) async {
    final auth = _ref.read(authProvider);
    if (auth.sessionPhase != SessionPhase.authenticated) {
      state = const NotificationsState();
      return;
    }

    if (showLoadingIndicator) {
      state = state.copyWith(isLoading: true, clearError: true);
    } else {
      state = state.copyWith(clearError: true);
    }

    try {
      final page = await _repo.listNotifications(page: 1, perPage: _perPage);
      _hasLoadedOnce = true;
      state = NotificationsState(
        items: page.items,
        currentPage: page.currentPage,
        hasMore: page.hasNextPage,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: ApiExceptionMapper.userMessage(e),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true, clearError: true);
    try {
      final nextPage = state.currentPage + 1;
      final page = await _repo.listNotifications(
        page: nextPage,
        perPage: _perPage,
      );
      state = state.copyWith(
        isLoadingMore: false,
        items: [...state.items, ...page.items],
        currentPage: page.currentPage,
        hasMore: page.hasNextPage,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: ApiExceptionMapper.userMessage(e),
      );
    }
  }

  Future<void> markRead(String id) async {
    try {
      await _repo.markRead(id);
      state = state.copyWith(
        items: state.items
            .map((n) => n.id == id ? n.markRead() : n)
            .toList(growable: false),
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(error: ApiExceptionMapper.userMessage(e));
    }
  }

  Future<void> markAllRead() async {
    try {
      await _repo.markAllRead();
      state = state.copyWith(
        items: state.items.map((n) => n.markRead()).toList(growable: false),
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(error: ApiExceptionMapper.userMessage(e));
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      await _repo.deleteNotification(id);
      state = state.copyWith(
        items: state.items.where((n) => n.id != id).toList(growable: false),
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(error: ApiExceptionMapper.userMessage(e));
    }
  }
}

final customerNotificationsProvider = StateNotifierProvider<
    NotificationsNotifier, NotificationsState>(
  (ref) => NotificationsNotifier(
    ref.read(customerNotificationsRepositoryProvider),
    ref,
  ),
);

final driverNotificationsProvider = StateNotifierProvider<
    NotificationsNotifier, NotificationsState>(
  (ref) => NotificationsNotifier(
    ref.read(driverNotificationsRepositoryProvider),
    ref,
  ),
);

final customerUnreadCountProvider = Provider<int>((ref) {
  return ref.watch(customerNotificationsProvider).unreadCount;
});

final driverUnreadCountProvider = Provider<int>((ref) {
  return ref.watch(driverNotificationsProvider).unreadCount;
});
