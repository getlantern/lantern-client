package org.getlantern.lantern.model;

import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.google.gson.reflect.TypeToken;

import org.getlantern.lantern.LanternApp;
import org.getlantern.lantern.util.Json;
import org.getlantern.mobilesdk.Logger;
import org.getlantern.mobilesdk.util.HttpClient;

import java.io.IOException;
import java.lang.reflect.Type;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import okhttp3.CacheControl;
import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.FormBody;
import okhttp3.Headers;
import okhttp3.HttpUrl;
import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;
import okhttp3.ResponseBody;
import okio.Buffer;

/**
 * An OkHttp-based HTTP client.
 */
public class LanternHttpClient extends HttpClient {
    private static final String TAG = LanternHttpClient.class.getName();

    // the standard user headers sent with most Pro requests
    private static final String DEVICE_ID_HEADER = "X-Lantern-Device-Id";
    private static final String USER_ID_HEADER = "X-Lantern-User-Id";
    private static final String PRO_TOKEN_HEADER = "X-Lantern-Pro-Token";
    private static final String APP_VERSION_HEADER = "X-Lantern-Version";
    private static final String PLATFORM_HEADER = "X-Lantern-Platform";

    private static final MediaType JSON
            = MediaType.parse("application/json; charset=utf-8");

    /**
     * Creates a new HTTP client
     */
    public LanternHttpClient() {
        super();
    }

    /**
     * Creates a new HTTP client
     *
     * @param httpClient The HTTP client to use.
     */
    public LanternHttpClient(final OkHttpClient httpClient) {
        super(httpClient);
    }

    public static HttpUrl createProUrl(final String uri) {
        return createProUrl(uri, null);
    }

    /**
     * Constructs a url for a request to the pro server
     *
     * @param uri    the requested resource
     * @param params any query params to include with the url
     * @return a URL
     */
    public static HttpUrl createProUrl(final String uri, final Map<String, String> params) {
        final String url = String.format("http://localhost/pro%s", uri);
        HttpUrl.Builder builder = HttpUrl.parse(url).newBuilder();
        if (params != null) {
            for (Map.Entry<String, String> param : params.entrySet()) {
                builder.addQueryParameter(param.getKey(), param.getValue());
            }
        }
        return builder.build();
    }

    /**
     * The HTTP headers expected with Pro requests for a user
     */
    private Map<String, String> userHeaders() {
        final Map<String, String> headers = new HashMap<String, String>();
        headers.put(DEVICE_ID_HEADER, LanternApp.getSession().getDeviceID());
        headers.put(PRO_TOKEN_HEADER, LanternApp.getSession().getToken());
        headers.put(USER_ID_HEADER, String.valueOf(LanternApp.getSession().getUserID()));
        headers.put(PLATFORM_HEADER, "android");
        headers.put(APP_VERSION_HEADER, Utils.appVersion(LanternApp.getAppContext()));
        headers.putAll(LanternApp.getSession().getInternalHeaders());
        return headers;
    }

    public void request(@NonNull final String method, @NonNull final HttpUrl url,
                        final HttpCallback cb) {
        request(method, url, null, null, cb);
    }

    public void request(@NonNull final String method, @NonNull final HttpUrl url,
                        final ProCallback cb) {
        proRequest(method, url, null, null, cb);
    }

    public void request(@NonNull final String method, @NonNull final HttpUrl url,
                        final boolean addProHeaders,
                        RequestBody body, final HttpCallback cb) {
        if (addProHeaders) {
            request(method, url, userHeaders(), body, cb);
        } else {
            request(method, url, null, body, cb);
        }
    }

    public void request(@NonNull final String method, @NonNull final HttpUrl url,
                        RequestBody body, final ProCallback cb) {
        proRequest(method, url, userHeaders(), body, cb);
    }

    /**
     * GET request.
     *
     * @param url request URL
     * @param cb  for notifying the caller of an HTTP response or failure
     */
    public void get(@NonNull final HttpUrl url, final ProCallback cb) {
        proRequest("GET", url, userHeaders(), null, cb);
    }

    /**
     * POST request.
     *
     * @param url  request URL
     * @param body the data enclosed with the HTTP message
     * @param cb   the callback responded with an HTTP response or failure
     */
    public void post(@NonNull final HttpUrl url,
                     final RequestBody body, @NonNull final ProCallback cb) {
        proRequest("POST", url, userHeaders(), body, cb);
    }

