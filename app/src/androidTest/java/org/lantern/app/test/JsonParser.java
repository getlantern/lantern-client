package org.lantern.app.test;

import java.io.IOException;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.UnsupportedEncodingException;
import java.net.HttpURLConnection;
import java.net.URL;
import org.json.JSONException;
import org.json.JSONObject;

import android.util.Log;

public class JsonParser {
  public static JSONObject getJSONFromUrl(String url) {
    BufferedReader in = null;
    String json = "";
    try {
      URL u = new URL(url);
      HttpURLConnection urlConnection = (HttpURLConnection)u.openConnection();
      in = new BufferedReader(new InputStreamReader(urlConnection.getInputStream()));
      StringBuilder sb = new StringBuilder();
      String line = null;
      while ((line = in.readLine()) != null) {
        sb.append(line + "n");
      }
      json = sb.toString();
    } catch (Exception e) {
      e.printStackTrace();
    } finally {
      if (in != null) {
        try {
          in.close();
        } catch (IOException e) {
          e.printStackTrace();
        }
      }
    }
    Log.d("JSON Parser", "JSON result: " + json);

    JSONObject jObj = null;
    // try parse the string to a JSON object
    try {
      jObj = new JSONObject(json);
    } catch (JSONException e) {
      Log.e("JSON Parser", "Error parsing data " + e.toString());
    }

    // return JSON String
    return jObj;

  }
}
