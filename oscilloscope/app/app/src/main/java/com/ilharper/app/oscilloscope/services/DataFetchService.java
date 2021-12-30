package com.ilharper.app.oscilloscope.services;

import io.reactivex.rxjava3.android.schedulers.AndroidSchedulers;
import io.reactivex.rxjava3.core.Observable;
import io.reactivex.rxjava3.schedulers.Schedulers;

import javax.inject.Inject;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;
import java.util.concurrent.TimeUnit;

public class DataFetchService {
    private static final String Endpoint = "https://oscilloscope.ilharper.com/get-data";
    private final Map<String, String> headers;
    public VolleyRequest volleyRequest;
    public Observable<String> Data;

    @Inject
    public DataFetchService(VolleyRequest volleyRequest) {
        this.volleyRequest = volleyRequest;
        headers = new HashMap<>();
        headers.put("Authorization", "There's no authorization");
        Data = Observable.interval(8, TimeUnit.SECONDS)
            .flatMap(((x) -> {
                return volleyRequest.getRequestObservable(Endpoint, headers);
            }))
            .filter(Objects::nonNull)
            .subscribeOn(Schedulers.io())
            .observeOn(AndroidSchedulers.mainThread())
        ;
    }
}
