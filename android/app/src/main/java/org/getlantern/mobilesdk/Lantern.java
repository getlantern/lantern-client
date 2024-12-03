package org.getlantern.mobilesdk;

import android.content.Context;
import android.content.res.AssetManager;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

import internalsdk.Session;


/**
 * API for embedding the Lantern proxy
 */
public abstract class Lantern {

    private static final String TAG = "Lantern";

    /**
     * <p>Starts Lantern at a random port, storing configuration information in the indicated
     * configDir and waiting up to timeoutMillis for the proxy to come online. If the proxy fails to
     * come online within the timeout, this throws an exception.</p>
     * <p/>
     * <p>If a Lantern proxy is already running within this process, that proxy is reused.</p>
     * <p/>
     * <p>Note - this does not wait for the entire initialization sequence to finish, just for the
     * proxy to be listening. Once the proxy is listening, one can start to use it, even as it
     * finishes its initialization sequence. However, initial activity may be slow, so clients with
     * low read timeouts may time out.</p>
     *
     * @param context
     * @param locale
     * @param config
     * @param settings
     * @return the {@link internalsdk.Lantern.StartResult} with port information about the started
     * lantern
     */
    public static StartResult enable(final Context context,
                                     final String locale,
                                     final Settings settings,
                                     final Session session)
            throws LanternNotRunningException {
        return doEnable(context, locale, settings,
                "org.getlantern.mobilesdk.embedded.EmbeddedLantern", session);
    }

    /**
     * Like {@link #enable(Context, int, String)} but runs the proxy in a Service.
     *
     * @param context
     * @param locale
     * @param settings
     * @param session
     * @return
     * @throws LanternNotRunningException
     */
    public static StartResult enableAsService(
            final Context context, final String locale,
            final Settings settings, final Session session)
            throws LanternNotRunningException {
        return doEnable(context, locale, settings,
                "org.getlantern.mobilesdk.LanternServiceManager", session);
    }

    private static StartResult doEnable(
            final Context context, final String locale,
            final Settings settings,
            String implClassName, Session session)
            throws LanternNotRunningException {

        initConfigDir(context);

        if (settings.stickyConfig()) {
            copyAssetFile(context, "proxies.yaml");
            copyAssetFile(context, "global.yaml");
        }


        final Lantern lantern = instanceOf(implClassName);
        final StartResult result = lantern.start(context, locale,
                settings, session);

        proxyOn(result.getHttpAddr());

        return result;
    }

    /**
     * Note - we use dynamic class loading to avoid loading unused classes into the caller's
     * classloader (i.e. to avoid loading native dependencies when running as service). This is
     * important because in some situations, it appears that including the Lantern native library
     * inside the same process as an application can cause instability on some phones (e.g. Samsung
     * Galaxy S4).
     *
     * @param implClassName
     * @return
     * @throws LanternNotRunningException
     */
    private static Lantern instanceOf(String implClassName) throws LanternNotRunningException {
        try {
            Class<? extends Lantern> implClass = (Class<? extends Lantern>) Lantern.class.getClassLoader().loadClass(implClassName);
            return implClass.newInstance();
        } catch (Exception e) {
            throw new LanternNotRunningException("Unable to get implementation class: " + e.getMessage(), e);
        }
    }

    protected abstract StartResult start(
            final Context context, final String locale,
            final Settings settings, final Session session)
            throws LanternNotRunningException;

    private static void proxyOn(String addr) {
        int lastIndexOfColon = addr.lastIndexOf(':');
        String host = addr.substring(0, lastIndexOfColon);
        String port = addr.substring(lastIndexOfColon + 1);
        System.setProperty("http.proxyHost", host);
        System.setProperty("http.proxyPort", port);
        System.setProperty("https.proxyHost", host);
        System.setProperty("https.proxyPort", port);
    }

    /**
     * Disables the Lantern proxy so that connections within this process will no longer be proxied.
     * This leaves any background activity for the proxy running, and subsequent calls to
     * {@link #enable(Context, int, String)} will reuse the existing proxy in this process.
     */
    public static void disable(final Context context) {
        System.clearProperty("http.proxyHost");
        System.clearProperty("http.proxyPort");
        System.clearProperty("https.proxyHost");
        System.clearProperty("https.proxyPort");
        // TODO: stop service if necessary
    }

    /**
     * Prints the contents of file to logcat.
     * Used for debugging purposes.
     *
     * @param file
     */
    private static void printFile(final File file) throws IOException {
        BufferedReader br = null;
        try {
            String line = null;
            br = new BufferedReader(new FileReader(file));

            while ((line = br.readLine()) != null) {
                Logger.d(TAG, line);
            }
        } finally {
            if (br != null) {
                br.close();
            }
        }
    }

    private static void copyFile(String fileName, File dstFile,
                                 InputStream in,
                                 OutputStream out) throws IOException {
        byte[] buffer = new byte[1024];
        int read;

        Logger.d(TAG, String.format("Copying %s to %s", fileName,
                dstFile.getAbsolutePath()));

        while ((read = in.read(buffer)) != -1) {
            out.write(buffer, 0, read);
        }

        Logger.d(TAG, "Finished copying asset file: " + fileName);
    }

    /**
     * Copies an asset file (named fileName) to the active
     * Lantern configuration directory.
     *
     * @param context
     * @param fileName
     */
    private static void copyAssetFile(Context context,
                                      String fileName) {

        InputStream in = null;
        OutputStream out = null;

        try {
            final AssetManager am = context.getAssets();
            in = am.open(fileName);

            final File dstFile = new File(new File(context.getFilesDir(), ".lantern"), fileName);

            out = new FileOutputStream(dstFile);

            copyFile(fileName, dstFile, in, out);

            printFile(dstFile);

        } catch (Exception e) {
            Logger.e(TAG, "Error trying to copy asset file", e);

        } finally {
            if (in != null) {
                try {
                    in.close();
                } catch (final IOException e) {
                    Logger.d(TAG, "Error closing stream", e);
                }
            }
            if (out != null) {
                try {
                    out.close();
                } catch (final IOException e) {
                    Logger.d(TAG, "Error closing stream", e);
                }
            }
        }
    }

    private static void initConfigDir(final Context context) {
        final File dir = new File(context.getFilesDir(), ".lantern");
        try{
            final boolean success = dir.mkdir();
            if (success) {
                Logger.d(TAG, "Created config directory");
            } else {
                Logger.d(TAG, "Error creating config directory");
            }
        }catch (Exception e){
            Logger.e(TAG, "Error while creating config directory", e);
        }

    }

    public static String configDirFor(Context context, String suffix) {
        return new File(context.getFilesDir(),
                ".lantern" + suffix).getAbsolutePath();
    }
}
