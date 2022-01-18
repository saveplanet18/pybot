*** Settings ***
Documentation       Only the robot is allowed to get the orders file.
...                 The robot save each order HTML receipt as a PDF file
...                 The robot save a screenshot of each of the ordered robots
...                 The robot embed the screenshot of the robot to the PDF receipt
...                 The robot create a ZIP archive of the PDF receipts (one zip archive that contains all the PDF files)
...                 The robot complete all the orders even when there are technical failures with the robot order website
...                 The robot use an assistant to ask some input from the human user, and then use that input some way 
...                 Author Manjunath kannur
...                 https://github.com/yarazari11/pybot.git

Library           RPA.Browser.Selenium
Library           OperatingSystem
Library           RPA.Tables
Library           RPA.PDF
Library           RPA.HTTP
Library           RPA.Dialogs
Library           RPA.Desktop
Library           RPA.Archive
Library           Collections
Library           RPA.Robocorp.Vault


*** Variables ***
${My_url_Path}                      https://robotsparebinindustries.com/#/robot-order
${My_csv_path}                      https://robotsparebinindustries.com/orders.csv
${My_Order_csv_file}                ${CURDIR}${/}Orders.csv
${My_Pdf_folder}                    ${CURDIR}${/}pdf_file
${My_image_folder}                  ${CURDIR}${/}image_file
${My_zip_file}                      ${My_Pdf_folder}${/}Archive_file.zip
# ${output_folder}                  ${CURDIR}${/}output


*** Tasks ***
Web store order   
    Get credentials
    open the intranet website
    Robots Order process in csv file
    ${Getting_order_robotsparebin}=   Robots Order process in csv file
    FOR   ${taking_loop_order}   IN   @{Getting_order_robotsparebin}
        Fill the form    ${taking_loop_order}
    Wait Until Keyword Succeeds     10x     1s    Verify new Robots from robotsparebinindustries
    Wait Until Keyword Succeeds     10x     1s    Subbimted the Order in robotsparebinindustries
    ${my_pdf}=           Store PDF file    ${taking_loop_order}[Order number]
    ${my_screenshot}=    Take a screenshot      ${taking_loop_order}[Order number]
    screenshot to the PDF file   ${taking_loop_order}[Order number]
    order another robot
    annoying model
    END
    Create a ZIP file 
    Log out browser
    Display the success dialog
    Create Yours dialog box

***keywords***
open the intranet website
    # open web site url given  variable myurlpath 
    Open Available Browser   ${My_url_Path}
    Maximize Browser Window
    Click Button    css:button.btn.btn-dark

***keywords***    
Robots Order process in csv file
    # stored csv file current directory 
    Download     url=${My_csv_path}         target_file=${My_Order_csv_file}    overwrite=True
    ${calling_the_csv_table}=   Read table from CSV    path=${My_Order_csv_file}
    [Return]    ${calling_the_csv_table}

***keywords***
Fill the form  
    # Extract the values from the  dictionary
    [Arguments]             ${webrow}
    Set Local Variable      ${order_no}         ${webrow}[Order number]
    Set Local Variable      ${head}             ${webrow}[Head]
    Set Local Variable      ${body}             ${webrow}[Body]
    Set Local Variable      ${legs}             ${webrow}[Legs]
    Set Local Variable      ${address}          ${webrow}[Address]
    # define local variables in ui path
    # xpath is prefer to a local variable
    # assign id eleement to Element

    Set Local Variable      ${txt_input_head}       //*[@id="head"]
    Set Local Variable      ${txt_input_body}       body
    Set Local Variable      ${txt_input_legs}       xpath://html/body/div/div/div[1]/div/div[1]/form/div[3]/input
    Set Local Variable      ${txt_input_address}    //*[@id="address"] 
    Set Local Variable      ${btn_preview}          //*[@id="preview"]
    Set Local Variable      ${btn_order}            //*[@id="order"]

    # Input the data. I use a "cautious" approach and assume
    # that there are situations when a field is not yet visible
    # It is however assumed that all of the input elements are visible
    # when the first element has been rendered visible.
    # An even more careful approach would result in checking if e.g.
    # the given group is actually a radio button, dropdown list etc.
    # However, this was deemed out of scope for this exercise
    Wait Until Element Is Visible   ${txt_input_head}
    Wait Until Element Is Enabled   ${txt_input_head}
    Select From List By Value       ${txt_input_head}           ${head}
    Wait Until Element Is Enabled   ${txt_input_body}
    Select Radio Button             ${txt_input_body}           ${body}
    Wait Until Element Is Enabled   ${txt_input_legs}
    Input Text                      ${txt_input_legs}           ${legs}
    Wait Until Element Is Enabled   ${txt_input_address}
    Input Text                      ${txt_input_address}        ${address}

