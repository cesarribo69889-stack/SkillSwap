package com.skillswap.firebase;

import com.google.firebase.firestore.CollectionReference;
import com.google.firebase.firestore.DocumentReference;
import com.skillswap.utils.Constants;

/** Referencias tipadas a las colecciones de Cloud Firestore. */
public final class FirestoreCollections {

    private FirestoreCollections() {
    }

    public static CollectionReference users() {
        return FirebaseManager.db().collection(Constants.COL_USERS);
    }

    public static DocumentReference user(String uid) {
        return users().document(uid);
    }

    public static CollectionReference skills() {
        return FirebaseManager.db().collection(Constants.COL_SKILLS);
    }

    public static CollectionReference matches() {
        return FirebaseManager.db().collection(Constants.COL_MATCHES);
    }

    public static CollectionReference requests() {
        return FirebaseManager.db().collection(Constants.COL_EXCHANGE_REQUESTS);
    }

    public static CollectionReference exchanges() {
        return FirebaseManager.db().collection(Constants.COL_EXCHANGES);
    }

    public static CollectionReference chats() {
        return FirebaseManager.db().collection(Constants.COL_CHATS);
    }

    public static CollectionReference messages(String chatId) {
        return chats().document(chatId).collection(Constants.COL_MESSAGES);
    }

    public static CollectionReference ratings() {
        return FirebaseManager.db().collection(Constants.COL_RATINGS);
    }

    public static CollectionReference notifications() {
        return FirebaseManager.db().collection(Constants.COL_NOTIFICATIONS);
    }

    public static CollectionReference passport() {
        return FirebaseManager.db().collection(Constants.COL_PASSPORT);
    }

    public static CollectionReference contracts() {
        return FirebaseManager.db().collection(Constants.COL_CONTRACTS);
    }

    public static CollectionReference skillPoints() {
        return FirebaseManager.db().collection(Constants.COL_SKILLPOINTS);
    }

    public static CollectionReference pointsHistory(String uid) {
        return skillPoints().document(uid).collection(Constants.COL_POINTS_HISTORY);
    }

    public static CollectionReference badges() {
        return FirebaseManager.db().collection(Constants.COL_BADGES);
    }

    public static CollectionReference challenges() {
        return FirebaseManager.db().collection(Constants.COL_CHALLENGES);
    }

    public static CollectionReference challengeParticipants() {
        return FirebaseManager.db().collection(Constants.COL_CHALLENGE_PARTICIPANTS);
    }

    public static CollectionReference evidence() {
        return FirebaseManager.db().collection(Constants.COL_EVIDENCE);
    }
}
