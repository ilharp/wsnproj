package com.ilharper.app.oscilloscope.services;

import android.content.Context;
import com.android.volley.RequestQueue;
import com.android.volley.toolbox.RequestFuture;
import com.android.volley.toolbox.StringRequest;
import com.android.volley.toolbox.Volley;
import dagger.hilt.android.qualifiers.ActivityContext;
import io.reactivex.rxjava3.annotations.NonNull;
import io.reactivex.rxjava3.core.Observable;
import io.reactivex.rxjava3.core.ObservableEmitter;
import io.reactivex.rxjava3.core.ObservableOnSubscribe;

import javax.inject.Inject;
import java.util.Map;
import java.util.Objects;

public class VolleyRequest {
    private final RequestQueue requestQueue;

    @Inject
    public VolleyRequest(@ActivityContext Context context) {
        requestQueue = Volley.newRequestQueue(context);
    }

    private String getRequest(String url, Map<String, String> headers) {
        RequestFuture<String> future = RequestFuture.newFuture();
        StringRequest request = new GetStringRequest(url, headers, future, future);
        requestQueue.add(request);
        try {
            return future.get();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    public Observable<String> getRequestObservable(String url, Map<String, String> headers) {
        return Observable.create(new ObservableOnSubscribe<String>() {
            @Override
            public void subscribe(@NonNull ObservableEmitter<String> emitter) throws Throwable {
                emitter.onNext(Objects.requireNonNull(getRequest(url, headers)));
            }
        });
    }
}
