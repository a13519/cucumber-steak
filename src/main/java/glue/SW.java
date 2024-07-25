package glue;

import cucumber.api.java.en.Given;
import cucumber.api.java.en.Then;
import cucumber.api.java.en.When;

public class SW {

@Given("^yI want to write a step with precondition$")
public void i_want_to_write_a_step_with_precondition() throws Exception {
    // Write code here that turns the phrase above into concrete actions
    System.out.println("aaa");
}

@Given("^some other precondition$")
public void some_other_precondition() throws Exception {
    // Write code here that turns the phrase above into concrete actions
	System.out.println("bbb");
}

@When("^I complete action$")
public void i_complete_action() throws Exception {
    // Write code here that turns the phrase above into concrete actions
	System.out.println("ccc");
}

@When("^some other action$")
public void some_other_action() throws Exception {
    // Write code here that turns the phrase above into concrete actions
	System.out.println("ddd");
}

@When("^yet another action$")
public void yet_another_action() throws Exception {
    // Write code here that turns the phrase above into concrete actions
	System.out.println("eee");
}

@Then("^I validate the outcomes$")
public void i_validate_the_outcomes() throws Exception {
    // Write code here that turns the phrase above into concrete actions
	System.out.println("fff");
}

@Then("^check more outcomes$")
public void check_more_outcomes() throws Exception {
    // Write code here that turns the phrase above into concrete actions
	System.out.println("ggg");
}


}