    private void processPlans(List<ProPlan> fetched, final PlansCallback cb, InAppBilling inAppBilling) {
        Map<String, ProPlan> plans = new HashMap<String, ProPlan>();
        Logger.debug(TAG, "Pro plans: " + fetched);
        for (ProPlan plan : fetched) {
            if (plan != null) {
                plan.formatCost();
                Logger.debug(TAG, "New plan is " + plan);
                plans.put(plan.getId(), plan);
            }
        }
        if (inAppBilling != null) {
            // this means we're in the play store, use the configured plans from there but with the
            // renewal bonus from the server side plans
            Map<String, ProPlan> regularPlans = new HashMap<>();
            for (Map.Entry<String, ProPlan> entry : plans.entrySet()) {
                // Plans from the pro server have a version suffix, like '1y-usd-9' but plans from
                // the Play Store don't, like '1y-usd'. So we normalize by dropping the version
                // suffix.
                regularPlans.put(entry.getKey().substring(0, entry.getKey().lastIndexOf("-")), entry.getValue());
            }
            plans = inAppBilling.getPlans();
            for (Map.Entry<String, ProPlan> entry : plans.entrySet()) {
                ProPlan regularPlan = regularPlans.get(entry.getKey());
                if (regularPlan != null) {
                    entry.getValue().updateRenewalBonusExpected(regularPlan.getRenewalBonusExpected());
                }
            }
        }
        cb.onSuccess(plans);
    }

    private void processPlansV1(final JsonObject result, final PlansCallback cb, InAppBilling inAppBilling) {
        String stripePubKey = result.get("providers").getAsJsonObject().get("stripe").getAsJsonObject().get("pubKey").getAsString();
        LanternApp.getSession().setStripePubKey(stripePubKey);
        Type listType = new TypeToken<List<ProPlan>>() {
        }.getType();
        Logger.debug(TAG, "Plans: " + result.get("plans"));
        final List<ProPlan> fetched = Json.gson.fromJson(result.get("plans"), listType);
        processPlans(fetched, cb, inAppBilling);
    }

    private void processPlansV3(final JsonObject result, final PlansV3Callback cb, InAppBilling inAppBilling) {
        Type mapType = new TypeToken<Map<String, List<PaymentMethods>>>() {
        }.getType();
        Map<String, List<PaymentMethods>> response = Json.gson.fromJson(result.get("providers"), mapType);
        List<PaymentMethods> providers = response.get("android");
        Type listType = new TypeToken<List<ProPlan>>() {
        }.getType();
        final List<ProPlan> fetched = Json.gson.fromJson(result.get("plans"), listType);
        Logger.debug(TAG, "Payment providers: " + providers);
        Map<String, ProPlan> plans = new HashMap<String, ProPlan>();
        for (ProPlan plan : fetched) {
            if (plan != null) {
                plan.formatCost();
                plans.put(plan.getId(), plan);
            }
        }
        cb.onSuccess(plans, providers);
    }

    public void prepareYuansfer(final String vendor, final YuansferCallback cb) {
        final HttpUrl url = createProUrl("/yuansfer-prepay");
        final RequestBody formBody = new FormBody.Builder()
                .add("plan", LanternApp.getSession().getSelectedPlan().getId())
                .add("email", LanternApp.getSession().email())
                .add("deviceName", LanternApp.getSession().deviceName())
                .add("paymentVendor", vendor)
                .build();

        post(url, formBody,
                new LanternHttpClient.ProCallback() {
                    @Override
                    public void onFailure(final Throwable throwable, final ProError error) {
                        if (cb != null) {
                            cb.onFailure(throwable, error);
                        }
                    }

                    @Override
                    public void onSuccess(final Response response, final JsonObject result) {
                        if (result.get("error") != null) {
                            onFailure(null, new ProError(result));
                        } else if (cb != null) {
                            cb.onSuccess(((JsonObject) result.get("alipay")).get("payInfo").getAsString());
                        }
                    }
                });
    }

    public void sendLinkRequest(final ProCallback cb) {
        final HttpUrl url = createProUrl("/user-link-request");
        final RequestBody formBody = new FormBody.Builder()
                .add("email", LanternApp.getSession().email())
                .add("deviceName", LanternApp.getSession().deviceName())
                .build();

        post(url, formBody,
                new LanternHttpClient.ProCallback() {
                    @Override
                    public void onFailure(final Throwable throwable, final ProError error) {
                        if (cb != null) {
                            cb.onFailure(throwable, error);
                        }
                    }

                    @Override
                    public void onSuccess(final Response response, final JsonObject result) {
                        if (result.get("error") != null) {
                            onFailure(null, new ProError(result));
                        } else if (cb != null) {
                            cb.onSuccess(response, result);
                        }
                    }
                });
    }

