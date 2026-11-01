#!/usr/bin/env bash
set -e
J="$(cd "$(dirname "$0")/.." && pwd)/app/src/main/java/com/skillswap"
V="$J/viewmodel"
mkdir -p "$V"

# ============================================================ RequestsViewModel
cat > "$V/RequestsViewModel.java" <<'EOF'
package com.skillswap.viewmodel;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import com.google.firebase.firestore.ListenerRegistration;
import com.skillswap.firebase.FirebaseManager;
import com.skillswap.model.Exchange;
import com.skillswap.model.ExchangeRequest;
import com.skillswap.model.Resource;
import com.skillswap.model.User;
import com.skillswap.repository.ExchangeRequestRepository;
import com.skillswap.repository.RepoCallback;
import com.skillswap.repository.UserRepository;

import java.util.ArrayList;
import java.util.List;

/** ViewModel de solicitudes recibidas / enviadas. */
public class RequestsViewModel extends ViewModel {

    private final ExchangeRequestRepository repository = ExchangeRequestRepository.get();

    private final MutableLiveData<List<ExchangeRequest>> received = new MutableLiveData<>(new ArrayList<>());
    private final MutableLiveData<List<ExchangeRequest>> sent = new MutableLiveData<>(new ArrayList<>());
    private final MutableLiveData<Resource<ExchangeRequest>> sendState = new MutableLiveData<>();
    private final MutableLiveData<Resource<Exchange>> acceptState = new MutableLiveData<>();
    private final MutableLiveData<Resource<Boolean>> actionState = new MutableLiveData<>();

    private ListenerRegistration receivedReg;
    private ListenerRegistration sentReg;

    public LiveData<List<ExchangeRequest>> received() {
        return received;
    }

    public LiveData<List<ExchangeRequest>> sent() {
        return sent;
    }

    public LiveData<Resource<ExchangeRequest>> sendState() {
        return sendState;
    }

    public LiveData<Resource<Exchange>> acceptState() {
        return acceptState;
    }

    public LiveData<Resource<Boolean>> actionState() {
        return actionState;
    }

    public void start() {
        String uid = FirebaseManager.uid();
        if (uid.isEmpty()) return;

        if (receivedReg == null) {
            receivedReg = repository.listenReceived(uid, new RepoCallback<List<ExchangeRequest>>() {
                @Override
                public void onSuccess(List<ExchangeRequest> data) {
                    received.postValue(data);
                }

                @Override
                public void onError(String message) {
                }
            });
        }
        if (sentReg == null) {
            sentReg = repository.listenSent(uid, new RepoCallback<List<ExchangeRequest>>() {
                @Override
                public void onSuccess(List<ExchangeRequest> data) {
                    sent.postValue(data);
                }

                @Override
                public void onError(String message) {
                }
            });
        }
    }

    public void sendRequest(User target, String skillWanted, String skillOffered,
                            String message, String modality, String schedule, int matchScore) {
        User me = UserRepository.get().currentUserValue();
        sendState.setValue(Resource.<ExchangeRequest>loading());
        repository.send(me, target, skillWanted, skillOffered, message, modality, schedule,
                matchScore, new RepoCallback<ExchangeRequest>() {
                    @Override
                    public void onSuccess(ExchangeRequest data) {
                        sendState.postValue(Resource.success(data));
                    }

                    @Override
                    public void onError(String msg) {
                        sendState.postValue(Resource.<ExchangeRequest>error(msg));
                    }
                });
    }

    public void accept(ExchangeRequest request) {
        acceptState.setValue(Resource.<Exchange>loading());
        repository.accept(request, new RepoCallback<Exchange>() {
            @Override
            public void onSuccess(Exchange data) {
                acceptState.postValue(Resource.success(data));
            }

            @Override
            public void onError(String message) {
                acceptState.postValue(Resource.<Exchange>error(message));
            }
        });
    }

    public void reject(ExchangeRequest request) {
        actionState.setValue(Resource.<Boolean>loading());
        repository.reject(request, wrap());
    }

    public void cancel(ExchangeRequest request) {
        actionState.setValue(Resource.<Boolean>loading());
        repository.cancel(request, wrap());
    }

    private RepoCallback<Boolean> wrap() {
        return new RepoCallback<Boolean>() {
            @Override
            public void onSuccess(Boolean data) {
                actionState.postValue(Resource.success(data));
            }

            @Override
            public void onError(String message) {
                actionState.postValue(Resource.<Boolean>error(message));
            }
        };
    }

    @Override
    protected void onCleared() {
        super.onCleared();
        if (receivedReg != null) receivedReg.remove();
        if (sentReg != null) sentReg.remove();
    }
}
EOF

