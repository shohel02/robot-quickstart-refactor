*** Settings ***
Resource     ../common.robot
Suite Setup     Clear Login Database
Test Teardown     Clear Login Database

Force Tags     quickstart
Default Tags     example    smoke

*** Keywords ***
Clear login database
    Remove file     $(DATABASE FILE}

Create valid user
    [Arguments]     ${username}     ${password}
    Create user     ${username}     ${password}
    Status should be     SUCCESS

Creating user with invalid password should fail
    [Arguments]    ${password}    ${error}
    Create user    example    ${password}
    Status should be    Creating user failed: ${error}

Login
    [Arguments]    ${username}    ${password}
    Attempt to login with credentials    ${username}    ${password}
    Status should be    Logged In

# Keywords for higher level test

A user has a valid account
    Create valid user    ${USERNAME}      ${PASSWORD}

She changes her password
    Change password    ${USERNAME}    ${PASSWORD}    ${NEW PASSWORD}
    Status should be    SUCCESS

She can log in with the new password
    Login    ${USERNAME}    ${NEW PASSWORD}

She cannot use the old password anymore
    Attempt to login with credentials    ${USERNAME}    ${PASSWORD}
    Status should be    Access Denied

Database should contain
    [Arguments]    ${username}     ${password}     ${status}
    ${database}=     Get File      ${DATABASE FILE}
    Should Contain    ${database}   ${username}\t${password}\t${status}\n    

*** Test Cases ***
User can create an account and log in
    Create Valid User    fred    P4ssw0rd
    Attempt to Login with Credentials    fred    P4ssw0rd
    Status Should Be     Logged In

User cannot log in with bad password
    Create Valid User    betty    P4ssw0rd
    Attempt to Login with Credentials    betty    wrong
    Status Should Be    Access Denied

User can change password
    Given a user has a valid account
    When she changes her password
    Then she can log in with the new password
    And she cannot use the old password anymore

Invalid password
    [Template]       Creating user with invalid password should fail
    abCD5            ${PWD INVALID LENGTH}
    abCD567890123    ${PWD INVALID LENGTH}
    123DEFG          ${PWD INVALID CONTENT}
    abcd56789        ${PWD INVALID CONTENT}
    AbCdEfGh         ${PWD INVALID CONTENT}
    abCD56+          ${PWD INVALID CONTENT}

User status is stored in databases
    [Tags]    variables    databases
    Create Valid User     ${USERNAME}     ${PASSWORD}
    Database Should Contain     ${USERNAME}    ${PASSWORD}     Inactive
    Login     ${USERNAME}      ${PASSWORD}
    Database Should Contain     ${USERNAME}    ${PASSWORD}     Active 

