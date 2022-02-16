package com;

import java.io.ByteArrayOutputStream;
import java.io.File;

import android.telephony.SignalStrength;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import android.net.NetworkInfo;
import java.lang.reflect.Method;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import org.cocos2dx.lib.Cocos2dxActivity;
import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;

import android.Manifest;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.ActivityInfo;
import android.graphics.Bitmap;
import android.graphics.Bitmap.CompressFormat;
import android.graphics.BitmapFactory;
import android.net.ConnectivityManager;
import android.net.Uri;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.os.Vibrator;
import android.telephony.PhoneStateListener;
import android.telephony.SignalStrength;
import android.telephony.TelephonyManager;
import android.text.TextUtils;
import android.util.Log;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.Toast;



public class MainManager {
	
	private static Cocos2dxActivity _cocosActivity;
	private static MainManager _instance;
	
	private MainManager() {
	}

	public static MainManager getInstance() {
		if (_instance == null) {
			_instance = new MainManager();
		}
		return _instance;
	}
	
	public void setup(Cocos2dxActivity $activity) {
		_cocosActivity = $activity;
	}

	////////////////////////
	private static native void nativeCheckSign(Context con);
	public static String[] permissions = null;
	public static void enterGame(){
		_cocosActivity.runOnUiThread(new Runnable() {
		    @Override
		    public void run() {
				runApp();
		    }
		  });		
	}
	
	/**
	 * 跑应用的逻辑
	 */
	private static void runApp() {
		nativeCheckSign(_cocosActivity);
	}
}
