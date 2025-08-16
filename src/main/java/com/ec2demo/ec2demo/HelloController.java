package com.ec2demo.ec2demo;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloController {

        @GetMapping("/hello")
        public String hello() {
                return "Hello World";
        }

        @GetMapping("/welcome")
        public String welcome() {
        return "Welcome";
    }

        @GetMapping("/welcome1")
        public String welcome1() {
        return "Welcome Test User";
    }

}
