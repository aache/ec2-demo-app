package com.ec2demo.ec2demo;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.test.web.servlet.MockMvc;

@WebMvcTest(HelloController.class)
class HelloControllerTest {

        @Autowired
        private MockMvc mockMvc;

        @Test
        void helloEndpointReturnsGreeting() throws Exception {
                mockMvc.perform(get("/hello"))
                                .andExpect(status().isOk())
                                .andExpect(content().string("Hello World"));
        }
}
