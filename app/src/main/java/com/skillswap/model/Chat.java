package com.skillswap.model;

import com.google.firebase.firestore.Exclude;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/** Documento de la coleccion "chats". */
public class Chat implements Serializable {

    private String id = "";
    private String exchangeId = "";
    private List<String> participants = new ArrayList<>();
    private Map<String, String> names = new HashMap<>();
    private Map<String, String> photos = new HashMap<>();
    private Map<String, Long> unread = new HashMap<>();

    private String lastMessage = "";
    private String lastSenderId = "";
    private long lastMessageAt = 0L;
    private boolean enabled = true;
    private long createdAt = 0L;

    /**
     * Bloqueo entre los dos estudiantes. Mientras este activo nadie puede
     * escribir en el chat (lo impone la regla de seguridad, no solo la app) y
     * unicamente quien bloqueo puede levantarlo.
     */
    private boolean blocked = false;
    private String blockedBy = "";

    public Chat() {
    }

    @Exclude
    public String getPartnerId(String myUid) {
        for (String p : participants) {
            if (!p.equals(myUid)) return p;
        }
        return "";
    }

    @Exclude
    public String getPartnerName(String myUid) {
        String pid = getPartnerId(myUid);
        String n = names.get(pid);
        return n == null ? "Estudiante" : n;
    }

    @Exclude
    public String getPartnerPhoto(String myUid) {
        String pid = getPartnerId(myUid);
        String p = photos.get(pid);
        return p == null ? "" : p;
    }

    @Exclude
    public long getUnreadFor(String myUid) {
        Long v = unread.get(myUid);
        return v == null ? 0L : v;
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getExchangeId() { return exchangeId; }
    public void setExchangeId(String exchangeId) { this.exchangeId = exchangeId; }

    public List<String> getParticipants() { return participants; }
    public void setParticipants(List<String> participants) {
        this.participants = participants == null ? new ArrayList<String>() : participants;
    }

    public Map<String, String> getNames() { return names; }
    public void setNames(Map<String, String> names) {
        this.names = names == null ? new HashMap<String, String>() : names;
    }

    public Map<String, String> getPhotos() { return photos; }
    public void setPhotos(Map<String, String> photos) {
        this.photos = photos == null ? new HashMap<String, String>() : photos;
    }

    public Map<String, Long> getUnread() { return unread; }
    public void setUnread(Map<String, Long> unread) {
        this.unread = unread == null ? new HashMap<String, Long>() : unread;
    }

    public String getLastMessage() { return lastMessage; }
    public void setLastMessage(String lastMessage) { this.lastMessage = lastMessage; }

    public String getLastSenderId() { return lastSenderId; }
    public void setLastSenderId(String lastSenderId) { this.lastSenderId = lastSenderId; }

    public long getLastMessageAt() { return lastMessageAt; }
    public void setLastMessageAt(long lastMessageAt) { this.lastMessageAt = lastMessageAt; }

    public boolean isEnabled() { return enabled; }
    public void setEnabled(boolean enabled) { this.enabled = enabled; }

    public boolean isBlocked() { return blocked; }
    public void setBlocked(boolean blocked) { this.blocked = blocked; }

    public String getBlockedBy() { return blockedBy; }
    public void setBlockedBy(String blockedBy) { this.blockedBy = blockedBy == null ? "" : blockedBy; }

    /** true si el bloqueo lo puse yo (y por tanto soy quien puede levantarlo). */
    @Exclude
    public boolean isBlockedByMe(String myUid) {
        return blocked && myUid != null && myUid.equals(blockedBy);
    }

    public long getCreatedAt() { return createdAt; }
    public void setCreatedAt(long createdAt) { this.createdAt = createdAt; }
}
