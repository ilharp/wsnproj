package com.ilharper.app.oscilloscope;

import android.os.Bundle;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ListView;
import android.widget.TextView;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.viewpager.widget.PagerAdapter;
import com.ilharper.app.oscilloscope.databinding.ActivityMainBinding;
import com.ilharper.app.oscilloscope.services.DataFetchService;
import dagger.hilt.android.AndroidEntryPoint;
import io.reactivex.rxjava3.annotations.NonNull;
import io.reactivex.rxjava3.core.Observer;
import io.reactivex.rxjava3.disposables.Disposable;
import org.jetbrains.annotations.NotNull;

import javax.inject.Inject;
import java.util.ArrayList;
import java.util.Collections;

@AndroidEntryPoint
public class MainActivity extends AppCompatActivity {

    @Inject
    public DataFetchService fetchService;

    private Disposable subscribe;

    private ActivityMainBinding binding;

    private ArrayList<String> rawDispData = new ArrayList<>();
    private ArrayAdapter<String> rawAdapter;
    private TextView mainData;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        // setContentView(R.layout.activity_main);
        binding = ActivityMainBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        ArrayList<View> views = new ArrayList<>();
        views.add(getLayoutInflater().inflate(R.layout.page_main, null));
        views.add(getLayoutInflater().inflate(R.layout.page_raw, null));
        PagerAdapter adapter = new PagerAdapter() {
            @Override
            public int getCount() {
                return views.size();
            }

            @Override
            public boolean isViewFromObject(@androidx.annotation.NonNull @NotNull View view, @androidx.annotation.NonNull @NotNull Object object) {
                return view == object;
            }

            @Override
            public void destroyItem(@androidx.annotation.NonNull @NotNull ViewGroup container, int position, @androidx.annotation.NonNull @NotNull Object object) {
                container.removeView(views.get(position));
            }

            @androidx.annotation.NonNull
            @NotNull
            @Override
            public Object instantiateItem(@androidx.annotation.NonNull @NotNull ViewGroup container, int position) {
                container.addView(views.get(position));
                return views.get(position);
            }

            @Nullable
            @org.jetbrains.annotations.Nullable
            @Override
            public CharSequence getPageTitle(int position) {
                switch (position) {
                    case 0:
                        return "概览";
                    case 1:
                        return "原始数据";
                    default:
                        return "";
                }
            }
        };

        binding.rootViewPager.setAdapter(adapter);
        binding.rootTabView.setupWithViewPager(binding.rootViewPager);

        rawAdapter = new ArrayAdapter<>(this, android.R.layout.simple_list_item_1, rawDispData);

        ListView rawListView = (ListView) views.get(1).findViewById(R.id.rawListView);
        rawListView.setAdapter(rawAdapter);

        mainData = views.get(0).findViewById(R.id.mainData);
    }

    @Override
    protected void onResume() {
        super.onResume();
        fetchService.Data.subscribe(new Observer<String>() {
            @Override
            public void onSubscribe(@NonNull Disposable d) {

            }

            @Override
            public void onNext(@NonNull String s) {
                String md = "";
                rawDispData.clear();
                for (String line :
                    s.split("\n")) {
                    line = line.trim();
                    String[] idSpl = line.split("ID");
                    String[] dtSpl = idSpl[1].split("DT");
                    String nonce = idSpl[0];
                    String id = dtSpl[0];
                    String[] sps = dtSpl[1].split("SP");
                    double total = 0;
                    for (String sp : sps) {
                        total += Integer.parseInt(sp);
                    }
                    total /= 10000;
                    rawDispData.add(String.format("序号：%s 节点ID：%s 平均电压：%sV", nonce, id, String.valueOf(total)));
                    md = String.format("序号：%s%n节点ID：%s%n平均电压：%sV", nonce, id, String.valueOf(total));
                }
                Collections.reverse(rawDispData);
                rawAdapter.notifyDataSetChanged();

                mainData.setText(md);
            }

            @Override
            public void onError(@NonNull Throwable e) {
                e.printStackTrace();
            }

            @Override
            public void onComplete() {

            }
        });
    }

    @Override
    protected void onPause() {
        super.onPause();
        if (subscribe != null && !subscribe.isDisposed()) subscribe.dispose();
    }
}