    /**
     * Returns all user data, including payments, referrals, and all available
     * fields.
     *
     * @param cb for notifying the caller of an HTTP response or failure
     */
    public void userData(final ProUserCallback cb) {
        final Map<String, String> params = new HashMap<String, String>();
        params.put("locale", LanternApp.getSession().getLanguage());
        final HttpUrl url = createProUrl("/user-data", params);
        get(url, new ProCallback() {
            @Override
            public void onFailure(final Throwable throwable, final ProError error) {
                Logger.error(TAG, "Unable to fetch user data", throwable);
                if (cb != null) {
                    cb.onFailure(throwable, error);
                }
            }

            @Override
            public void onSuccess(final Response response, final JsonObject result) {
                try {
                    Logger.debug(TAG, "JSON response" + result.toString());
                    final ProUser user = Json.gson.fromJson(result, ProUser.class);
                    if (user != null) {
                        Logger.debug(TAG, "User ID is " + user.getUserId());
                        LanternApp.getSession().storeUserData(user);
                    }
                    if (cb != null) {
                        cb.onSuccess(response, user);
                    }
                } catch (Exception e) {
                    Logger.error(TAG, "Unable to fetch user data: " + e.getMessage(), e);
                }
            }
        });
    }

    public void plans(final PlansCallback cb, InAppBilling inAppBilling) {
        final Map<String, String> params = new HashMap<String, String>();
        params.put("locale", LanternApp.getSession().getLanguage());
        params.put("countrycode", LanternApp.getSession().getCountryCode());
        final HttpUrl url = createProUrl("/plans", params);
        final Map<String, ProPlan> plans = new HashMap<String, ProPlan>();
        get(url, new ProCallback() {
            @Override
            public void onFailure(final Throwable throwable, final ProError error) {
                Logger.error(TAG, "Unable to fetch plans", throwable);
                cb.onFailure(throwable, error);
            }

            @Override
            public void onSuccess(final Response response, final JsonObject result) {
                try {
                    Logger.debug(TAG, "JSON response for " + url + ":" + result.toString());
                    processPlansV1(result, cb, inAppBilling);
                } catch (Exception e) {
                    Logger.error(TAG, "Unable to fetch plans: " + e.getMessage(), e);
                }
            }
        });
    }

    public void plansV3(final PlansV3Callback cb, InAppBilling inAppBilling) {
        final Map<String, String> params = new HashMap<String, String>();
        params.put("locale", LanternApp.getSession().getLanguage());
        params.put("countrycode", LanternApp.getSession().getCountryCode());
        final HttpUrl url = createProUrl("/plans-v3", params);
        final Map<String, ProPlan> plans = new HashMap<String, ProPlan>();
        get(url, new ProCallback() {
            @Override
            public void onFailure(final Throwable throwable, final ProError error) {
                Logger.error(TAG, "Unable to fetch plans", throwable);
                cb.onFailure(throwable, error);
            }

            @Override
            public void onSuccess(final Response response, final JsonObject result) {
                try {
                    Logger.debug(TAG, "JSON response for " + url + ":" + result.toString());
                    processPlansV3(result, cb, inAppBilling);
                } catch (Exception e) {
                    Logger.error(TAG, "Unable to fetch plans: " + e.getMessage(), e);
                }
            }
        });
    }


    public void plansV3(final PlansCallback cb, InAppBilling inAppBilling) {
        plansV3(cb, inAppBilling);
    }

    public void getPlans(final PlansCallback cb, InAppBilling inAppBilling) {
        plans(cb, inAppBilling);
    }

    /**
     * Convert a JsonObject json into a RequestBody that transmits content
     *
     * @param json the JsonObject to be converted
     */
    public static RequestBody createJsonBody(final JsonObject json) {
        return RequestBody.create(JSON, json.toString());
    }

