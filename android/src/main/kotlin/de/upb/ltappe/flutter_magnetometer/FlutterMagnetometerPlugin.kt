package de.upb.ltappe.flutter_magnetometer

import android.os.Bundle
import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorManager
import android.hardware.SensorEventListener

import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

class FlutterMagnetometerPlugin(context: Context) :
        MethodCallHandler,
        EventChannel.StreamHandler,
        SensorEventListener {

    var sensorManager: SensorManager? = null

    private var latestData: MagnetometerData? = null

    private var eventSink: EventChannel.EventSink? = null

    init {
        sensorManager = context.getSystemService(Context.SENSOR_SERVICE) as SensorManager
    }

    companion object {
        private val METHOD_CHANNEL = "flutter_magnetometer"
        private val EVENTS_CHANNEL = "flutter_magnetometer/magnetometer-events"

        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val instance = FlutterMagnetometerPlugin(registrar.context())


            val mChannel = MethodChannel(registrar.messenger(), METHOD_CHANNEL)
            mChannel.setMethodCallHandler(instance)


            val eChannel = EventChannel(registrar.messenger(), EVENTS_CHANNEL)
            eChannel.setStreamHandler(instance)
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        if (call.method == "getMagnetometerData") {
            if (latestData != null) {
                result.success(latestData?.toMap());
            } else {
                result.success(MagnetometerData(0.0F, 0.0F, 0.0F).toMap())
            }

        }
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {
        println("Accuracy changed to ${accuracy.toString()}")
    }

    override fun onSensorChanged(event: SensorEvent?) {
        if (event != null) {
            val newData: MagnetometerData = MagnetometerData(event.values[0], event.values[1], event.values[2])
            latestData = newData;
            eventSink?.success(newData.toMap())
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        eventSink = events
        registerIfActive()
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
        unregisterIfActive()
    }

    // Lifecycle methods.
    private fun registerIfActive() {
        if (eventSink == null) return
        val magneticFieldSensor: Sensor = sensorManager!!.getDefaultSensor(Sensor.TYPE_MAGNETIC_FIELD)

        // We could play around with samplingPeriodUs (3rd param) here for lower latency
        // e.g. SensorManger.SENSOR_DELAY_GAME
        sensorManager!!.registerListener(this, magneticFieldSensor, SensorManager.SENSOR_DELAY_UI)
    }

    private fun unregisterIfActive() {
        if (eventSink == null) return
        sensorManager!!.unregisterListener(this)
    }
}

/**
 * An object representing the data acquired from a magnetometer along the device's coordinate
 * system.
 *
 * The attributes are stored as µT (microtesla).
 */
data class MagnetometerData(val x: Float, val y: Float, val z: Float) {

    /**
     * Representation of the class' attributes as typed Map object
     */
    fun toMap(): Map<String, Float> {
        return mapOf<String, Float>("x" to x, "y" to y, "z" to z)
    }
}
