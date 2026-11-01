package com.skillswap.repository;

/** Callback generico usado por los repositorios. */
public interface RepoCallback<T> {

    void onSuccess(T data);

    void onError(String message);
}
