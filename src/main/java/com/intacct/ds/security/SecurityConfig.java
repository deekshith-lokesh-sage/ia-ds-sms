package com.intacct.ds.security;

import lombok.Getter;
import lombok.Setter;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.annotation.Order;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;

@Configuration
@ConfigurationProperties(prefix = "com.intacct.ds.auth")
@ConditionalOnProperty(value = "com.intacct.ds.auth.secured", havingValue = "true")
@EnableWebSecurity
@Setter
@Getter
@Order(1)
public class SecurityConfig extends WebSecurityConfigurerAdapter {

    private String headerName;
    private String apiKey;

    @Override
    protected void configure(HttpSecurity http) throws Exception {
        final ApiKeyAuthFilter filter = new ApiKeyAuthFilter(headerName);

        filter.setAuthenticationManager(authentication -> {
            final String principal = (String) authentication.getPrincipal();

            if (!apiKey.equals(principal)) {
                throw new BadCredentialsException("The API key was not found or not the expected value.");
            }

            authentication.setAuthenticated(true);

            return authentication;
        });

        http
                .csrf().disable()
                .addFilter(filter)
                .authorizeRequests()
                .antMatchers("/actuator/env/**").permitAll()
                .antMatchers("/actuator/health/**").permitAll()
                .anyRequest()
                .authenticated();
    }
}
