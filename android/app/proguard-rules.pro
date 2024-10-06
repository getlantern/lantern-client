# Add project specific ProGuard rules here.
# By default, the flags in this file are appended to flags specified
# in /Users/todd/Library/Android/sdk/tools/proguard/proguard-android.txt
# You can edit the include path and order by changing the proguardFiles
# directive in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# Add any project specific keep options here:

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Don't obfuscate so that logs contain useful stack traces
-dontobfuscate
#-keep class com.microtripit.** { *; }
#-keep class com.microtripit.mandrillapp.**
-keepattributes Signature

#-keep class android.** { *; }
# Make sure we get line numbers in stack traces, but don't reveal source file names
-renamesourcefileattribute SourceFile
-keepattributes SourceFile,LineNumberTable

##---------------Begin: proguard configuration for Tapsell Sdk  ----------

# Application classes that will be serialized/deserialized over Gson
-keepclassmembers enum * { *; }
-keep interface ir.tapsell.sdk.NoProguard

-keep interface ir.tapsell.sdk.NoNameProguard
-keep class * implements ir.tapsell.sdk.NoProguard { *; }

-keep enum * implements ir.tapsell.sdk.NoProguard { *; }

-keepnames class * implements ir.tapsell.sdk.NoNameProguard { *; }
-keep class ir.tapsell.sdk.nativeads.TapsellNativeVideoAdLoader$Builder {*;}
-keep class ir.tapsell.sdk.nativeads.TapsellNativeBannerAdLoader$Builder {*;}
-keep interface com.android.vending.billing.IInAppBillingService
-keep class * implements com.android.vending.billing.IInAppBillingService {*;}

-keep class ir.tapsell.sdk.models.** { *; }

-keep class ir.tapsell.sdk.sentry.model.** {*;}

# To Remove Logger Class (Todo: Replace Logger Class with LogUtils)
-assumenosideeffects class ir.tapsell.sdk.logger.Logger {
    public * ;
    public static *** LogDebug(...);
    public static *** LogError(...);
    public static *** LogInfo(...);
    public static *** LogVerbose(...);
    public static *** LogWarn(...);
}

-keep public class com.bumptech.glide.**

# This is generated automatically by the Android Gradle plugin.
-dontwarn com.google.android.libraries.places.api.Places
-dontwarn com.google.android.libraries.places.api.model.AddressComponent
-dontwarn com.google.android.libraries.places.api.model.AddressComponents
-dontwarn com.google.android.libraries.places.api.model.AutocompletePrediction
-dontwarn com.google.android.libraries.places.api.model.AutocompleteSessionToken
-dontwarn com.google.android.libraries.places.api.model.Place$Field
-dontwarn com.google.android.libraries.places.api.model.Place
-dontwarn com.google.android.libraries.places.api.model.TypeFilter
-dontwarn com.google.android.libraries.places.api.net.FetchPlaceRequest
-dontwarn com.google.android.libraries.places.api.net.FetchPlaceResponse
-dontwarn com.google.android.libraries.places.api.net.FindAutocompletePredictionsRequest$Builder
-dontwarn com.google.android.libraries.places.api.net.FindAutocompletePredictionsRequest
-dontwarn com.google.android.libraries.places.api.net.FindAutocompletePredictionsResponse
-dontwarn com.google.android.libraries.places.api.net.PlacesClient
-dontwarn com.stripe.android.stripecardscan.cardscan.CardScanSheet$CardScanResultCallback
-dontwarn com.stripe.android.stripecardscan.cardscan.CardScanSheet$Companion
-dontwarn com.stripe.android.stripecardscan.cardscan.CardScanSheet
-dontwarn com.stripe.android.stripecardscan.cardscan.CardScanSheetResult$Completed
-dontwarn com.stripe.android.stripecardscan.cardscan.CardScanSheetResult$Failed
-dontwarn com.stripe.android.stripecardscan.cardscan.CardScanSheetResult
-dontwarn com.stripe.android.stripecardscan.cardscan.exception.UnknownScanException
-dontwarn com.stripe.android.stripecardscan.payment.card.ScannedCard
-dontwarn groovy.lang.GroovyObject
-dontwarn groovy.lang.MetaClass
-dontwarn java.lang.management.ManagementFactory
-dontwarn javax.management.InstanceNotFoundException
-dontwarn javax.management.MBeanRegistrationException
-dontwarn javax.management.MBeanServer
-dontwarn javax.management.MalformedObjectNameException
-dontwarn javax.management.ObjectInstance
-dontwarn javax.management.ObjectName
-dontwarn javax.naming.Context
-dontwarn javax.naming.InitialContext
-dontwarn javax.naming.NamingEnumeration
-dontwarn javax.naming.NamingException
-dontwarn javax.naming.directory.Attribute
-dontwarn javax.naming.directory.Attributes
-dontwarn javax.naming.directory.DirContext
-dontwarn javax.naming.directory.InitialDirContext
-dontwarn javax.naming.directory.SearchControls
-dontwarn javax.naming.directory.SearchResult
-dontwarn javax.servlet.ServletContainerInitializer
-dontwarn org.bouncycastle.jsse.BCSSLParameters
-dontwarn org.bouncycastle.jsse.BCSSLSocket
-dontwarn org.bouncycastle.jsse.provider.BouncyCastleJsseProvider
-dontwarn org.codehaus.groovy.reflection.ClassInfo
-dontwarn org.codehaus.groovy.runtime.BytecodeInterface8
-dontwarn org.codehaus.groovy.runtime.ScriptBytecodeAdapter
-dontwarn org.codehaus.groovy.runtime.callsite.CallSite
-dontwarn org.codehaus.groovy.runtime.callsite.CallSiteArray
-dontwarn org.codehaus.janino.ClassBodyEvaluator
-dontwarn org.conscrypt.Conscrypt$Version
-dontwarn org.conscrypt.Conscrypt
-dontwarn org.conscrypt.ConscryptHostnameVerifier
-dontwarn org.joda.convert.FromString
-dontwarn org.joda.convert.ToString
-dontwarn org.openjsse.javax.net.ssl.SSLParameters
-dontwarn org.openjsse.javax.net.ssl.SSLSocket
-dontwarn org.openjsse.net.ssl.OpenJSSE
-dontwarn sun.nio.ch.DirectBuffer
-dontwarn sun.reflect.Reflection

