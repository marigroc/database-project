cd VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_qa_form"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database

Private Sub btnAddSite_Click()
    Dim strSQL As String
    Dim strSiteName As String
    Dim strSiteAddress As String
    Dim rs As DAO.Recordset
    Dim db As DAO.Database
    
    On Error GoTo ErrorHandler

    ' Retrieve the site name and address from the text boxes
    strSiteName = Nz(Me.txtSiteName.Value, "")
    strSiteAddress = Nz(Me.txtSiteAddress.Value, "")
    
    ' Check if the site name and address are filled in
    If Trim(strSiteName) = "" Or Trim(strSiteAddress) = "" Then
        MsgBox "Please fill in both the Site Name and Site Address.", vbExclamation
        Exit Sub
    End If
    
    ' Initialize the database object
    Set db = CurrentDb
    
    ' Check if the site already exists
    Set rs = db.OpenRecordset("SELECT site_name FROM sites WHERE site_name = '" & strSiteName & "'")
    
    If Not rs.EOF Then
        MsgBox "The site '" & strSiteName & "' already exists.", vbExclamation
        rs.Close
        Set rs = Nothing
        Exit Sub
    End If
    rs.Close
    Set rs = Nothing
    
    ' Create the SQL statement to insert a new site
    strSQL = "INSERT INTO sites (site_name, site_address, is_current) " & _
             "VALUES ('" & strSiteName & "', '" & strSiteAddress & "', Yes);"
    
    ' Execute the SQL statement
    CurrentDb.Execute strSQL, dbFailOnError
    
    ' Notify the user
    MsgBox "Site added successfully.", vbInformation
    
    ' Clear the text boxes for new input
    Me.txtSiteName.Value = ""
    Me.txtSiteAddress.Value = ""
    
    Exit Sub

ErrorHandler:
    ' Handle errors and notify the user
    MsgBox "Error " & Err.Number & ": " & Err.Description, vbCritical, "Error"
End Sub

Private Sub btnRemoveSite_Click()
    Dim strSQL As String
    Dim strSiteName As String
    Dim rs As DAO.Recordset
    Dim db As DAO.Database
    Dim userResponse As VbMsgBoxResult
    
    ' Retrieve the site name from the text box
    strSiteName = Me.txtSiteName.Value
    
    ' Check if the site name is filled in
    If IsNull(strSiteName) Then
        MsgBox "Please enter the Site Name to remove.", vbExclamation
        Exit Sub
    End If
    
    ' Initialize the database object
    Set db = CurrentDb
    
    ' Check if the site exists and its status
    Set rs = db.OpenRecordset("SELECT site_name, is_current FROM sites WHERE site_name = '" & strSiteName & "'")
    
    
    If rs.EOF Then
        ' Site does not exist
        MsgBox "The site '" & strSiteName & "' does not exist.", vbExclamation
        rs.Close
        Set rs = Nothing
        Exit Sub
    Else
        ' Site exists, check its status
        If rs!is_current = False Then
            MsgBox "The site '" & strSiteName & "' is already decommissioned.", vbInformation
        Else
            ' Ask the user for confirmation to decommission the site
            response = MsgBox("Are you sure you want to decommission the site '" & strSiteName & "'?", vbYesNo + vbQuestion, "Confirm Decommission")
            
            If response = vbYes Then
                ' Create the SQL statement to mark the site as decommissioned
                strSQL = "UPDATE sites SET is_current = No WHERE site_name = '" & strSiteName & "';"
                
                ' Execute the SQL statement
                CurrentDb.Execute strSQL, dbFailOnError
                
                ' Notify the user
                MsgBox "The site '" & strSiteName & "' has been decommissioned.", vbInformation
            Else
                MsgBox "Site decommissioning cancelled.", vbInformation
            End If
        End If
    End If

    ' Clean up
    rs.Close
    Set rs = Nothing
    
    ' Clear the text boxes for new input
    Me.txtSiteName.Value = ""
    Me.txtSiteAddress.Value = ""
    
    Exit Sub

ErrorHandler:
    ' Handle errors and notify the user
    MsgBox "Error " & Err.Number & ": " & Err.Description, vbCritical, "Error"
End Sub

Private Sub btnAddDept_Click()
    Dim strSQL As String
    Dim strSiteName As String
    Dim strDeptName As String
    Dim strContactPerson As String
    Dim strEmail As String
    
    ' Retrieve the values from the form's combo boxes and text boxes
    strSiteName = Me.cboSite.Value
    strDeptName = Me.txtDeptName.Value
    strContactPerson = Me.txtContactPerson.Value
    strEmail = Me.txtEmail.Value
    
    ' Validate that required fields are filled in
    If IsNull(strSiteName) Or IsNull(strDeptName) Then
        MsgBox "Please select both the Site and enter the Department Name.", vbExclamation
        Exit Sub
    End If
    
    ' Check if the department already exists with is_current = False
    strSQL = "SELECT * FROM depts WHERE site = '" & strSiteName & "' AND dept_name = '" & strDeptName & "' AND is_current = False;"
    Set rst = CurrentDb.OpenRecordset(strSQL)

    If Not rst.EOF Then
        ' Department exists with is_current = False, update the existing record
        strSQL = "UPDATE depts SET is_current = True, contact = '" & strContactPerson & "', contact_email = '" & strEmail & "' " & _
                 "WHERE site = '" & strSiteName & "' AND dept_name = '" & strDeptName & "' AND is_current = False;"
        MsgBox "Existing department found. Updating to active status.", vbInformation
    Else
        ' Department does not exist, create a new record
        strSQL = "INSERT INTO depts (site, dept_name, contact, contact_email, is_current) " & _
                 "VALUES ('" & strSiteName & "', '" & strDeptName & "', '" & strContactPerson & "', '" & strEmail & "', True);"
        MsgBox "New department added successfully.", vbInformation
    End If
    
    ' Execute the SQL statement
    CurrentDb.Execute strSQL, dbFailOnError
    
    ' Clear the form for new entry
    Me.cboSite.Value = Null
    Me.txtDeptName.Value = ""
    Me.txtContactPerson.Value = ""
    Me.txtEmail.Value = ""
    
