package com.ilharper.app.oscilloscope.services;

import androidx.annotation.Nullable;
import com.android.volley.AuthFailureError;
import com.android.volley.Response;
import com.android.volley.toolbox.StringRequest;

import java.util.Map;

public class GetStringRequest extends StringRequest {
    private final Map<String, String> headers;

    public GetStringRequest(
        String url,
        Map<String, String> headers,
        Response.Listener<String> listener,
        @Nullable Response.ErrorListener errorListener) {
        super(url, listener, errorListener);
        this.headers = headers;
    }

    @Nullable
    @Override
    public Map<String, String> getHeaders() throws AuthFailureError {
        return headers;
    }
}
