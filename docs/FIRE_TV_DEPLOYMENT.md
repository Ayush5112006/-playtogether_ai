# Amazon Fire TV & Vega OS Deployment Guide — PlayTogether AI

## Executive Overview
**PlayTogether AI** is engineered as a TV-first, 10-foot living room multi-generational gaming experience. This guide details packaging, input handling, overscan compensation, audio management, and submission requirements for **Amazon Fire TV (Fire OS 7 / 8, Android API 28–33)** and future **Vega OS** deployment targets.

---

## 1. Architectural Foundations (10-Foot UI)

### 1.1 Resolution & Safe Zones
- **Target Physical Canvas**: `1920 x 1080` (Full HD Reference).
- **Aspect Ratio**: Strict `16:9` fixed viewport (`width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no`).
- **Overscan Margins (Title/Action Safe Area)**:
  - Television screens frequently crop edge pixels (overscan).
  - All critical interactive elements (buttons, score HUD, questions) are placed within a **90% safe zone** (5% margins top, bottom, left, right).
  - Minimum safe container bounds: `1728 x 972` centered within the 1080p canvas.
  - Tailwind safe layout utility: `.tv-safe-container` in `app/globals.css`.

### 1.2 Contrast & Typography
- **Viewing Distance**: 10 feet (~3 meters).
- **Minimum Font Sizes**:
  - Primary prompts: `32px – 48px` font-black.
  - Option text: `20px – 24px` font-bold.
  - Meta/status legends: `12px – 14px` font-mono.
- **Focus Rings**:
  - Unfocused elements maintain `opacity: 0.85 – 0.90`.
  - Focused elements expand (`scale(1.04)`), display a high-contrast amber/gold glow (`#F59E0B`), and emit a soft synthetic audio click.

---

## 2. Remote Input Architecture (Fire OS KeyCode Mapping)

### 2.1 Hardware Remote KeyCodes
PlayTogether AI directly binds to Fire OS hardware remote events via `components/tv/TVFocusManager.tsx`:

| Fire OS Hardware Key | Android KeyCode | Web Keyboard Fallback | RemoteCommand Action |
|:---|:---:|:---:|:---|
| **D-Pad UP** | `19` | `ArrowUp` (`38`) | `UP` (Spatial Focus Traversal) |
| **D-Pad DOWN** | `20` | `ArrowDown` (`40`) | `DOWN` (Spatial Focus Traversal) |
| **D-Pad LEFT** | `21` | `ArrowLeft` (`37`) | `LEFT` (Spatial Focus Traversal) |
| **D-Pad RIGHT** | `22` | `ArrowRight` (`39`) | `RIGHT` (Spatial Focus Traversal) |
| **D-Pad CENTER (Select)** | `23` | `Enter` (`13`) | `OK` (Activate Focused Element) |
| **BACK** | `4` | `Escape` (`27`) / `Backspace` (`8`) | `BACK` (Hierarchical Back Navigation) |
| **VOICE / SEARCH (Mic)** | `84` | `KeyM` (`77`) | `MIC` (Open Host Voice Assistant) |
| **MENU** | `82` | `KeyR` (`82`) | `MENU` (Quick Settings) |
| **MEDIA PLAY / PAUSE** | `85` | `Space` (`32`) / `KeyB` (`66`) | `BUZZ` (Lightning Buzzer Blitz) |

### 2.2 Input Debouncing & Gesture Safety
- TV remotes send rapid-fire key repeats when held.
- `TVFocusManager` enforces a **60ms hardware debounce threshold**.
- Question answer options immediately lock (`isSubmitted: true`) upon activation to prevent accidental double-scoring or desynchronization.

---

## 3. Web App Manifest (`public/manifest.json`)

To deploy as an Amazon Web App (W3C standard packaged web application):

```json
{
  "name": "PlayTogether AI",
  "short_name": "PlayTogether",
  "description": "One TV. One Remote. Every Generation Plays. AI-Powered Adaptive Family Trivia for Amazon Fire TV.",
  "start_url": "/",
  "display": "fullscreen",
  "orientation": "landscape",
  "background_color": "#070812",
  "theme_color": "#070812",
  "icons": [
    {
      "src": "/icons/icon-512x512.png",
      "sizes": "512x512",
      "type": "image/png",
      "purpose": "any maskable"
    },
    {
      "src": "/icons/icon-1280x720.png",
      "sizes": "1280x720",
      "type": "image/png"
    }
  ],
  "categories": ["games", "entertainment", "trivia"]
}
```

