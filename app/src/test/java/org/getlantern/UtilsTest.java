package org.getlantern;

import org.junit.Assert;
import org.junit.Test;

import org.getlantern.lantern.model.Utils;

public class UtilsTest {

    @Test
    public void testFormatAsHeader() {
        final String[][] tests = {
            {"x_lantern_foo_bar_1", "X-Lantern-Foo-Bar-1"},
            {"x_lantern_x_y_ZULU", "X-Lantern-X-Y-ZULU"},
            {"host", "Host"},
            {"", ""},
            {"X-Lantern-Foo-12", "X-Lantern-Foo-12"},
            {"x-lantern-foo-12", "X-Lantern-Foo-12"},
        };

        for (String[] t : tests) {
            final String got = Utils.formatAsHeader(t[0]);
            Assert.assertEquals(t[1], got);
        }
    }
}