# Lantern
-keep class org.getlantern.** { *; }
-keep class io.lantern.** { *; }
#
# Gson
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.examples.android.model.** { <fields>; }
-keep class * extends com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer
-keepclassmembers,allowobfuscation class * {
  @com.google.gson.annotations.SerializedName <fields>;
}
-keep,allowobfuscation,allowshrinking class com.google.gson.reflect.TypeToken
-keep,allowobfuscation,allowshrinking class * extends com.google.gson.reflect.TypeToken

# J2ObjC Annotations
-dontwarn com.google.j2objc.annotations.ReflectionSupport$Level
-dontwarn com.google.j2objc.annotations.ReflectionSupport
-dontwarn com.google.j2objc.annotations.RetainedWith

## Lifecycle
#-keep class androidx.lifecycle.** {*;}
#
## Safely ignore warnings about other libraries since we are using Gson
#-dontwarn com.fasterxml.jackson.**
#-dontwarn org.json.**
#
## Annotations
#-dontwarn javax.annotation.**
#
## Findbugs
#-dontwarn edu.umd.cs.findbugs.annotations.SuppressFBWarnings
#
## slf4j
#-dontwarn org.slf4j.**
#
## Ensure annotations are kept for runtime use.
#-keepattributes *Annotation*
## Don't remove any GreenRobot classes
#-keep class org.greenrobot.** {*;}
## Don't remove any methods that have the @Subscribe annotation
#
#-keepclassmembers class ** {
#    @org.greenrobot.eventbus.Subscribe <methods>;
#}
#-keep enum org.greenrobot.eventbus.ThreadMode { *; }
#
#
###---------------Begin: proguard configuration for Gson  ----------
## Gson uses generic type information stored in a class file when working with fields. Proguard
## removes such information by default, so configure it to keep all of it.
#-keepattributes Signature
#
## For using GSON @Expose annotation
#-keepattributes *Annotation*
#
## Gson specific classes
#-dontwarn sun.misc.**
##-keep class com.google.gson.stream.** { *; }
#
## Application classes that will be serialized/deserialized over Gson
#-keep class com.google.gson.examples.android.model.** { *; }
#
## Prevent proguard from stripping interface information from TypeAdapterFactory,
## JsonSerializer, JsonDeserializer instances (so they can be used in @JsonAdapter)
#-keep class * implements com.google.gson.TypeAdapterFactory
#-keep class * implements com.google.gson.JsonSerializer
#-keep class * implements com.google.gson.JsonDeserializer
#
###---------------End: proguard configuration for Gson  ----------
#
#
###---------------Begin: proguard configuration for Retrofit  ----------
## Retrofit does reflection on generic parameters. InnerClasses is required to use Signature and
## EnclosingMethod is required to use InnerClasses.
#-keepattributes Signature, InnerClasses, EnclosingMethod
#
## Retain service method parameters when optimizing.
#-keepclassmembers,allowshrinking,allowobfuscation interface * {
#    @retrofit2.http.* <methods>;
#}
#
## Ignore annotation used for build tooling.
#-dontwarn org.codehaus.mojo.animal_sniffer.IgnoreJRERequirement
#
## Ignore JSR 305 annotations for embedding nullability information.
#-dontwarn javax.annotation.**
#
## Guarded by a NoClassDefFoundError try/catch and only used when on the classpath.
#-dontwarn kotlin.Unit
#
## Top-level functions that can only be used by Kotlin.
#-dontwarn retrofit2.-KotlinExtensions
###---------------End: proguard configuration for Retrofit  ----------
#
#
###---------------Begin: proguard configuration for okhttp3  ----------
## JSR 305 annotations are for embedding nullability information.
#-dontwarn javax.annotation.**
#
## A resource is loaded with a relative path so the package of this class must be preserved.
#-keepnames class okhttp3.internal.publicsuffix.PublicSuffixDatabase
#
## Animal Sniffer compileOnly dependency to ensure APIs are compatible with older versions of Java.
#-dontwarn org.codehaus.mojo.animal_sniffer.*
#
## OkHttp platform used only on JVM and when Conscrypt dependency is available.
#-dontwarn okhttp3.internal.platform.ConscryptPlatform
###---------------End: proguard configuration for okhttp3  ----------
#
#
###---------------Begin: proguard configuration for okio  ----------
## Animal Sniffer compileOnly dependency to ensure APIs are compatible with older versions of Java.
#-dontwarn org.codehaus.mojo.animal_sniffer.*
###---------------End: proguard configuration for okio  ----------
#

##---------------Begin: proguard configuration for sqlcipher  ----------
-keep class net.sqlcipher.** { *; }
-keep class net.sqlcipher.database.* { *; }
##---------------End: proguard configuration for sqlcipher  ----------

##---------------Begin: proguard configuration for Signal  ----------
-keep class org.whispersystems.** { *; }
##---------------End: proguard configuration for Signal  ----------
#
