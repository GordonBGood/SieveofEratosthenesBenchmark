/*
 *
 *   A simple "Wheel Factorized Multi-Threaded Page Segmented Sieve of Eratosthenes" in Nim.
 *
 *   (c) Copyright 2020 W. Gordon Goodsman (GordonBGood)
 *
 *   See the file "copying.txt", included at the root of
 *   this distribution, for details about the copyright.
 *
 */

package com.gordonbgood.sieveoferatosthenesbenchmark

import android.os.Build
import android.os.Bundle
import android.view.View
import android.widget.*
import androidx.annotation.Keep
import androidx.appcompat.app.AppCompatActivity
import kotlinx.android.synthetic.main.activity_main.*
import java.io.File

class MainActivity : AppCompatActivity() {

    private val numprcs = Runtime.getRuntime().availableProcessors()
    private var maxfreq = 0.0
    private var isRunning = false
    private var isCancelled = false
    private var strt: Long = 0
    private var inpt: EditText? = null // = findViewById<EditText>(R.id.limit)
    private var cchszchs: Spinner? = null //  = findViewById<Spinner>(R.id.cachesize)
    private var mlti: CheckBox? = null //  = findViewById<CheckBox>(R.id.multi)
    private var rslt: TextView? = null //  = findViewById<TextView>(R.id.result)
    private var btn: Button? = null //  = findViewById<Button>(R.id.doit)

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        // initialize the convenience values to be used through the class...
        this.inpt = this.findViewById<EditText>(R.id.limit)
        this.cchszchs = this.findViewById<Spinner>(R.id.cachesize)
        this.mlti = this.findViewById<CheckBox>(R.id.multi)
        this.rslt = this.findViewById<TextView>(R.id.result)
        this.btn = this.findViewById<Button>(R.id.doit)

        findViewById<TextView>(R.id.smartphone).text =
            "Smartphone is " + Build.MANUFACTURER + " " + Build.DEVICE + " " + Build.MODEL
        var cpu = ""
        File("/proc/cpuinfo")
            .forEachLine {
                if (it.startsWith("Hardware")) cpu = it.drop(10).trim() else cpu = "" }
        this.findViewById<TextView>(R.id.cpuname).text =
            "The CPU is " + (if (cpu != "") cpu
                             else if (Build.HARDWARE != "") Build.HARDWARE
                                  else "unknown") + "."
        var mxfrqstr = File("sys/devices/system/cpu/cpu" +
                                      (numprcs - 1).toString() +
                                      "/cpufreq/cpuinfo_max_freq").readText()
        if (mxfrqstr == "")
            mxfrqstr =
                File("sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq").readText()
        this.findViewById<TextView>(R.id.maxfreq).text =
                    "The maximum CPU frequency is " +
                    (if (mxfrqstr != "") (mxfrqstr.toDouble() / 1000000).toString() + " GHz."
                     else "unknown.")
        if (mxfrqstr != "") this.maxfreq = mxfrqstr.toDouble()
        this.findViewById<TextView>(R.id.abi).text = "The CPU Android ABI is " + getAndroidABI()
        val aa = ArrayAdapter(this, android.R.layout.simple_spinner_item,
                               arrayOf("16 Kilobytes", "32 Kilobytes", "64 Kilobytes"))
        aa.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item)
        this.cchszchs?.adapter = aa
        this.cchszchs?.setSelection(1)
        this.mlti?.text = "Multi thread (" + numprcs + " cores)."
        val outer = this
        this.btn?.setOnClickListener(object: View.OnClickListener {
            override fun onClick(v: View) {
                outer.btn?.isClickable = false
                if (outer.isRunning) {
                    outer.btn?.text = "Pending cancelation..."
                    outer.btn?.isEnabled = false
                    // don't need to do atomically because only referenced on UI thread
                    outer.isCancelled = true
                } else {
                    outer.isCancelled = false
                    val lmt = outer.inpt?.text.toString().toLong()
                    if (lmt > 1000000000000)
                        outer.result?.text = "Limit must be 1000000000000 or less!"
                    else {
                        val cchsz = (1 shl outer.cchszchs?.selectedItemPosition!!) * 131072
                        val nmprcs = if (outer.mlti?.isChecked!!) outer.numprcs else 1
                        outer.btn?.text = "Click to cancel sieving..."
                        outer.isRunning = true
                        outer.strt = System.currentTimeMillis()
                        outer.startPrimesBench(lmt, cchsz, nmprcs)
                    }
                    outer.btn?.isClickable = true
                }
            }
        })
    }

    /*
     * a native method to obtain the Android ABI string...
     */
    external fun getAndroidABI(): String

    /* A native method that is implemented by the
     * 'primes-jni' native library, which is packaged
     * with this application.
     * This computes the number of primes to lmt using cache-sized sieving and numpros threads;
     * results are returned through calling JNI mothods, and progress is reported by
     * periodically calling a progress JNI mothod which also returns whether
     * cancellation has been initiated by the UI.
     */
    external fun startPrimesBench(lmt: Long, cache: Int, numprcs: Int)

    /*
     * A helper function called from here to go back to waiting for next run
     * Always run on UI thread!
     */
    @Keep
    public fun rdy2rsm() {
        this.isRunning = false
        this.isCancelled = false
        this.btn?.text = "Click to start sieving..."
        this.btn?.isEnabled = true
        this.btn?.isClickable = true
    }

    /*
     * A function called from JNI to update the progress and check for cancellation
     */
    @Keep
    private fun progressIsCancelled(prgrss: Double): Boolean {
        this.runOnUiThread {
            this.rslt?.text = "Sieving:  " + String.format("%.2f", prgrss * 100.0) + "% complete."
        }
        return this.isCancelled
    }

    /*
     * A function called from JNI to show the primes computation was cancelled
     */
    @Keep
    private fun doneCancelled() {
        this.runOnUiThread {
            this.rslt?.text = "Sieving was cancelled!"
            this.rdy2rsm()
        }
    }

    /*
     * A function called from JNI to show completion results
     */
    @Keep
    private fun doneCompleted(numprms: Long) {
        this.runOnUiThread {
            val elpsd = System.currentTimeMillis() - this.strt
            this.rslt?.text = "Found " + numprms + " primes in " + elpsd + " milliseconds."
            this.rdy2rsm()
        }
    }

    companion object {
        /* this is used to load the 'primes-jni' library on application
         * startup. The library has already been unpacked into
         * /data/data/com.gordonbgood.sieveoferatosthenesbenchmark/lib/libprimes-jni.so at
         * installation time by the package manager.
         */
        init {
            System.loadLibrary("primes-jni")
        }
    }
}
