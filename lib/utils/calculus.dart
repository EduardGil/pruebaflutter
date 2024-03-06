export 'calculus.dart';

bool isBetween(num min, num x, num max, [bool includeLimits = true]) {
  return includeLimits ? !(x < min || x > max) : !(x <= min || x >= max);
}
