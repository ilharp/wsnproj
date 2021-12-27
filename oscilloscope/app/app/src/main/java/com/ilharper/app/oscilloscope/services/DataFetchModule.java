package com.ilharper.app.oscilloscope.services;

import dagger.Module;
import dagger.Provides;
import dagger.hilt.InstallIn;
import dagger.hilt.components.SingletonComponent;

import javax.inject.Singleton;

@InstallIn(SingletonComponent.class)
@Module
public class DataFetchModule {
    @Provides
    @Singleton
    public VolleyRequest provideVolleyRequest() {
        return new VolleyRequest();
    }

    @Provides
    @Singleton
    public DataFetchService provideDataFetch() {
        return new DataFetchService();
    }
}