End Sub

Private Sub btnAddScan_Click()
    Dim strSQL As String
    Dim strScanID As String
    Dim strScanMan As String
    Dim strScanMod As String
    Dim strScanSerial As String
    Dim strSiteName As String
    Dim strDeptName As String
    Dim blnLoan As Boolean
    Dim rst As DAO.Recordset
    Dim newID As Long
    
    On Error GoTo ErrorHandler
    
    ' Retrieve the values from the form's text boxes and option button
    strScanMan = Me.txtScanMan.Value
    strScanID = Me.txtScanID.Value
    strScanMod = Me.txtScanMod.Value
    strScanSerial = Me.txtScanSerial.Value
    strSiteName = Me.cboSite.Value
    strDeptName = Me.cboDepartment.Value
    
    ' Use Nz to handle the case when optLoanScan is not ticked
    blnLoan = Nz(Me.optLoanScan.Value, False)
    
    ' Validate that required fields are filled in
    If IsNull(strScanMan) Or IsNull(strScanMod) Or IsNull(strScanSerial) Or IsNull(strSiteName) Or IsNull(strDeptName) Then
        MsgBox "Please choose site name and department name from the dropdown and fill in all scanner details.", vbExclamation
        Exit Sub
    End If
    
    ' Check if the scanner already exists in another department
    strSQL = "SELECT * FROM scanners WHERE serial_number = '" & strScanSerial & "';"
    Set rst = CurrentDb.OpenRecordset(strSQL)
    
    If Not rst.EOF Then
        ' Scanner exists, check if it's assigned to a different department
        If rst!dept <> strDeptName Then
            response = MsgBox("This scanner is currently assigned to department '" & rst!dept & "'. Do you want to reassign it to '" & strDeptName & "'?", vbYesNo + vbQuestion, "Reassign Scanner")
            
            If response = vbYes Then
                ' Reassign the scanner to the new department
                strSQL = "UPDATE scanners SET dept = '" & strDeptName & "', site = '" & strSiteName & "', loan = " & IIf(blnLoan, "True", "False") & " WHERE serial_number = '" & strScanSerial & "';"
                CurrentDb.Execute strSQL, dbFailOnError
                MsgBox "Scanner reassigned successfully.", vbInformation
            Else
                MsgBox "Scanner reassignment cancelled.", vbInformation
            End If
        Else
            MsgBox "This scanner is already assigned to the selected department.", vbExclamation
        End If
        
        rst.Close
        Exit Sub
    End If
    rst.Close
    
    ' Generate a new id for the scanners table
    newID = GenerateNewID("scanners")

    ' Create the SQL statement to insert a new scanner
    strSQL = "INSERT INTO scanners (id, scanner_id, brand, model, serial_number, site, dept, is_current, loan) " & _
             "VALUES (" & newID & ", '" & strScanID & "', '" & strScanMan & "', '" & strScanMod & "', '" & strScanSerial & "', " & _
             "'" & strSiteName & "', '" & strDeptName & "', True, " & IIf(blnLoan, "True", "False") & ");"
    
    ' Debug: Display the SQL query to check correctness
    ' MsgBox "SQL Query: " & strSQL
    
    ' Execute the SQL statement
    CurrentDb.Execute strSQL, dbFailOnError
    
    ' Notify the user that the scanner has been added
    MsgBox "Scanner added successfully.", vbInformation
    
    ' Clear the form for new entry
    Me.txtScanID.Value = ""
    Me.txtScanMan.Value = ""
    Me.txtScanMod.Value = ""
    Me.txtScanSerial.Value = ""
    Me.cboSite.Value = ""
    Me.cboDepartment.Value = ""
    Me.optLoanScan.Value = False
    
    Exit Sub

ErrorHandler:
    ' Handle errors and notify the user
    MsgBox "Error " & Err.Number & ": " & Err.Description, vbCritical, "Error"
End Sub

Private Sub btnRemoveScan_Click()
    Dim strSQL As String
    Dim strScanID As String
    Dim rst As DAO.Recordset
    Dim db As DAO.Database
    Dim response As VbMsgBoxResult
    
    On Error GoTo ErrorHandler
    
    ' Retrieve the value from the form's text box
    strScanID = Nz(Me.txtScanID.Value, "")
    
    ' Validate that the scanner ID is filled in
    If Trim(strScanID) = "" Then
        MsgBox "Please enter the Scanner ID.", vbExclamation
        Exit Sub
    End If
    
    ' Initialize the database object
    Set db = CurrentDb
    
    ' Check if the scanner exists and is_current = True
    strSQL = "SELECT * FROM scanners WHERE scanner_id = '" & strScanID & "';"
    Set rst = db.OpenRecordset(strSQL)
    
    If rst.EOF Then
        ' Scanner does not exist or is already decommissioned
        MsgBox "This scanner either does not exist or is already decommissioned.", vbExclamation
        rst.Close
        Exit Sub
    Else
        ' Check if the scanner is current
        If rst!is_current = False Then
            MsgBox "This scanner has already been decommissioned.", vbInformation
        Else
            ' Ask the user for confirmation to decommission the scanner
            response = MsgBox("Are you sure you want to decommission the scanner with ID '" & strScanID & "'?", vbYesNo + vbQuestion, "Confirm Decommission")
            
            If response = vbYes Then
                ' Create the SQL statement to update the scanner
                strSQL = "UPDATE scanners SET is_current = False WHERE scanner_id = '" & strScanID & "';"
                
                ' Execute the SQL statement
                db.Execute strSQL, dbFailOnError
                
                ' Notify the user that the scanner has been marked as decommissioned
                MsgBox "Scanner has been marked as decommissioned.", vbInformation
            Else
                MsgBox "Scanner decommissioning cancelled.", vbInformation
            End If
        End If
    End If
    
    ' Clean up
    rst.Close
    Set rst = Nothing
    
    ' Clear the text box for new entry
    Me.txtScanID.Value = ""

    Exit Sub

