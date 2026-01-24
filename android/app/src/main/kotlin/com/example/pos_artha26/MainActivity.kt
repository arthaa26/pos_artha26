package com.example.pos_artha26

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.bluetooth.BluetoothAdapter

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.pos_artha26/bluetooth"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getBondedDevices" -> {
                    try {
                        val bluetoothAdapter = BluetoothAdapter.getDefaultAdapter()
                        if (bluetoothAdapter != null) {
                            val bondedDevices = bluetoothAdapter.bondedDevices
                            val deviceList = mutableListOf<Map<String, Any>>()
                            
                            for (device in bondedDevices) {
                                val deviceMap = mapOf(
                                    "name" to (device.name ?: "Unknown"),
                                    "address" to device.address
                                )
                                deviceList.add(deviceMap)
                            }
                            
                            result.success(deviceList)
                        } else {
                            result.error("NO_BLUETOOTH", "Bluetooth adapter not available", null)
                        }
                    } catch (e: Exception) {
                        result.error("ERROR", "Error getting bonded devices: ${e.message}", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
