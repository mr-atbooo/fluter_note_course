import 'package:intl/intl.dart';

class DateTimeServices {


  String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} يوم';
    } else {
      return DateFormat('yyyy/MM/dd').format(date);
    }
  }

  String formatDateTimeExactly(DateTime dateTime) {
    return DateFormat('yyyy/MM/dd - hh:mm:ss a').format(dateTime);
  }

  String formatTimeOnly(DateTime dateTime) {
    // الخيار 1: الوقت بـ 12 ساعة مع AM/PM
    return DateFormat('hh:mm:ss a').format(dateTime);
    // 02:30:45 PM

    // الخيار 2: الوقت بـ 12 ساعة بدون ثواني
    // return DateFormat('hh:mm a').format(dateTime);
    // 02:30 PM

    // الخيار 3: الوقت بـ 24 ساعة
    // return DateFormat('HH:mm:ss').format(dateTime);
    // 14:30:45
  }

    String formatRemainingTime(DateTime futureDate) {
      final now = DateTime.now();
      final difference = futureDate.difference(now);

      // لو التاريخ فات
      if (difference.isNegative) {
        return 'انتهى منذ ${formatPastTime(futureDate)}';
      }

      // الأيام
      if (difference.inDays > 0) {
        if (difference.inDays == 1) {
          final hours = difference.inHours % 24;
          if (hours > 0) {
            return 'بعد يوم و $hours ساعة';
          }
          return 'بعد يوم واحد';
        } else if (difference.inDays < 30) {
          final hours = difference.inHours % 24;
          if (hours > 0) {
            return 'بعد ${difference.inDays} يوم و $hours ساعة';
          }
          return 'بعد ${difference.inDays} يوم';
        } else if (difference.inDays < 365) {
          final months = (difference.inDays / 30).floor();
          final days = difference.inDays % 30;
          if (days > 0) {
            return 'بعد $months شهر و $days يوم';
          }
          return 'بعد $months شهر';
        } else {
          final years = (difference.inDays / 365).floor();
          final months = ((difference.inDays % 365) / 30).floor();
          if (months > 0) {
            return 'بعد $years سنة و $months شهر';
          }
          return 'بعد $years سنة';
        }
      }

      // الساعات
      if (difference.inHours > 0) {
        if (difference.inHours == 1) {
          final minutes = difference.inMinutes % 60;
          if (minutes > 0) {
            return 'بعد ساعة و $minutes دقيقة';
          }
          return 'بعد ساعة واحدة';
        } else {
          final minutes = difference.inMinutes % 60;
          if (minutes > 0) {
            return 'بعد ${difference.inHours} ساعة و $minutes دقيقة';
          }
          return 'بعد ${difference.inHours} ساعة';
        }
      }

      // الدقائق
      if (difference.inMinutes > 0) {
        if (difference.inMinutes == 1) {
          return 'بعد دقيقة واحدة';
        } else {
          return 'بعد ${difference.inMinutes} دقيقة';
        }
      }

      // الثواني
      if (difference.inSeconds > 0) {
        return 'بعد ${difference.inSeconds} ثانية';
      }

      return 'الآن';
    }

    // دالة مساعدة للتواريخ الماضية
    String formatPastTime(DateTime pastDate) {
      final now = DateTime.now();
      final difference = now.difference(pastDate);

      if (difference.inDays > 0) {
        return '${difference.inDays} يوم';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} ساعة';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} دقيقة';
      } else {
        return '${difference.inSeconds} ثانية';
      }
    }



/**********************************************************/
 // دالة لمقارنة الوقت فقط
  String compareTimeOnly(DateTime dateTime) {
    final now = DateTime.now();
    
    // بناء وقت النهاردة بنفس الساعة والدقيقة
    final todayTime = DateTime(
      now.year,
      now.month,
      now.day,
      dateTime.hour,
      dateTime.minute,
      dateTime.second,
    );
    
    // تحديد الوقت المستهدف (النهاردة أو بكرة)
    final targetTime = todayTime.isBefore(now)
        ? todayTime.add(const Duration(days: 1))
        : todayTime;
    
    final difference = targetTime.difference(now);
    
    return _formatDifference(difference);
  }
  
  // دالة مساعدة للتنسيق
  String _formatDifference(Duration difference) {
    if (difference.inDays > 0) {
      if (difference.inDays == 1) {
        final hours = difference.inHours % 24;
        if (hours > 0) {
          return 'بعد يوم و $hours ساعة';
        }
        return 'بعد يوم';
      }
      return 'بعد ${difference.inDays} يوم';
    }
    
    if (difference.inHours > 0) {
      if (difference.inHours == 1) {
        final minutes = difference.inMinutes % 60;
        if (minutes > 0) {
          return 'بعد ساعة و $minutes دقيقة';
        }
        return 'بعد ساعة';
      } else {
        final minutes = difference.inMinutes % 60;
        if (minutes > 0) {
          return 'بعد ${difference.inHours} ساعة و $minutes دقيقة';
        }
        return 'بعد ${difference.inHours} ساعة';
      }
    }
    
    if (difference.inMinutes > 0) {
      if (difference.inMinutes == 1) {
        return 'بعد دقيقة';
      }
      return 'بعد ${difference.inMinutes} دقيقة';
    }
    
    if (difference.inSeconds > 0) {
      return 'بعد ${difference.inSeconds} ثانية';
    }
    
    return 'الآن';
  }
/**********************************************************/


}