ErrorHandler:
    ' Handle errors and notify the user
    MsgBox "Error " & Err.Number & ": " & Err.Description, vbCritical, "Error"
End Sub


Private Sub btnAddProbe_Click()
    Dim strSQL As String
    Dim strSiteName As String
    Dim strDeptName As String
    Dim strScanID As String
    Dim strModel As String
    Dim strSerialNumber As String
    Dim strType As String
    Dim blnLoanPro As Boolean
    Dim rst As DAO.Recordset
    Dim strExistingScannerID As String
    Dim strExistingType As String
    Dim status As String
    Dim newID As Long
    

    ' Retrieve the values from the form's text boxes, option button, and attachment control
    strSiteName = Nz(Me.cboSite.Value, "")
    strDeptName = Nz(Me.cboDepartment.Value, "")
    strScanID = Nz(Me.cboScanner.Value, "")
    strModel = Nz(Me.txtModel.Value, "")
    strSerialNumber = Nz(Me.txtSerialNumber.Value, "")
    strType = Nz(Me.txtType.Value, "")
    blnLoanPro = Nz(Me.optLoanPro.Value, False)

    ' Validate that required fields are filled in
    If strSiteName = "" Or strDeptName = "" Or strScanID = "" Or strModel = "" _
        Or strSerialNumber = "" Or strType = "" Then
        MsgBox "Please choose site name, department name, and scanner ID from the dropdown as well as fill in all details of the probe and try again.", vbExclamation
        Exit Sub
    End If

    ' Check if the probe already exists
    strSQL = "SELECT * FROM probes WHERE serial_number = '" & strSerialNumber & "';"
    Set rst = CurrentDb.OpenRecordset(strSQL)

    If Not rst.EOF Then
        ' Probe exists, check if it's currently decommissioned
        If Not rst!is_current Then
            MsgBox "This probe re-entered use and has been assigned to a different scanner.", vbInformation
            ' Update the scanner_id and set is_current to True
            strSQL = "UPDATE probes SET scanner_id = '" & strScanID & "', is_current = True WHERE serial_number = '" & strSerialNumber & "';"
            CurrentDb.Execute strSQL, dbFailOnError
            rst.Close
            Exit Sub
        Else
            ' Probe exists and is currently assigned to another scanner
            strExistingScannerID = rst!scanner_id
            If strExistingScannerID <> strScanID Then
                Dim intResponse As Integer
                intResponse = MsgBox("Probe already exists and is assigned to the scanner " & strExistingScannerID & ". Do you want to reassign the probe to scanner " & strScanID & "?", vbYesNo + vbQuestion)
                If intResponse = vbYes Then
                    ' Update the scanner_id
                    strSQL = "UPDATE probes SET scanner_id = '" & strScanID & "' WHERE serial_number = '" & strSerialNumber & "';"
                    CurrentDb.Execute strSQL, dbFailOnError
                    MsgBox "Probe reassigned successfully.", vbInformation
                Else
                    MsgBox "Action cancelled.", vbExclamation
                    rst.Close
                    Exit Sub
                End If
            End If
        End If
    End If
    rst.Close

    ' Check if the scanner already has a probe of the same model
    strSQL = "SELECT * FROM probes WHERE scanner_id = '" & strScanID & "' AND model = '" & strModel & "' AND is_current = True;"
    Set rst = CurrentDb.OpenRecordset(strSQL)

    If Not rst.EOF Then
        ' Scanner already has a probe of this model
        Dim intSupersedeResponse As Integer
        intSupersedeResponse = MsgBox("This scanner already has a probe of this type. Do you want to supersede the old probe?", vbYesNo + vbQuestion)
        If intSupersedeResponse = vbYes Then
            ' Mark the existing probe as no longer current
            strSQL = "UPDATE probes SET is_current = False WHERE scanner_id = '" & strScanID & "' AND model = '" & strModel & "' AND is_current = True;"
            CurrentDb.Execute strSQL, dbFailOnError
        Else
            MsgBox "This scanner now has two probes of the same type.", vbInformation
        End If
    End If
    rst.Close

    ' Determine the new status based on the selected option button
    If Me.optPass.Value = True Then
        status = "Pass"
    ElseIf Me.optAdv.Value = True Then
        status = "Advisory"
    ElseIf Me.optFail.Value = True Then
        status = "Fail"
    Else
        MsgBox "Please select a status for the probe.", vbExclamation
        Exit Sub
    End If
    
    ' Generate a new id for the probes table
    newID = GenerateNewID("probes")


    ' Create the SQL statement to insert or update the probe
    strSQL = "INSERT INTO probes (id, dept, scanner_id, model, serial_number, type, status, is_current, loan) " & _
             "VALUES (" & newID & ", '" & strDeptName & "', '" & strScanID & "', '" & strModel & "', '" & strSerialNumber & "', " & _
             "'" & strType & "', '" & status & "', True, " & IIf(blnLoanPro, "True", "False") & ");"

    ' Execute the SQL statement
    CurrentDb.Execute strSQL, dbFailOnError

    ' Notify the user that the probe has been added
    MsgBox "Probe added successfully.", vbInformation

    ' Clear the form for new entry
    Me.cboSite.Value = Null
    Me.cboDepartment.Value = Null
    Me.cboScanner.Value = Null
    Me.txtModel.Value = Null
    Me.txtSerialNumber.Value = Null
    Me.txtType.Value = Null
    Me.optLoanPro.Value = False
    Me.txtScanModel.Value = Null
    Me.optAdv.Value = False
    Me.optPass.Value = False
    Me.optFail.Value = False
    
End Sub