***keywords***
Verify new Robots from robotsparebinindustries
    # priveiw the button reopen the web site
    # Define local variables for the UI elements
    Set Local Variable              ${btn_preview}          //*[@id="preview"]
    Set Local Variable              ${img_preview}          //*[@id="robot-preview-image"]
    Click Button                    ${btn_preview}
    sleep  1s
    Wait Until Element Is Visible   ${img_preview} 
    

***keywords*
Subbimted the Order in robotsparebinindustries
    # submitted to the order & receipt
    Set Local Variable              ${btn_order}       //*[@id="order"]
    Set Local Variable              ${lbl_receipt}     //*[@id="receipt"]
    
    # Do not generate screenshots if the test fails
    Mute Run On Failure             Page Should Contain Element 
    Click button                        ${btn_order}
    Sleep    1s 
    Page Should Contain Element         ${lbl_receipt}  ${btn_order} 
   

***keywords***
order another robot
   Set Local Variable     ${btnorder}     //*[@id="order-another"]
   Sleep  1s 
   Click Button           ${btnorder}
   

*** Keywords ***
Create a ZIP file 
    Archive Folder With ZIP     ${My_Pdf_folder}  ${My_zip_file}   recursive=True  include=*.pdf

***keywords***
annoying model
    Set Local Variable              ${btn_ananoying}        //*[@id="root"]/div/div[2]/div/div/div/div/div/button[2]
    Wait And Click Button           ${btn_ananoying}

***keywords***
Log out browser
    sleep  1s
    Close Browser
   

***keywords***
Display the success dialog
    # display dialog box after ordering orders show one pop msg to the user
    Add icon            Success
    Add heading         You Order is Succfully added to Bots
    Add files           all orders have been processed to the Bots.
    Run dialog          title= Success
    Close Browser

***keywords***
Create Yours dialog box
    # creating dialog boxes here 
    Add heading                 Please Enter User Inputs here
    Add text input              myway   label= How may i help you?    placeholder= Give me some input here
    ${adding_newdialogbox}=                 Run dialog
    [Return]                    ${adding_newdialogbox}

*** Keywords ***
Get credentials
    Log To Console              Getting Secret from our Vault
    ${my_vault_secret}=             Get Secret     robotsparebin    
    open available browser      https://robotsparebinindustries.com/#/
    sleep  3s
    Input Text                  id:username    ${my_vault_secret}[username]
    Input Password              id:password    ${my_vault_secret}[password]
    Close Browser

*** Keywords ***
Take a screenshot 
    [Arguments]                     ${scrren}
    Capture Element Screenshot      //*[@id="robot-preview-image"]      
    ...                             ${CURDIR}${/}image_file${/}Order_${scrren}.png    
    [Return]                        ${CURDIR}${/}image_file${/}Order_${scrren}.png 

*** Keywords ***
screenshot to the PDF file
    [Arguments]         ${takescreen_pdf_row}
    ${screenshot}=      Create List             ${CURDIR}${/}image_file${/}Order_${takescreen_pdf_row}.png   
    Add Files To Pdf    ${screenshot}           ${CURDIR}${/}pdf_file${/}Order_${takescreen_pdf_row}.pdf       True

*** Keywords ***
Store PDF file
    [Arguments]         ${store_pdf_row}                    
    ${pdf_file}=        Get Element Attribute      id:receipt      outerHTML
    Html To Pdf         ${pdf_file}      
    ...                 ${CURDIR}${/}pdf_file${/}Order_${store_pdf_row}.pdf
    [Return]            ${CURDIR}${/}pdf_file${/}Order_${store_pdf_row}.pdf