---

## 4. Android WebView / Fire OS Hybrid Container Packaging

For developers packaging the Next.js production build inside an Android APK wrapper using Android Studio:

### 4.1 `AndroidManifest.xml` Configuration
```xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="ai.playtogether.firetv">

    <!-- Fire TV Features: Touchscreen NOT required, Gamepad/Remote supported -->
    <uses-feature android:name="android.hardware.touchscreen" android:required="false" />
    <uses-feature android:name="android.software.leanback" android:required="true" />

    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.RECORD_AUDIO" />

    <application
        android:allowBackup="true"
        android:hardwareAccelerated="true"
        android:icon="@mipmap/ic_launcher"
        android:label="PlayTogether AI"
        android:theme="@android:style/Theme.NoTitleBar.Fullscreen">

        <activity
            android:name=".MainActivity"
            android:configChanges="orientation|keyboardHidden|screenSize"
            android:screenOrientation="landscape"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LEANBACK_LAUNCHER" />
            </intent-filter>
        </activity>
    </application>
</manifest>
```

### 4.2 `MainActivity.java` WebView Optimizations
```java
package ai.playtogether.firetv;

import android.app.Activity;
import android.os.Bundle;
import android.view.KeyEvent;
import android.view.View;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;

public class MainActivity extends Activity {
    private WebView mWebView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        mWebView = new WebView(this);
        setContentView(mWebView);

        WebSettings settings = mWebView.getSettings();
        settings.setJavaScriptEnabled(true);
        settings.setDomStorageEnabled(true);
        settings.setDatabaseEnabled(true);
        settings.setMediaPlaybackRequiresUserGesture(false);
        settings.setAllowFileAccess(true);
        settings.setCacheMode(WebSettings.LOAD_DEFAULT);

        // Hardware accelerated canvas and WebGL
        mWebView.setLayerType(View.LAYER_TYPE_HARDWARE, null);
        mWebView.setScrollBarStyle(View.SCROLLBARS_INSIDE_OVERLAY);
        mWebView.setVerticalScrollBarEnabled(false);
        mWebView.setHorizontalScrollBarEnabled(false);

        mWebView.setWebViewClient(new WebViewClient());
        mWebView.loadUrl("https://your-production-app.vercel.app");
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        // Intercept Fire TV Back key to allow in-app state machine back navigation
        if (keyCode == KeyEvent.KEYCODE_BACK) {
            mWebView.dispatchKeyEvent(event);
            return true;
        }
        return super.onKeyDown(keyCode, event);
    }
}
```

---

## 5. Audio & Performance Optimizations

1. **Synthetic Sound Synthesis**:
   - Built directly via the standard Web Audio API in `TVFocusManager.tsx`.
   - Requires zero external audio file downloads, reducing cold start latency to near 0ms.
   - Provides pitch-calibrated feedback (420Hz navigate chime, 523Hz select chime, 350Hz buzzer blast, 1046Hz winner fanfare).

2. **60 FPS Ambient Background**:
   - `components/tv/AnimatedAINetworkBackground.tsx` draws particles on an HTML5 canvas with delta-time normalization.
   - Automatically handles window resize, high-DPI scaling, and throttles off-screen rendering.

3. **Production Security**:
   - Next.js response headers (`next.config.mjs`) inject:
     - `Content-Security-Policy`: Disallows unauthorized script injections.
     - `X-Frame-Options: DENY`: Prevents clickjacking.
     - `X-Content-Type-Options: nosniff`: Prevents MIME-sniffing.
     - `Strict-Transport-Security`: Enforces TLS 1.3 across all Supabase and API communications.

---

## 6. Amazon Appstore Submission Checklist

- [x] **Leanback Launcher Support**: App displays properly on Fire TV home carousel.
- [x] **100% Remote Control Compliance**: Complete flow playable with 5-way D-Pad alone without touchscreen or mouse pointer.
- [x] **Safe-Zone Conformance**: Zero text or buttons clipped on overscan TVs.
- [x] **No Horizontal/Vertical Scrollbars**: Scrollbars hidden; pagination handled via spatial focus.
- [x] **Zero Uncaught Exceptions**: All transitions validated by state machine.
- [x] **Authoritative Server Scoring**: Prevents tamper; guest mode supported with optional MFA.