' Function to generate a new ID by getting the maximum value from the 'id' column of any table
Private Function GenerateNewID(ByVal tableName As String) As Long
    Dim rst As DAO.Recordset
    Dim maxID As Long
    Dim strSQL As String

    ' Build the query string to get the maximum value of the 'id' column
    strSQL = "SELECT Max(id) AS maxID FROM " & tableName & ";"

    ' Query to get the maximum value of the 'id' column from the specified table
    Set rst = CurrentDb.OpenRecordset(strSQL)
    
    If Not rst.EOF Then
        maxID = Nz(rst!maxID, 0) ' Use Nz to handle null values (empty table)
    Else
        maxID = 0
    End If
    rst.Close

    ' Return the new ID (MaxID + 1)
    GenerateNewID = maxID + 1
End Function

Private Sub cboSite_AfterUpdate()
    Dim strSQL As String
    Dim strSiteName As String
    
    ' Check if a site is selected
    If Not IsNull(Me.cboSite) Then
        strSiteName = Me.cboSite.Column(0) ' Assuming the site_name is the first column (index 0)
        
        ' Create the new SQL statement for the second combo box
        strSQL = "SELECT id, dept_name FROM depts WHERE site = '" & strSiteName & "'AND is_current = True ORDER BY dept_name;"
        
        ' Debug: Display the SQL query to check correctness
        ' MsgBox "SQL Query: " & strSQL
        
        ' Assign the new Row Source to the second combo box
        Me.cboDepartment.RowSource = strSQL
        
        ' Requery the second combo box to reflect the new Row Source
        Me.cboDepartment.Requery
    End If
End Sub

Private Sub cboDepartment_AfterUpdate()
    Dim strSQL As String
    Dim strDeptName As String
    Dim rs As DAO.Recordset
    Dim strContacts As String
    Dim strEmails As String
    Dim arrContacts() As String
    Dim arrEmails() As String
    Dim i As Integer
    Dim strContactList As String
    
    ' Check if a department is selected
    If Not IsNull(Me.cboDepartment) Then
        ' Retrieve the selected dept_name (assuming it's the second column in cboDepartment)
        strDeptName = Me.cboDepartment.Column(1)
        
        ' Create the new SQL statement for the third combo box
        strSQL = "SELECT serial_number FROM scanners WHERE dept = '" & strDeptName & "' AND is_current = True ORDER BY serial_number;"
        
        ' Assign the new Row Source to the third combo box
        Me.cboScanner.RowSource = strSQL
        Me.cboScanner.Requery
        
        ' Check if the "Show Contact Details" toggle is checked
        If Me.chkShowContacts.Value = True Then
            ' Retrieve the contacts and emails from the depts table
            strSQL = "SELECT contact, contact_email FROM depts WHERE dept_name = '" & strDeptName & "';"
            
            ' Open the recordset
            Set rs = CurrentDb.OpenRecordset(strSQL)
            
            If Not rs.EOF Then
                ' Initialize the contact list
                strContactList = ""
                
                ' Loop through each record in the recordset
                Do While Not rs.EOF
                    ' Get the contacts and emails
                    strContacts = Nz(rs!contact, "")
                    strEmails = Nz(rs!contact_email, "")
                    
                    ' Split the contacts and emails into arrays
                    arrContacts = Split(strContacts, ",")
                    arrEmails = Split(strEmails, ";")
                    
                    ' Ensure both arrays have the same number of elements
                    If UBound(arrContacts) >= 0 And UBound(arrEmails) >= 0 Then
                        ' Loop through the contacts and emails, combining them
                        For i = LBound(arrContacts) To UBound(arrContacts)
                            If i <= UBound(arrEmails) Then
                                strContactList = strContactList & Trim(arrContacts(i)) & " (" & Trim(arrEmails(i)) & ")" & vbCrLf
                            Else
                                strContactList = strContactList & Trim(arrContacts(i)) & " (No Email)" & vbCrLf
                            End If
                        Next i
                    End If
                    
                    ' Move to the next record
                    rs.MoveNext
                Loop
                
                ' Display the combined contact list in the text box
                Me.txtContactList = strContactList
            Else
                ' If no records found, clear the contact list
                Me.txtContactList = ""
            End If
            
            ' Close the recordset
            rs.Close
            Set rs = Nothing
        Else
            ' Clear the contact list if the toggle box is not checked
            Me.txtContactList = ""
        End If
    End If
End Sub

Private Sub chkShowContacts_AfterUpdate()
    ' Re-run the department selection logic when the toggle box changes state
    Call cboDepartment_AfterUpdate
End Sub

Private Sub cboScanner_AfterUpdate()
    Dim strSQL As String
    Dim strScannerID As String
    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim sql As String
    Dim scannerModel As String
    
    ' Check if a scanner is selected
    If Not IsNull(Me.cboScanner) Then
        ' Retrieve the selected serial_number (assuming it's the first column in cboScanner)
        strScannerID = Me.cboScanner.Column(0)
        
        ' Create the new SQL statement for the fourth combo box
        strSQL = "SELECT serial_number FROM probes WHERE scanner_id = '" & strScannerID & "' AND is_current = True ORDER BY serial_number;"
               
        ' Get the scanner model from the scanners table
        Set db = CurrentDb
        sql = "SELECT model FROM scanners WHERE serial_number = '" & strScannerID & "';"
        Set rs = db.OpenRecordset(sql)
        
        If Not rs.EOF Then
            scannerModel = rs!model
        Else
            scannerModel = "Not found"
        End If
        
        Me.txtScanModel.Value = scannerModel
        
        rs.Close
        Set rs = Nothing
        Set db = Nothing
    End If
End Sub