# ============================================================ ExchangeViewModel
cat > "$V/ExchangeViewModel.java" <<'EOF'
package com.skillswap.viewmodel;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import com.google.firebase.firestore.ListenerRegistration;
import com.skillswap.firebase.FirebaseManager;
import com.skillswap.model.Exchange;
import com.skillswap.model.LearningContract;
import com.skillswap.model.Resource;
import com.skillswap.repository.ContractRepository;
import com.skillswap.repository.ExchangeRepository;
import com.skillswap.repository.RepoCallback;

import java.util.ArrayList;
import java.util.List;

/** ViewModel de "Mis intercambios" y del detalle de un intercambio. */
public class ExchangeViewModel extends ViewModel {

    private final ExchangeRepository repository = ExchangeRepository.get();

    private final MutableLiveData<List<Exchange>> all = new MutableLiveData<>(new ArrayList<>());
    private final MutableLiveData<Exchange> detail = new MutableLiveData<>();
    private final MutableLiveData<LearningContract> contract = new MutableLiveData<>();
    private final MutableLiveData<Resource<Exchange>> completeState = new MutableLiveData<>();
    private final MutableLiveData<Resource<Boolean>> actionState = new MutableLiveData<>();

    private ListenerRegistration listReg;
    private ListenerRegistration detailReg;
    private ListenerRegistration contractReg;

    public LiveData<List<Exchange>> all() {
        return all;
    }

    public LiveData<Exchange> detail() {
        return detail;
    }

    public LiveData<LearningContract> contract() {
        return contract;
    }

    public LiveData<Resource<Exchange>> completeState() {
        return completeState;
    }

    public LiveData<Resource<Boolean>> actionState() {
        return actionState;
    }

    public void start() {
        String uid = FirebaseManager.uid();
        if (uid.isEmpty() || listReg != null) return;
        listReg = repository.listenByUser(uid, new RepoCallback<List<Exchange>>() {
            @Override
            public void onSuccess(List<Exchange> data) {
                all.postValue(data);
            }

            @Override
            public void onError(String message) {
            }
        });
    }

    /** Filtra por estado: PROXIMO / EN_PROCESO / COMPLETADO. */
    public List<Exchange> filterByStatus(String status) {
        List<Exchange> out = new ArrayList<>();
        List<Exchange> source = all.getValue();
        if (source == null) return out;
        for (Exchange e : source) {
            if (status.equals(e.getStatus())) out.add(e);
        }
        return out;
    }

    public void observeDetail(String exchangeId) {
        if (detailReg != null) detailReg.remove();
        detailReg = repository.listenById(exchangeId, new RepoCallback<Exchange>() {
            @Override
            public void onSuccess(Exchange data) {
                detail.postValue(data);
            }

            @Override
            public void onError(String message) {
            }
        });

        if (contractReg != null) contractReg.remove();
        contractReg = ContractRepository.get().listen(exchangeId, new RepoCallback<LearningContract>() {
            @Override
            public void onSuccess(LearningContract data) {
                contract.postValue(data);
            }

            @Override
            public void onError(String message) {
            }
        });
    }

    public void markCompleted(Exchange exchange) {
        completeState.setValue(Resource.<Exchange>loading());
        repository.markCompleted(exchange, FirebaseManager.uid(), new RepoCallback<Exchange>() {
            @Override
            public void onSuccess(Exchange data) {
                completeState.postValue(Resource.success(data));
            }

            @Override
            public void onError(String message) {
                completeState.postValue(Resource.<Exchange>error(message));
            }
        });
    }

    public void updateProgress(Exchange exchange, int sessionsDone) {
        actionState.setValue(Resource.<Boolean>loading());
        repository.updateProgress(exchange, sessionsDone, new RepoCallback<Boolean>() {
            @Override
            public void onSuccess(Boolean data) {
                actionState.postValue(Resource.success(data));
            }

            @Override
            public void onError(String message) {
                actionState.postValue(Resource.<Boolean>error(message));
            }
        });
    }

    public void cancel(Exchange exchange) {
        actionState.setValue(Resource.<Boolean>loading());
        repository.cancel(exchange.getId(), new RepoCallback<Boolean>() {
            @Override
            public void onSuccess(Boolean data) {
                actionState.postValue(Resource.success(data));
            }

            @Override
            public void onError(String message) {
                actionState.postValue(Resource.<Boolean>error(message));
            }
        });
    }

    @Override
    protected void onCleared() {
        super.onCleared();
        if (listReg != null) listReg.remove();
        if (detailReg != null) detailReg.remove();
        if (contractReg != null) contractReg.remove();
    }
}
EOF

# ============================================================ ChatViewModel
cat > "$V/ChatViewModel.java" <<'EOF'
package com.skillswap.viewmodel;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import com.google.firebase.firestore.ListenerRegistration;
import com.skillswap.firebase.FirebaseManager;
import com.skillswap.model.Chat;
import com.skillswap.model.ChatMessage;
import com.skillswap.model.Resource;
import com.skillswap.model.User;
import com.skillswap.repository.ChatRepository;
import com.skillswap.repository.RepoCallback;
import com.skillswap.repository.UserRepository;

