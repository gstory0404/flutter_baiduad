package com.gstory.flutter_baiduad

import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel

class FlutterBaiduAdEventPlugin : FlutterPlugin, EventChannel.StreamHandler {

    companion object {
        private var eventChannel: EventChannel? = null

        private var eventSink: EventChannel.EventSink? = null

        private var context: Context? = null

        fun sendContent(content: MutableMap<String, Any?>) {
            eventSink?.success(content);
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        eventChannel = EventChannel(binding.binaryMessenger, FlutterBaiduAdConfig.adevent)
        eventChannel!!.setStreamHandler(this)
        context = binding.applicationContext
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        eventChannel = null
        eventChannel!!.setStreamHandler(null)
    }
}