Private Sub btnRemoveDept_Click()
    Dim strSQL As String
    Dim strSiteName As String
    Dim strDeptName As String
    Dim rst As DAO.Recordset
    
    ' Retrieve the values from the form's text boxes
    strSiteName = Me.cboSite.Value
    strDeptName = Me.cboDepartment.Value
    
    ' Validate that required fields are filled in
    If IsNull(strSiteName) Or IsNull(strDeptName) Then
        MsgBox "Please choose site name and department name from the dropdown and try again.", vbExclamation
        Exit Sub
    End If
    
    ' Check if the department exists
    strSQL = "SELECT * FROM depts WHERE site = '" & strSiteName & "' AND dept_name = '" & strDeptName & "';"
    Set rst = CurrentDb.OpenRecordset(strSQL)
    
    If rst.EOF Then
        MsgBox "The department '" & strDeptName & "' at site '" & strSiteName & "' does not exist.", vbExclamation
        rst.Close
        Exit Sub
    Else
        ' Check if the department is already decommissioned
        If rst!is_current = False Then
            MsgBox "The department '" & strDeptName & "' is already marked as decommissioned.", vbInformation
            rst.Close
            Exit Sub
        End If
    End If
    
    ' Update the department to mark it as decommissioned
    strSQL = "UPDATE depts SET is_current = False WHERE site = '" & strSiteName & "' AND dept_name = '" & strDeptName & "';"
    CurrentDb.Execute strSQL, dbFailOnError
    
    ' Notify the user that the department has been decommissioned
    MsgBox "Department '" & strDeptName & "' has been marked as decommissioned.", vbInformation
    
    ' Clear the form for new entry
    Me.cboSite.Value = ""
    Me.cboDepartment.Value = ""
    
    rst.Close
End Sub

Private Sub btnRemoveProbe_Click()
    Dim strSerialNumber As String
    Dim strSQL As String
    Dim rst As DAO.Recordset
    Dim strPhysComment As String

    ' Retrieve the serial number from the form
    strSerialNumber = Me.txtSerialNumber.Value

    ' Validate that the serial number is filled in
    If IsNull(strSerialNumber) Or strSerialNumber = "" Then
        MsgBox "Please enter the serial number of the probe to be removed.", vbExclamation
        Exit Sub
    End If

    ' Check if the probe exists
    strSQL = "SELECT * FROM probes WHERE serial_number = '" & strSerialNumber & "';"
    Set rst = CurrentDb.OpenRecordset(strSQL)

     If rst.EOF Then
        ' If no matching probe is found
        MsgBox "Probe with serial number " & strSerialNumber & " does not exist in the database.", vbExclamation
        rst.Close
        Exit Sub
    End If
    
    ' Prompt the user for the phys_comment
    strPhysComment = InputBox("Please provide a reason for removing the probe (leaving blank will abort the cancelation process):", "Phys Comment")

    ' If the user cancels the InputBox or provides no comment, cancel the process
    If strPhysComment = "" Then
        MsgBox "No reason given for de-commissioning. Removal process cancelled.", vbExclamation
        rst.Close
        Exit Sub
    End If

    ' If the probe exists, mark it as not current and save the phys_comment
    strSQL = "UPDATE probes SET is_current = False, phys_comment = '" & strPhysComment & "' WHERE serial_number = '" & strSerialNumber & "';"
    CurrentDb.Execute strSQL, dbFailOnError
    
    ' Close the recordset
    rst.Close

    ' Clear the form for new entry
    Me.txtSerialNumber.Value = ""

End Sub

Private Sub btnClearForm_Click()
    Dim response As VbMsgBoxResult
    
    ' Ask the user if they want to clear the form
    response = MsgBox("Do you want to clear the form?", vbYesNo + vbQuestion, "Confirm Clear Form")
    
    ' If the user selects 'Yes', clear the form
    If response = vbYes Then
        ' Clear all comboboxes and text boxes on the form
        Dim ctrl As Control
        
        For Each ctrl In Me.Controls
            If TypeOf ctrl Is TextBox Or TypeOf ctrl Is ComboBox Then
                ctrl.Value = Null
            End If
        Next ctrl
        
        ' Notify the user that the form has been cleared
        MsgBox "The form has been cleared.", vbInformation
    Else
        ' If the user selects 'No', cancel the operation
        MsgBox "The form has not been cleared.", vbInformation
    End If
End Sub

