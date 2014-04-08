library jwt.jwt_claimset;

import 'jose.dart';
import 'validation_constraint.dart';
import 'util.dart';

class JwtClaimSet extends JosePayload with _JwtClaimSetMixin {
  final String issuer;
  final String subject;
  final DateTime expiry;
  final DateTime issuedAt;
  
  JwtClaimSet(this.issuer, this.subject, this.expiry, this.issuedAt);
  
  JwtClaimSet.fromJson(Map json)
      : issuer = json['iss'],
        subject = json['sub'],
        expiry = decodeIntDate(json['exp']),
        issuedAt = decodeIntDate(json['iat']);

}

class MutableJwtClaimSet extends JosePayload with _JwtClaimSetMixin 
    implements JwtClaimSet {
  String issuer;
  String subject;
  DateTime expiry;
  DateTime issuedAt;

  JwtClaimSet toImmutable() => 
      new JwtClaimSet(issuer, subject, expiry, issuedAt);
}

class JwtClaimSetValidationContext {
  final Duration expiryTolerance;
  
  const JwtClaimSetValidationContext( 
      { this.expiryTolerance: const Duration(seconds: 30) } );
}

abstract class _JwtClaimSetMixin  {
  String get issuer;
  String get subject;
  DateTime get expiry;
  DateTime get issuedAt;

  Map toJson() {
    return {
      'iat' : encodeIntDate(issuedAt),
      'exp' : encodeIntDate(expiry),
      'iss' : issuer,
      'sub' : subject
    };
  }
  
  String toString() => 'JwtClaimSet[issuer=$issuer]';
    
  Set<ConstraintViolation> validate(JwtClaimSetValidationContext validationContext) {
    final now = new DateTime.now();
    final diff = now.difference(expiry);
    if (diff > validationContext.expiryTolerance) {
      return new Set()..add(new ConstraintViolation(
          'JWT expired. Expiry ($expiry) is more than tolerance '
          '(${validationContext.expiryTolerance}) before now ($now)'));
    }
    
    return new Set.identity();
  }
}