package com.ilharper.app.oscilloscope.services;

import io.reactivex.rxjava3.core.Observable;

import javax.inject.Inject;
import java.util.concurrent.TimeUnit;

public class DataFetchService {
    @Inject
    public DataFetchService() {
    }

    private static final String Endpoint = "https://oscilloscope.ilharper.com/get-data";

    @Inject
    public VolleyRequest volleyRequest;
}
