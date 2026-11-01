package com.skillswap.repository;

import com.google.firebase.firestore.DocumentReference;
import com.skillswap.firebase.FirestoreCollections;
import com.skillswap.model.ExploreFilter;
import com.skillswap.model.MatchResult;
import com.skillswap.model.User;
import com.skillswap.model.UserSkill;
import com.skillswap.utils.SkillCatalog;
import com.skillswap.utils.SkillMatchEngine;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

/**
 * INNOVACION 1 - SkillMatch.
 * Recupera candidatos y los ordena con el motor de compatibilidad.
 */
public class MatchRepository {

    private static MatchRepository instance;

    public static synchronized MatchRepository get() {
        if (instance == null) instance = new MatchRepository();
        return instance;
    }

    private MatchRepository() {
    }

    /** Calcula todos los matches del usuario actual. */
    public void findMatches(final User me, final RepoCallback<List<MatchResult>> callback) {
        if (me == null) {
            callback.onError("Perfil no disponible");
            return;
        }
        UserRepository.get().fetchCandidates(me.getUid(), new RepoCallback<List<User>>() {
            @Override
            public void onSuccess(List<User> data) {
                callback.onSuccess(SkillMatchEngine.rank(me, data));
            }

            @Override
            public void onError(String message) {
                callback.onError(message);
            }
        });
    }

    /** Explorar: matches + filtros + busqueda de texto. */
    public void explore(final User me, final ExploreFilter filter,
                        final RepoCallback<List<MatchResult>> callback) {
        findMatches(me, new RepoCallback<List<MatchResult>>() {
            @Override
            public void onSuccess(List<MatchResult> data) {
                callback.onSuccess(applyFilters(data, filter));
            }

            @Override
            public void onError(String message) {
                callback.onError(message);
            }
        });
    }

    /** Guarda el match en la coleccion "matches" para poder notificarlo. */
    public void saveMatch(MatchResult match) {
        if (match == null || match.getScore() < SkillMatchEngine.MATCH_THRESHOLD) return;
        String id = buildMatchId(match.getUserAId(), match.getUserBId());
        DocumentReference ref = FirestoreCollections.matches().document(id);
        match.setId(id);
        ref.set(match);
    }

    public static String buildMatchId(String a, String b) {
        if (a == null) a = "";
        if (b == null) b = "";
        return a.compareTo(b) <= 0 ? a + "_" + b : b + "_" + a;
    }

    // ------------------------------------------------------------- filtros

    public static List<MatchResult> applyFilters(List<MatchResult> input, ExploreFilter f) {
        List<MatchResult> out = new ArrayList<>();
        if (input == null) return out;
        if (f == null) return new ArrayList<>(input);

        for (MatchResult m : input) {
            User u = m.getUser();
            if (u == null) continue;

            if (!isBlank(f.getQuery()) && !matchesQuery(u, f.getQuery())) continue;
            if (!isBlank(f.getSkill()) && !teachesSkill(u, f.getSkill())) continue;
            if (!isBlank(f.getCategory()) && !hasCategory(u, f.getCategory())) continue;
            if (!isBlank(f.getLevel()) && !hasLevel(u, f.getLevel())) continue;
            if (!isBlank(f.getModality())
                    && !SkillMatchEngine.modalityCompatible(f.getModality(), u.getModality())) continue;
            if (!isBlank(f.getUniversity())
                    && (u.getUniversity() == null
                    || !u.getUniversity().toLowerCase(Locale.ROOT)
                    .contains(f.getUniversity().toLowerCase(Locale.ROOT)))) continue;
            if (m.getScore() < f.getMinCompatibility()) continue;

            out.add(m);
        }
        return out;
    }

    private static boolean matchesQuery(User u, String query) {
        String q = query.toLowerCase(Locale.ROOT).trim();
        if (contains(u.getFullName(), q)) return true;
        if (contains(u.getCareer(), q)) return true;
        if (contains(u.getUniversity(), q)) return true;
        for (UserSkill s : u.getTeachSkills()) {
            if (contains(s.getName(), q)) return true;
        }
        for (UserSkill s : u.getLearnSkills()) {
            if (contains(s.getName(), q)) return true;
        }
        return false;
    }

    private static boolean teachesSkill(User u, String skill) {
        String key = skill.toLowerCase(Locale.ROOT).trim();
        for (UserSkill s : u.getTeachSkills()) {
            if (s.getKey().equals(key)) return true;
        }
        return false;
    }

    private static boolean hasCategory(User u, String category) {
        for (UserSkill s : u.getTeachSkills()) {
            String cat = isBlank(s.getCategory()) ? SkillCatalog.categoryOf(s.getName()) : s.getCategory();
            if (category.equals(cat)) return true;
        }
        return false;
    }

    private static boolean hasLevel(User u, String level) {
        for (UserSkill s : u.getTeachSkills()) {
            if (level.equals(s.getLevel())) return true;
        }
        return false;
    }

    private static boolean contains(String value, String query) {
        return value != null && value.toLowerCase(Locale.ROOT).contains(query);
    }

    private static boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }
}
