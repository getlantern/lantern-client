package org.getlantern.lantern

import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.ext.junit.rules.activityScenarioRule
import androidx.test.internal.runner.junit4.AndroidJUnit4ClassRunner
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4ClassRunner::class)
class MainActivityTestSuite {
    @get:Rule
    var activityRule = activityScenarioRule<MainActivity>()

    @Test
    fun testEvent() {
        activityRule.scenario.onActivity { activity ->

        }
    }
}