Private Sub btnContactUpdate_Click()
    On Error GoTo ErrorHandler

    Dim strContactName As String
    Dim strDeptName As String
    Dim strNewDeptName As String
    Dim strSQL As String
    Dim rs As DAO.Recordset
    Dim arrContacts() As String
    Dim arrEmails() As String
    Dim i As Integer
    Dim contactFound As Boolean
    Dim contactIndex As Integer
    Dim emailToMove As String
    Dim newContacts() As String
    Dim newEmails() As String
    Dim newContactIndex As Integer
    Dim response As Integer
    
    ' Get the contact name and department from the form
    strContactName = Trim(Me.txtContactUpdate)
    strNewDeptName = Trim(Me.txtDeptName)
    
    ' Ensure the user has entered a contact name and department
    If strContactName = "" Or strNewDeptName = "" Then
        MsgBox "Please enter a contact name and department."
        Exit Sub
    End If

    Debug.Print "Contact Name: " & strContactName
    Debug.Print "New Department: " & strNewDeptName
    
    ' Query to get the contacts and emails for all departments
    strSQL = "SELECT dept_name, contact, contact_email FROM depts;"
    
    ' Open the recordset
    Set rs = CurrentDb.OpenRecordset(strSQL)
    
    ' Initialize variables
    contactFound = False
    contactIndex = -1
    
    ' Loop through each department to find the contact
    Do While Not rs.EOF
        arrContacts = Split(Nz(rs!contact, ""), ",")
        arrEmails = Split(Nz(rs!contact_email, ""), ";")
        
        ' Search through the contact array
        For i = LBound(arrContacts) To UBound(arrContacts)
            If Trim(arrContacts(i)) = strContactName Then
                contactFound = True
                contactIndex = i
                strDeptName = rs!dept_name
                emailToMove = Trim(arrEmails(i))
                Exit For
            End If
        Next i
        
        If contactFound Then Exit Do
        
        rs.MoveNext
    Loop
    
    ' If contact is found, check if it needs to be reassigned or added to the new department
    If contactFound Then
        Debug.Print "Contact found in Department: " & strDeptName
        Debug.Print "Contact Index: " & contactIndex
        
        ' Ask the user if they want to add the contact to the new department
        response = MsgBox("The contact '" & strContactName & "' is currently assigned to the '" & strDeptName & "' department. " & _
                          "Do you want to add this contact to the '" & strNewDeptName & "' department?", vbYesNo)
        If response = vbYes Then
            ' Append the contact and email to the new department
            rs.MoveFirst
            Do While Not rs.EOF
                If rs!dept_name = strNewDeptName Then
                    arrContacts = Split(Nz(rs!contact, ""), ",")
                    arrEmails = Split(Nz(rs!contact_email, ""), ";")
                    
                    ' Add the contact and email to the arrays
                    ReDim Preserve arrContacts(UBound(arrContacts) + 1)
                    ReDim Preserve arrEmails(UBound(arrEmails) + 1)
                    arrContacts(UBound(arrContacts)) = strContactName
                    arrEmails(UBound(arrEmails)) = emailToMove
                    
                    ' Update the new department's record
                    strSQL = "UPDATE depts SET contact = '" & Join(arrContacts, ",") & "', " & _
                             "contact_email = '" & Join(arrEmails, ";") & "' " & _
                             "WHERE dept_name = '" & strNewDeptName & "';"
                    CurrentDb.Execute strSQL
                    Exit Do
                End If
                rs.MoveNext
            Loop
            
            MsgBox "Contact added to the new department."
            
            ' Ask if the contact should remain in the old department
            response = MsgBox("Do you want to keep the contact details assigned to the old department as well?", vbYesNo)
            If response = vbNo Then
                ' Remove the contact and email from the current department
                rs.MoveFirst
                Do While Not rs.EOF
                    If rs!dept_name = strDeptName Then
                        arrContacts = Split(Nz(rs!contact, ""), ",")
                        arrEmails = Split(Nz(rs!contact_email, ""), ";")
                        
                        ' Create new arrays excluding the contact to be removed
                        newContactIndex = 0
                        ReDim newContacts(UBound(arrContacts))
                        ReDim newEmails(UBound(arrEmails))
                        
                        For i = LBound(arrContacts) To UBound(arrContacts)
                            If i <> contactIndex Then
                                newContacts(newContactIndex) = arrContacts(i)
                                newEmails(newContactIndex) = arrEmails(i)
                                newContactIndex = newContactIndex + 1
                            End If
                        Next i
                        
                        ' Resize the arrays to remove empty elements only if there are any
                        If newContactIndex > 0 Then
                            ReDim Preserve newContacts(newContactIndex - 1)
                            ReDim Preserve newEmails(newContactIndex - 1)
                        Else
                            ReDim newContacts(0)
                            ReDim newEmails(0)
                        End If
                        
                        ' Update the old department's record
                        strSQL = "UPDATE depts SET contact = '" & Join(newContacts, ",") & "', " & _
                                 "contact_email = '" & Join(newEmails, ";") & "' " & _
                                 "WHERE dept_name = '" & strDeptName & "';"
                        CurrentDb.Execute strSQL
                        
                        Exit Do
                    End If
                    rs.MoveNext
                Loop
                
                MsgBox "Contact removed from the old department and assigned to the new department."
            Else
                MsgBox "Contact details kept in both departments."
            End If
        Else
            MsgBox "Contact not added to the new department."
        End If
    Else
        MsgBox "Contact not found."
    End If
    
    ' Close the recordset
    rs.Close
    Set rs = Nothing
    
    Exit Sub

ErrorHandler:
    MsgBox "Error: " & Err.Description
End Sub

Private Sub btnRemoveCont_Click()
    On Error GoTo ErrorHandler

    Dim strContactName As String
    Dim strDeptName As String
    Dim strSQL As String
    Dim rs As DAO.Recordset
    Dim arrContacts() As String
    Dim arrEmails() As String
    Dim i As Integer
    Dim contactIndex As Integer
    Dim newContacts() As String
    Dim newEmails() As String
    Dim newContactIndex As Integer
    Dim response As Integer
    
    ' Get the contact name from the form
    strContactName = Trim(Me.txtContactUpdate)
    
    ' Ensure the user has entered a contact name
    If strContactName = "" Then
        MsgBox "Please enter a contact name."
        Exit Sub
    End If

    ' Confirm the deletion
    response = MsgBox("Are you sure you want to permanently remove the contact '" & strContactName & "'?", vbYesNo + vbExclamation)
    If response = vbNo Then Exit Sub

    ' Notify the user that contact details will be lost forever
    MsgBox "Contact details are about to be lost forever.", vbExclamation
    
    ' Query to get the contacts and emails for all departments
    strSQL = "SELECT dept_name, contact, contact_email FROM depts;"
    
    ' Open the recordset
    Set rs = CurrentDb.OpenRecordset(strSQL)
    
    ' Loop through each department to find the contact
    Do While Not rs.EOF
        arrContacts = Split(Nz(rs!contact, ""), ",")
        arrEmails = Split(Nz(rs!contact_email, ""), ";")
        
        ' Search through the contact array
        contactIndex = -1
        For i = LBound(arrContacts) To UBound(arrContacts)
            If Trim(arrContacts(i)) = strContactName Then
                contactIndex = i
                Exit For
            End If
        Next i
        
        If contactIndex <> -1 Then
            ' Remove the contact and email from the current department
            newContactIndex = 0
            ReDim newContacts(UBound(arrContacts))
            ReDim newEmails(UBound(arrEmails))
            
            For i = LBound(arrContacts) To UBound(arrContacts)
                If i <> contactIndex Then
                    newContacts(newContactIndex) = arrContacts(i)
                    newEmails(newContactIndex) = arrEmails(i)
                    newContactIndex = newContactIndex + 1
                End If
            Next i
            
            ' Resize the arrays to remove empty elements only if there are any
            If newContactIndex > 0 Then
                ReDim Preserve newContacts(newContactIndex - 1)
                ReDim Preserve newEmails(newContactIndex - 1)
            Else
                ReDim newContacts(0)
                ReDim newEmails(0)
            End If
            
            ' Update the department's record
            strSQL = "UPDATE depts SET contact = '" & Join(newContacts, ",") & "', " & _
                     "contact_email = '" & Join(newEmails, ";") & "' " & _
                     "WHERE dept_name = '" & rs!dept_name & "';"
            CurrentDb.Execute strSQL
            
            MsgBox "Contact '" & strContactName & "' has been removed."
            
            ' Exit loop after removal
            Exit Do
        End If
        
        rs.MoveNext
    Loop
    
    If contactIndex = -1 Then
        MsgBox "Contact not found."
    End If
    
    ' Close the recordset
    rs.Close
    Set rs = Nothing
    
    Exit Sub