    public void request(@NonNull final String method, @NonNull final HttpUrl url,
                        final Map<String, String> headers,
                        RequestBody body, final HttpCallback cb) {
        Request.Builder builder = new Request.Builder()
                .cacheControl(CacheControl.FORCE_NETWORK);
        if (headers != null) {
            builder = builder.headers(Headers.of(headers));
        }
        builder = builder.url(url);

        if (method != null && method.equals("POST")) {
            if (body == null) {
                body = RequestBody.create(null, new byte[0]);
            }
            builder = builder.post(body);
        }
        final Request request = builder.build();
        httpClient.newCall(request).enqueue(new Callback() {
            @Override
            public void onFailure(Call call, IOException e) {
                if (cb != null)
                    cb.onFailure(e);
            }

            @Override
            public void onResponse(Call call, Response response) throws IOException {
                if (!response.isSuccessful()) {
                    Logger.error(TAG, "Request to " + url + " failed");
                    Logger.error(TAG, "Response: " + response);
                    final ResponseBody body = response.body();
                    if (body != null) {
                        Logger.error(TAG, "Body: " + body.string());
                    }
                    cb.onFailure(null);
                    return;
                }
                cb.onSuccess(response);
            }
        });
    }

    /**
     * Creates a new HTTP request to be enqueued for later execution
     *
     * @param method  the HTTP method
     * @param url     the URL target of this request
     * @param headers the HTTP header fields to add to the request
     * @param body    the body of a POST request
     * @param cb      to notify the caller of an HTTP response or failure
     */
    private void proRequest(@NonNull final String method, @NonNull final HttpUrl url,
                            final Map<String, String> headers,
                            RequestBody body, final ProCallback cb) {
        Request.Builder builder = new Request.Builder()
                .cacheControl(CacheControl.FORCE_NETWORK);
        if (headers != null) {
            builder = builder.headers(Headers.of(headers));
        }
        builder = builder.url(url);

        if (method != null && method.equals("POST")) {
            if (body == null) {
                body = RequestBody.create(null, new byte[0]);
            }
            builder = builder.post(body);
        }
        final Request request = builder.build();
        httpClient.newCall(request).enqueue(new Callback() {
            @Override
            public void onFailure(Call call, IOException e) {
                if (e != null) {
                    final ProError error = new ProError("", e.getMessage());
                    cb.onFailure(e, error);
                }
            }

            @Override
            public void onResponse(Call call, Response response) throws IOException {
                if (!response.isSuccessful()) {
                    Logger.error(TAG, "Request to " + url + " failed");
                    Logger.error(TAG, "Response: " + response);
                    final ResponseBody body = response.body();
                    if (body != null) {
                        Logger.error(TAG, "Body: " + body.string());
                    }
                    final ProError error = new ProError("", "Unexpected response code from server");
                    cb.onFailure(null, error);
                    return;
                }
                final String responseData = response.body().string();
                JsonObject result;
                if (responseData == null) {
                    Logger.error(TAG, String.format("Invalid response body for %s request", url));
                    return;
                }
                try {
                    result = (new JsonParser()).parse(responseData).getAsJsonObject();
                } catch (Throwable t) {
                    Logger.debug(TAG, "Not a JSON response");
                    final ResponseBody body = ResponseBody.create(null, responseData);
                    cb.onSuccess(response.newBuilder().body(body).build(), null);
                    return;
                }
                if (result.get("error") != null) {
                    final String error = result.get("error").getAsString();
                    Logger.error(TAG, "Error making request to " + url + ":" + result + " error:" + error);
                    cb.onFailure(null, new ProError(result));
                } else if (cb != null) {
                    cb.onSuccess(response, result);
                }
            }
        });
    }

    public interface ProCallback {
        public void onFailure(@Nullable Throwable throwable, @Nullable final ProError error);

        public void onSuccess(Response response, JsonObject result);
    }

    public interface ProUserCallback {
        public void onFailure(@Nullable Throwable throwable, @Nullable final ProError error);

        public void onSuccess(Response response, final ProUser userData);
    }

    public interface AuctionInfoCallback {
        public void onSuccess(final AuctionInfo auctionInfo);
    }

    public interface HttpCallback {
        public void onFailure(@Nullable Throwable throwable);

        public void onSuccess(Response response);
    }

    public interface PlansCallback {
        public void onFailure(@Nullable Throwable throwable, @Nullable final ProError error);

        public void onSuccess(Map<String, ProPlan> plans);
    }

    public interface PlansV3Callback {
        public void onFailure(@Nullable Throwable throwable, @Nullable final ProError error);

        public void onSuccess(Map<String, ProPlan> plans, List<PaymentMethods> methods);
    }

    public interface YuansferCallback {
        public void onFailure(@Nullable Throwable throwable, @Nullable final ProError error);

        public void onSuccess(String paymentInfo);
    }
}
