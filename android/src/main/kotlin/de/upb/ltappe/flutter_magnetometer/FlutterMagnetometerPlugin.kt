package de.upb.ltappe.flutter_magnetometer

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorManager
import android.hardware.SensorEventListener

import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.PluginRegistry.Registrar

/**
 * Kotlin implementation for streaming Sensor.TYPE_MAGNETIC_FIELD values inside Dart code through
 * platform messages
 */
class FlutterMagnetometerPlugin(context: Context) :
        EventChannel.StreamHandler,
        SensorEventListener {

    private var sensorManager: SensorManager? = null
    private var sensor: Sensor? = null

    private var eventSink: EventChannel.EventSink? = null

    init {
        sensorManager = context.getSystemService(Context.SENSOR_SERVICE) as SensorManager
    }

    companion object {
        private const val EVENTS_CHANNEL = "flutter_magnetometer/magnetometer-events"

        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val instance = FlutterMagnetometerPlugin(registrar.context())

            val eChannel = EventChannel(registrar.messenger(), EVENTS_CHANNEL)
            eChannel.setStreamHandler(instance)
        }
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {
        println("Sensor accuracy changed to $accuracy")
    }

    override fun onSensorChanged(event: SensorEvent?) {
        val values = listOf(event!!.values[0], event.values[1], event.values[2])
        eventSink?.success(values)
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        eventSink = events
        registerIfActive()
    }

    override fun onCancel(arguments: Any?) {
        unregisterIfActive()
        eventSink = null
    }

    // Lifecycle methods.
    private fun registerIfActive() {
        if (eventSink == null) return
        sensor = sensorManager!!.getDefaultSensor(Sensor.TYPE_MAGNETIC_FIELD)

        // We could play around with samplingPeriodUs (3rd param) here for lower latency
        // e.g. SensorManger.SENSOR_DELAY_GAME
        sensorManager!!.registerListener(this, sensor, SensorManager.SENSOR_DELAY_UI)
    }

    private fun unregisterIfActive() {
        if (eventSink == null) return
        sensorManager!!.unregisterListener(this)
    }
}
