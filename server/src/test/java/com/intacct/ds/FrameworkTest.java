package com.intacct.ds;

import com.intacct.core.Globals;
import com.intacct.core.errorhandling.IAException;
import lombok.extern.slf4j.Slf4j;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

import java.util.Locale;

@SpringBootTest
@Slf4j
public class FrameworkTest {

    @Test
    public void resourceFileLoadingTest() {
        // message property from ia-core
        String errorId = "InternalServerError.apiSchemaIssue.5003";
        String message = Globals.g.getMessage(errorId, new Object[]{}, null, Locale.getDefault());
        Assertions.assertNotNull(message);
        Assertions.assertTrue(message.contains("Invalid schema file format"));

        // message property from domain specific bundle
        // domain owner should replace "template" in the folder, filename, and as well in the error id, with its own domain name
        errorId = "InternalServerError.sampleMessage.template-9000";
        message = Globals.g.getMessage(errorId, new Object[]{}, null, Locale.TAIWAN);
        log.info("error id " + errorId + " resolved in " + Locale.TAIWAN.toString() + " is: " + message);
        try {
            throw new IAException(errorId, new Object[]{});
        } catch (IAException e) {
            Assertions.assertNotNull(e.getIaError());
            Assertions.assertNotNull(e.getIaError().getMessage());
            Assertions.assertFalse(e.getIaError().getMessage().isEmpty());
            Assertions.assertTrue(message.contains("錯誤訊息範本"));
            log.info("error id " + errorId + " resolved message: " + e.getIaError().getMessage());
        }
    }
}
