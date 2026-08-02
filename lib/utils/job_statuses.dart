class JobStatuses {
  JobStatuses._();

  static const offering = 'Offering';
  static const accepted = 'Accepted';
  static const ongoing = 'Ongoing';
  static const completed = 'Completed';
  static const cancelled = 'Cancelled';
  static const failed = 'Failed';

  static String? _norm(String? status) => status?.trim().toLowerCase();

  static bool isOffering(String? status) => _norm(status) == 'offering';

  static bool isFailed(String? status) => _norm(status) == 'failed';

  static bool isAccepted(String? status) => _norm(status) == 'accepted';

  static bool isActive(String? status) {
    final s = _norm(status);
    return s == 'offering' || s == 'accepted' || s == 'ongoing';
  }

  static bool isCompleted(String? status) => _norm(status) == 'completed';

  static bool isCancelledGroup(String? status) {
    final s = _norm(status);
    return s == 'cancelled' || s == 'failed';
  }

  /// Customer can cancel while Offering (requesting) or Accepted.
  static bool canCancel(String? status) {
    final s = _norm(status);
    return s == 'offering' || s == 'accepted';
  }

  static bool canChat(String? status) {
    final s = _norm(status);
    return s == 'accepted' || s == 'ongoing';
  }

  static bool canRate(String? status, bool hasRating) =>
      isCompleted(status) && !hasRating;

  static bool canComplaint(String? status) {
    final s = _norm(status);
    return s == 'accepted' ||
        s == 'ongoing' ||
        s == 'completed' ||
        s == 'cancelled';
  }
}
