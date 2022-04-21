*** Settings ***
Documentation       Robocorp level II certification course
Library             RPA.Browser.Selenium    auto_close=${FALSE}   #screenshot_directory=${CURDIR}${/}Output${/}robopics
Library             RPA.HTTP
Library             RPA.Tables
Library             RPA.PDF
Library             RPA.Archive
Library             RPA.Dialogs

*** example final task ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    ${orders}=    Get orders
    FOR    ${row}    IN    @{orders}
        Close the annoying modal
        Fill the form    ${row}
        Preview the robot
        Submit the order
        ${pdf}=    Store the receipt as a PDF file    ${row}[Order number]
        ${screenshot}=    Take a screenshot of the robot    ${row}[Order number]
        Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}
        Go to order another robot
    END
    Create a ZIP file of the receipts

Ask user for orders file
    Add heading     Choose orders file to upload.
    Add files       *.csv
    Add submit buttons  buttons=Submit
    ${dialog}=      Show dialog     title=Upload
    #${results}=     Run dialog

*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    Download the orders file
    #Ask user for orders file
    Fill the order forms with data from the CVS file
    Create a ZIP file of the receipts

*** Keywords ***
Fill the order forms with data from the CVS file
    Download the orders file
    ${orders}=                  Read table from CSV     orders.csv      header=true
    FOR    ${row}    IN    @{orders}
        Close the annoying modal
        Fill the form    ${row}
        Preview the robot
        ${order_number}     Submit the order
        ${pdf}=  Store the receipt as a PDF file     ${order_number}
        ${screenshot_file}    Take a screenshot of the robot      ${order_number}
        Log     ${pdf}
        Embed the robot screenshot to the receipt PDF file    ${pdf}    ${screenshot_file}
        Order another robot
    END

Open the robot order website
    RPA.Browser.Selenium.Open Available Browser      https://robotsparebinindustries.com/#/robot-order

Download the orders file
    Download                    https://robotsparebinindustries.com/orders.csv      overwrite=true

Close the annoying modal
    Wait until page contains element       css=.btn-dark
    Wait Until Element Is Enabled          css=.btn-dark
    Click Button                           css=.btn-dark

Fill the form
    [Arguments]     ${robot_order}
    Select from List By Value   css=#head   ${robot_order}[Head]
    Select Radio Button         body        ${robot_order}[Body]
    Input Text                  class=form-control  ${robot_order}[Legs]
    Input Text                  address  ${robot_order}[Address]
    
Preview the robot
    Click Button                preview

Submit the order
    FOR     ${i}    IN RANGE     10000
        ${count}=           Get element count    order
        IF  ${count}>0
            Click Button   order
        ELSE
            ${receipt_number}=  Get Text  css:.badge-success
            #Log     ${receipt_number}   console=true
            #Store the receipt as a PDF file  ${receipt_number}
            #${screenshot}   Take a screenshot of the robot
            #Capture Element Screenshot  css:#robot-preview-image  filename=${CURDIR}${/}Output${/}${receipt_number}.png
        END
        Exit For Loop If    ${count}==0
    END
    [Return]    ${receipt_number}

Store the receipt as a PDF file
    [Arguments]     ${receipt_number}
    Wait Until Element Is Visible   order-completion
    ${receipt_html}=     Get Element Attribute   order-completion    outerHTML
    Log             ${receipt_number}   console=true
    ${receipt_pdf}=  Html to PDF     ${receipt_html}     ${OUTPUT_DIR}${/}${receipt_number}.pdf
    Html to PDF     ${receipt_html}     ${CURDIR}${/}Output${/}${receipt_number}.pdf
    [Return]    ${CURDIR}${/}Output${/}${receipt_number}.pdf

Take a screenshot of the robot
    [Arguments]     ${receipt_number}
    ${single_screenshot}=   Capture Element Screenshot  css:#robot-preview-image   ${CURDIR}${/}Output${/}robopics${/}${receipt_number}.png
    #${single_screenshot}=      Capture Element Screenshot  css:#robot-preview-image    #${receipt_number}.png
    ${screenshot}=  Create List  ${single_screenshot}
    [Return]    ${screenshot}

Order another robot
    Click Button        css:#order-another

Embed the robot screenshot to the receipt PDF file    #${screenshot}    ${pdf}
    [Arguments]     ${pdf}          ${screenshot}
    Log             hello           console=true
    Log             ${screenshot}   console=true
    Log             ${pdf}          console=true
    Add Files to Pdf    ${screenshot}   ${pdf}   append=true

Create a ZIP file of the receipts
    Archive folder with ZIP     ${CURDIR}${/}Output     receipts.zip