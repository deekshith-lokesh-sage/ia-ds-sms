package com.intacct.bdd;

import org.junit.platform.suite.api.*;

import static io.cucumber.junit.platform.engine.Constants.GLUE_PROPERTY_NAME;

@Suite
@SuiteDisplayName("JUnit Platform Suite")
@SelectPackages("bdd")
@IncludeClassNamePatterns(".*Test.*")
@ConfigurationParameter(key = GLUE_PROPERTY_NAME, value = "com.intacct.bdd.framework")
public class TestRunner {
}