ErrorHandler:
    MsgBox "Error: " & Err.Description
End Sub


Private Sub btnEmailUpdate_Click()
    On Error GoTo ErrorHandler

    Dim strContactName As String
    Dim strDeptName As String
    Dim strNewDeptName As String
    Dim strSQL As String
    Dim rs As DAO.Recordset
    Dim arrContacts() As String
    Dim arrEmails() As String
    Dim i As Integer
    Dim contactFound As Boolean
    Dim contactIndex As Integer
    Dim emailToMove As String
    Dim newContacts() As String
    Dim newEmails() As String
    Dim newContactIndex As Integer
    Dim response As Integer
    Dim newEmail As String
    
    ' Get the contact name and department from the form
    strContactName = Trim(Me.txtContactUpdate)
    
    ' Ensure the user has entered a contact name
    If strContactName = "" Then
        MsgBox "Please enter a contact name."
        Exit Sub
    End If

    Debug.Print "Contact Name: " & strContactName
    
    ' Query to get the contacts and emails for all departments
    strSQL = "SELECT dept_name, contact, contact_email FROM depts;"
    
    ' Open the recordset
    Set rs = CurrentDb.OpenRecordset(strSQL)
    
    ' Initialize variables
    contactFound = False
    contactIndex = -1
    
    ' Loop through each department to find the contact
    Do While Not rs.EOF
        arrContacts = Split(Nz(rs!contact, ""), ",")
        arrEmails = Split(Nz(rs!contact_email, ""), ";")
        
        ' Search through the contact array
        For i = LBound(arrContacts) To UBound(arrContacts)
            If Trim(arrContacts(i)) = strContactName Then
                contactFound = True
                contactIndex = i
                strDeptName = rs!dept_name
                Exit For
            End If
        Next i
        
        If contactFound Then Exit Do
        
        rs.MoveNext
    Loop
    
    ' If contact is found, prompt for a new email address
    If contactFound Then
        newEmail = InputBox("The contact '" & strContactName & "' is currently assigned to the '" & strDeptName & "' department. " & _
                           "Please enter the new email address:", "Update Contact Email")
        
        ' Validate the new email address
        If newEmail = "" Then
            MsgBox "Email address cannot be empty."
            Exit Sub
        End If
        
        ' Update the email address in the current department
        rs.MoveFirst
        Do While Not rs.EOF
            If rs!dept_name = strDeptName Then
                arrContacts = Split(Nz(rs!contact, ""), ",")
                arrEmails = Split(Nz(rs!contact_email, ""), ";")
                
                ' Update the email for the specified contact
                If contactIndex <= UBound(arrEmails) Then
                    arrEmails(contactIndex) = newEmail
                End If
                
                ' Update the department's record
                strSQL = "UPDATE depts SET contact_email = '" & Join(arrEmails, ";") & "' " & _
                         "WHERE dept_name = '" & strDeptName & "';"
                CurrentDb.Execute strSQL
                
                MsgBox "Email address updated successfully."
                Exit Do
            End If
            rs.MoveNext
        Loop
    Else
        MsgBox "Contact not found."
    End If
    
    ' Close the recordset
    rs.Close
    Set rs = Nothing
    
    Exit Sub

ErrorHandler:
    MsgBox "Error: " & Err.Description
End Sub

Private Sub cboSiteRep_AfterUpdate()
    Dim strSQL As String
    Dim strSiteName As String
    
    ' Check if a site is selected
    If Not IsNull(Me.cboSiteRep) Then
        strSiteName = Me.cboSiteRep.Column(0) ' Assuming the site_name is the first column (index 0)
        
        ' Create the new SQL statement for the second combo box
        strSQL = "SELECT id, dept_name FROM depts WHERE site = '" & strSiteName & "' AND is_current = True ORDER BY dept_name;"
        
        ' Debug: Display the SQL query to check correctness
        ' MsgBox "SQL Query: " & strSQL
        
        ' Assign the new Row Source to the second combo box
        Me.cboDeptRep.RowSource = strSQL
        
        ' Requery the second combo box to reflect the new Row Source
        Me.cboDeptRep.Requery
    End If
End Sub

Private Sub cboDeptRep_AfterUpdate()
    Dim strSQL As String
    Dim strDeptName As String
    
    ' Check if a department is selected
    If Not IsNull(Me.cboDeptRep) Then
        ' Retrieve the selected dept_name (assuming it's the second column in cboDepartment)
        strDeptName = Me.cboDeptRep.Column(1)
        
        ' Create the new SQL statement for the third combo box
        strSQL = "SELECT serial_number FROM scanners WHERE dept = '" & strDeptName & "' AND is_current = True ORDER BY serial_number ASC;"
        
        ' Debug: Display the SQL query to check correctness
        ' MsgBox "SQL Query for cboScanner: " & strSQL
        
    End If
End Sub

Private Sub Form_Load()
    Dim i As Integer
    ' Clear previous values for cboYear
    Me.cboYear.RowSourceType = "Value List"
    Me.cboYear.RowSource = ""
    
    ' Populate cboYear with the last 10 years
    For i = Year(date) To Year(date) - 10 Step -1
        Me.cboYear.AddItem i
    Next i
    
    ' Clear and populate cboMonth with month names
    Me.cboMonth.RowSourceType = "Value List"
    Me.cboMonth.RowSource = "" ' Clear any existing values
    Me.cboMonth.RowSource = "January;February;March;April;May;June;July;August;September;October;November;December"
End Sub


