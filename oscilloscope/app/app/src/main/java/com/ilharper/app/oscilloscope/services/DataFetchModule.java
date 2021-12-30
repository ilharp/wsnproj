package com.ilharper.app.oscilloscope.services;

import android.content.Context;
import dagger.Module;
import dagger.Provides;
import dagger.hilt.InstallIn;
import dagger.hilt.android.components.ActivityComponent;
import dagger.hilt.android.qualifiers.ActivityContext;

@InstallIn(ActivityComponent.class)
@Module
public class DataFetchModule {
    @Provides
    public VolleyRequest provideVolleyRequest(@ActivityContext Context context) {
        return new VolleyRequest(context);
    }

    @Provides
    public DataFetchService provideDataFetch(VolleyRequest volleyRequest) {
        return new DataFetchService(volleyRequest);
    }
}
