import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:agriculture_recommandation/domain/models/user_recommendation.dart';
import 'package:agriculture_recommandation/domain/models/rotation_models.dart';

class RecommendationFirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'user_recommendations';

  /// Sauvegarder une nouvelle recommandation
  static Future<String?> saveRecommendation({
    required String cultureName,
    required String regionName,
    required String climateName,
    required List<Culture> recommendedCultures,
  }) async {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return null;

      final recommendation = UserRecommendation(
        id: '',
        userId: currentUser.uid,
        cultureName: cultureName,
        regionName: regionName,
        climateName: climateName,
        recommendedCultures: recommendedCultures,
        createdAt: DateTime.now(),
      );

      final docRef = await _firestore
          .collection(_collection)
          .add(recommendation.toFirestore());

      return docRef.id;
    } catch (e) {
      print('Erreur lors de la sauvegarde de la recommandation: $e');
      return null;
    }
  }

  /// Récupérer les recommandations de l'utilisateur actuel (version simple sans index)
  static Future<List<UserRecommendation>> getUserRecommendations({
    int limit = 10,
  }) async {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return [];

      // Requête simplifiée sans orderBy pour éviter l'erreur d'index
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: currentUser.uid)
          .where('status', isEqualTo: 'active')
          .limit(limit)
          .get();

      // Trier localement par date de création
      final recommendations = querySnapshot.docs
          .map((doc) => UserRecommendation.fromFirestore(doc))
          .toList();
      
      recommendations.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return recommendations;
    } catch (e) {
      print('Erreur lors de la récupération des recommandations: $e');
      return [];
    }
  }

  /// Récupérer les recommandations en temps réel (version simple)
  static Stream<List<UserRecommendation>> getUserRecommendationsStream({
    int limit = 10,
  }) {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        return Stream.value([]);
      }

      // Requête simplifiée pour éviter l'erreur d'index
      return _firestore
          .collection(_collection)
          .where('userId', isEqualTo: currentUser.uid)
          .where('status', isEqualTo: 'active')
          .limit(limit)
          .snapshots()
          .map((snapshot) {
            final recommendations = snapshot.docs
                .map((doc) => UserRecommendation.fromFirestore(doc))
                .toList();
            
            // Trier localement par date
            recommendations.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            
            return recommendations;
          });
    } catch (e) {
      print('Erreur dans le stream des recommandations: $e');
      return Stream.value([]);
    }
  }

  /// Supprimer une recommandation
  static Future<bool> deleteRecommendation(String recommendationId) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(recommendationId)
          .update({'status': 'deleted'});
      return true;
    } catch (e) {
      print('Erreur lors de la suppression de la recommandation: $e');
      return false;
    }
  }

  /// Récupérer la dernière recommandation
  static Future<UserRecommendation?> getLatestRecommendation() async {
    try {
      final recommendations = await getUserRecommendations(limit: 1);
      return recommendations.isNotEmpty ? recommendations.first : null;
    } catch (e) {
      print('Erreur lors de la récupération de la dernière recommandation: $e');
      return null;
    }
  }
}