Private Function GetMonthNumber(monthName As String) As Integer
    Select Case monthName
        Case "January": GetMonthNumber = 1
        Case "February": GetMonthNumber = 2
        Case "March": GetMonthNumber = 3
        Case "April": GetMonthNumber = 4
        Case "May": GetMonthNumber = 5
        Case "June": GetMonthNumber = 6
        Case "July": GetMonthNumber = 7
        Case "August": GetMonthNumber = 8
        Case "September": GetMonthNumber = 9
        Case "October": GetMonthNumber = 10
        Case "November": GetMonthNumber = 11
        Case "December": GetMonthNumber = 12
    End Select
End Function

Private Sub btnSavePDF_Click()
    Dim reportName As String
    Dim reporterName As String
    Dim pdfFileName As String
    Dim reportYear As String
    Dim reportMonth As String
    Dim siteName As String
    Dim deptName As String
    Dim chosenFile As String

    On Error GoTo ErrorHandler

    ' Get the selected site, department, month, and year from the combo boxes
    siteName = Me.cboSiteRep.Value
    deptName = Me.cboDeptRep.Value
    reportMonth = GetMonthNumber(Me.cboMonth.Value)
    reportYear = Me.cboYear.Value
    
    ' Prompt the user to enter the reporter's name
    reporterName = InputBox("Please enter the reporter's name:", "Reporter Name")
    
    ' Check if the user has provided the reporter's name
    If Len(reporterName) = 0 Then
        MsgBox "You must enter the reporter's name to save the report.", vbExclamation
        Exit Sub
    End If
    
    ' Define the report name format: "[current year] [current month] [site] [department]"
    pdfFileName = reportYear & " " & reportMonth & " " & siteName ' Without .pdf extension

    ' Prompt the user for the file path and file name
    chosenFile = InputBox("Please enter the full file path (including file name) to save the PDF (e.g., Z:\Ultrasound\" & pdfFileName & ".pdf)", "Save PDF As", "Z:\Ultrasound\" & pdfFileName & ".pdf")
    
    ' Check if the user has provided a file path
    If Len(chosenFile) = 0 Then
        MsgBox "You must provide a file path to save the report.", vbExclamation
        Exit Sub
    End If
    
    ' Ensure the file name ends with .pdf
    If Right(chosenFile, 4) <> ".pdf" Then
        chosenFile = chosenFile & ".pdf"
    End If

    ' Output the report as a PDF file, using the chosen file path
    DoCmd.OutputTo acOutputReport, "Monthly QA Report", acFormatPDF, chosenFile
    
    ' Notify the user that the file was saved successfully
    MsgBox "Report saved as PDF successfully in: " & chosenFile, vbInformation

    Exit Sub

ErrorHandler:
    MsgBox "Error " & Err.Number & ": " & Err.Description, vbCritical
End Sub

Private Sub btnOpenReport_Click()
    Dim siteName As String
    Dim deptName As String
    Dim reporterName As String
    Dim sqlQuery As String
    Dim reportName As String
    Dim reportMonth As String
    Dim reportYear As String
    
    ' Define the report name
    reportName = "Monthly QA Report"
    
    ' Get the selected site, department, month, and year from the combo boxes
    siteName = Me.cboSiteRep.Value
    deptName = Me.cboDeptRep.Value
    reportMonth = GetMonthNumber(Me.cboMonth.Value)
    reportYear = Me.cboYear.Value
    
    ' Prompt the user to enter their name
    reporterName = InputBox("Please enter your name:", "Reporter Name")

    ' Build the SQL query dynamically using a shared function
    sqlQuery = BuildReportSQL(siteName, deptName, reportMonth, reportYear, reporterName)

    ' Close the report if it is already open
    If SysCmd(acSysCmdGetObjectState, acReport, reportName) = acObjStateOpen Then
        DoCmd.Close acReport, reportName, acSaveNo
    End If
    
    ' Open the report first, so it can accept the record source
    DoCmd.OpenReport reportName, acViewDesign
    
    ' Set the record source of the report to the dynamically built query
    Reports(reportName).RecordSource = sqlQuery
    
    ' Set the text box value to the reporter's name
    Reports(reportName)!txtReporterName.ControlSource = "=""" & reporterName & """"
    Reports(reportName)!txtReportMonth.ControlSource = "=""" & Me.cboMonth.Value & """"
    Reports(reportName)!txtReportYear.ControlSource = "=""" & Me.cboYear.Value & """"
    
    ' Switch the report back to preview mode
    DoCmd.Close acReport, reportName, acSaveYes
    DoCmd.OpenReport reportName, acViewPreview
End Sub

Private Function BuildReportSQL(siteName As String, deptName As String, reportMonth As String, reportYear As String, reporterName As String) As String
    ' Build the SQL query dynamically based on provided parameters
    BuildReportSQL = "SELECT s.serial_number AS ScannerSerialNumber, " & _
               "s.scanner_id AS ScannerID, p.model AS ProbeModel, " & _
               "p.serial_number AS ProbeSerialNumber, p.status AS ProbeStatus, " & _
               "IIf(IsNull(r.ResultSerialNumber), 'No QA received for " & reportMonth & " " & reportYear & "', r.ResultComment) AS CustComments, " & _
               "d.contact AS DeptContact, '" & reporterName & "' AS ReporterName " & _
               "FROM ((scanners AS s " & _
               "INNER JOIN probes AS p ON s.serial_number = p.scanner_id) " & _
               "LEFT JOIN (SELECT serial_number AS ResultSerialNumber, " & _
               "customer_comment AS ResultComment " & _
               "FROM results " & _
               "WHERE Year(date) = " & reportYear & " " & _
               "AND Month(date) = " & reportMonth & ") AS r " & _
               "ON p.serial_number = r.ResultSerialNumber) " & _
               "INNER JOIN depts AS d ON s.dept = d.dept_name " & _
               "WHERE d.dept_name = '" & deptName & "' " & _
               "AND d.site = '" & siteName & "' " & _
               "AND s.is_current = True " & _
               "AND p.is_current = True " & _
               "ORDER BY s.serial_number, p.serial_number;"
End Function