import java.util.ArrayList;
import java.util.List;

/** ViewModel de una conversacion. El chat exige un intercambio aceptado. */
public class ChatViewModel extends ViewModel {

    private final ChatRepository repository = ChatRepository.get();

    private final MutableLiveData<Chat> chat = new MutableLiveData<>();
    private final MutableLiveData<List<ChatMessage>> messages = new MutableLiveData<>(new ArrayList<>());
    private final MutableLiveData<Resource<Boolean>> sendState = new MutableLiveData<>();
    private final MutableLiveData<String> error = new MutableLiveData<>();

    private ListenerRegistration messagesReg;
    private ListenerRegistration chatReg;

    public LiveData<Chat> chat() {
        return chat;
    }

    public LiveData<List<ChatMessage>> messages() {
        return messages;
    }

    public LiveData<Resource<Boolean>> sendState() {
        return sendState;
    }

    public LiveData<String> error() {
        return error;
    }

    public void open(final String chatId) {
        repository.fetchChat(chatId, new RepoCallback<Chat>() {
            @Override
            public void onSuccess(Chat data) {
                chat.postValue(data);
                repository.markRead(chatId, FirebaseManager.uid());
                listen(chatId);
            }

            @Override
            public void onError(String message) {
                error.postValue(message);
            }
        });
    }

    private void listen(String chatId) {
        if (messagesReg != null) messagesReg.remove();
        messagesReg = repository.listenMessages(chatId, new RepoCallback<List<ChatMessage>>() {
            @Override
            public void onSuccess(List<ChatMessage> data) {
                messages.postValue(data);
            }

            @Override
            public void onError(String message) {
                error.postValue(message);
            }
        });

        if (chatReg != null) chatReg.remove();
        chatReg = repository.listenChat(chatId, new RepoCallback<Chat>() {
            @Override
            public void onSuccess(Chat data) {
                chat.postValue(data);
            }

            @Override
            public void onError(String message) {
            }
        });
    }

    public void send(String text) {
        Chat current = chat.getValue();
        User me = UserRepository.get().currentUserValue();
        if (current == null) {
            error.setValue("La conversación aún no está lista");
            return;
        }
        String name = me == null ? "Estudiante" : me.getFullName();
        String photo = me == null ? "" : me.getPhotoUrl();

        sendState.setValue(Resource.<Boolean>loading());
        repository.sendMessage(current, FirebaseManager.uid(), name, photo, text,
                new RepoCallback<Boolean>() {
                    @Override
                    public void onSuccess(Boolean data) {
                        sendState.postValue(Resource.success(data));
                    }

                    @Override
                    public void onError(String message) {
                        sendState.postValue(Resource.<Boolean>error(message));
                    }
                });
    }

    public void markRead() {
        Chat current = chat.getValue();
        if (current != null) repository.markRead(current.getId(), FirebaseManager.uid());
    }

    @Override
    protected void onCleared() {
        super.onCleared();
        if (messagesReg != null) messagesReg.remove();
        if (chatReg != null) chatReg.remove();
    }
}
EOF

# ============================================================ ChatListViewModel
cat > "$V/ChatListViewModel.java" <<'EOF'
package com.skillswap.viewmodel;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import com.google.firebase.firestore.ListenerRegistration;
import com.skillswap.firebase.FirebaseManager;
import com.skillswap.model.Chat;
import com.skillswap.repository.ChatRepository;
import com.skillswap.repository.RepoCallback;

import java.util.ArrayList;
import java.util.List;

/** ViewModel de la lista de conversaciones. */
public class ChatListViewModel extends ViewModel {

    private final MutableLiveData<List<Chat>> chats = new MutableLiveData<>(new ArrayList<>());
    private final MutableLiveData<Boolean> loading = new MutableLiveData<>(true);
    private ListenerRegistration reg;

    public LiveData<List<Chat>> chats() {
        return chats;
    }

    public LiveData<Boolean> loading() {
        return loading;
    }

    public void start() {
        String uid = FirebaseManager.uid();
        if (uid.isEmpty() || reg != null) return;
        reg = ChatRepository.get().listenChats(uid, new RepoCallback<List<Chat>>() {
            @Override
            public void onSuccess(List<Chat> data) {
                chats.postValue(data);
                loading.postValue(false);
            }

            @Override
            public void onError(String message) {
                loading.postValue(false);
            }
        });
    }

    @Override
    protected void onCleared() {
        super.onCleared();
        if (reg != null) reg.remove();
    }
}
EOF

echo "ViewModels (solicitudes/intercambios/chat) generados."
