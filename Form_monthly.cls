

Private Sub cboSite_AfterUpdate()
    Dim strSQL As String
    Dim strSiteName As String
    
    ' Check if a site is selected
    If Not IsNull(Me.cboSite) Then
        strSiteName = Me.cboSite.Column(0) ' Assuming the site_name is the first column (index 0)
        
        ' Create the new SQL statement for the second combo box
        strSQL = "SELECT id, dept_name FROM depts WHERE site = '" & strSiteName & "' AND is_current = True ORDER BY dept_name;"
        
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
    
    ' Check if a department is selected
    If Not IsNull(Me.cboDepartment) Then
        ' Retrieve the selected dept_name (assuming it's the second column in cboDepartment)
        strDeptName = Me.cboDepartment.Column(1)
        
        ' Create the new SQL statement for the third combo box
        strSQL = "SELECT serial_number FROM scanners WHERE dept = '" & strDeptName & "' AND is_current = True ORDER BY serial_number ASC;"
        
        ' Debug: Display the SQL query to check correctness
        ' MsgBox "SQL Query for cboScanner: " & strSQL
        
        ' Assign the new Row Source to the third combo box
        Me.cboScanner.RowSource = strSQL
        
        ' Requery the third combo box to reflect the new Row Source
        Me.cboScanner.Requery
    End If
End Sub
Private Sub cboProbe_AfterUpdate()
    Dim probeSerialNumber As String
    Dim chart1RowSource As String
    Dim chart2RowSource As String
    Dim chart3RowSource As String
    Dim chart4RowSource As String
    Dim chart5RowSource As String
    Dim chart6RowSource As String
    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim sql As String
    Dim model As String
    Dim status As String
    Dim cusComm As String
    Dim physComm As String
    Dim boxDate As String

    ' Retrieve selected serial number
    probeSerialNumber = Me.cboProbe.Value

    ' Define RowSource for each chart
    chart1RowSource = "SELECT [date], [qa_cl_rev] FROM results WHERE [serial_number] = '" & probeSerialNumber & "' ORDER BY [date];"
    chart2RowSource = "SELECT [date], [qa_cl_gn] FROM results WHERE [serial_number] = '" & probeSerialNumber & "' ORDER BY [date];"
    chart3RowSource = "SELECT [date], [qa_cl_c] FROM results WHERE [serial_number] = '" & probeSerialNumber & "' ORDER BY [date];"
    chart4RowSource = "SELECT [date], [qa_ph_rev] FROM results WHERE [serial_number] = '" & probeSerialNumber & "' ORDER BY [date];"
    chart5RowSource = "SELECT [date], [qa_ph_gn] FROM results WHERE [serial_number] = '" & probeSerialNumber & "' ORDER BY [date];"
    chart6RowSource = "SELECT [date], [qa_ph_c] FROM results WHERE [serial_number] = '" & probeSerialNumber & "' ORDER BY [date];"

    ' Update RowSource of the charts
    Me.chart_qa_cl_r.RowSource = chart1RowSource
    Me.chart_qa_cl_g.RowSource = chart2RowSource
    Me.chart_qa_cl_c.RowSource = chart3RowSource
    Me.chart_qa_ph_r.RowSource = chart4RowSource
    Me.chart_qa_ph_g.RowSource = chart5RowSource
    Me.chart_qa_ph_c.RowSource = chart6RowSource

    ' Requery the charts to refresh the data
    Me.chart_qa_cl_r.Requery
    Me.chart_qa_cl_g.Requery
    Me.chart_qa_cl_c.Requery
    Me.chart_qa_ph_r.Requery
    Me.chart_qa_ph_g.Requery
    Me.chart_qa_ph_c.Requery

    ' Get the latest result for the selected probe
    Set db = CurrentDb
    sql = "SELECT TOP 1 [qa_cl_rev], [qa_cl_gn], [qa_cl_c], [qa_ph_rev], [qa_ph_gn], [qa_ph_c], [phys_comment], [date] " & _
          "FROM results " & _
          "WHERE [serial_number] = '" & probeSerialNumber & "' " & _
          "ORDER BY [date] DESC;"

    Set rs = db.OpenRecordset(sql)

    If Not rs.EOF Then
        ' Get the result values or assign "N/A" if null
        Me.txtqa_cl_rev.Value = Nz(rs!qa_cl_rev, "N/A")
        Me.txtqa_cl_gn.Value = Nz(rs!qa_cl_gn, "N/A")
        Me.txtqa_cl_c.Value = Nz(rs!qa_cl_c, "N/A")
        Me.txtqa_ph_rev.Value = Nz(rs!qa_ph_rev, "N/A")
        Me.txtqa_ph_gn.Value = Nz(rs!qa_ph_gn, "N/A")
        Me.txtqa_ph_c.Value = Nz(rs!qa_ph_c, "N/A")
        Me.txtPhysComm.Value = Nz(rs!phys_comment, "N/A")
        Me.txtDate.Value = Nz(rs!date, "N/A")
    Else
        ' If no results found, set all values to "N/A"
        Me.txtqa_cl_rev.Value = "N/A"
        Me.txtqa_cl_gn.Value = "N/A"
        Me.txtqa_cl_c.Value = "N/A"
        Me.txtqa_ph_rev.Value = "N/A"
        Me.txtqa_ph_gn.Value = "N/A"
        Me.txtqa_ph_c.Value = "N/A"
        Me.txtPhysComm.Value = "N/A"
        Me.txtDate.Value = "N/A"
    End If

    ' Close the recordset
    rs.Close

    ' Now get the probe status and customer comment from the probes table
    sql = "SELECT model, status, customer_comment " & _
          "FROM probes " & _
          "WHERE serial_number = '" & probeSerialNumber & "';"

    Set rs = db.OpenRecordset(sql)

    If Not rs.EOF Then
        ' Get the values or set to "N/A"
        model = Nz(rs!model, "N/A")
        status = Nz(rs!status, "N/A")
        cusComm = Nz(rs!customer_comment, "N/A")
    Else
        ' Set defaults if no probe found
        model = "N/A"
        status = "N/A"
        cusComm = "N/A"
    End If

    ' Close the recordset
    rs.Close
    Set rs = Nothing
    Set db = Nothing

    ' Update the form controls with probe info
    Me.txtModel.Value = model
    Me.txtProbeStatus.Value = status
    Me.txtCustComm.Value = cusComm

    ' Update the status option buttons based on the probe status
    ' First, clear any previous selections
    Me.optPass.Value = False
    Me.optAdv.Value = False
    Me.optFail.Value = False

    ' Now set the correct option button for the current probe's status
    Select Case status
        Case "Pass"
            Me.optPass.Value = True
        Case "Advisory"
            Me.optAdv.Value = True
        Case "Fail"
            Me.optFail.Value = True
    End Select
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
        strSQL = "SELECT serial_number FROM probes WHERE scanner_id = '" & strScannerID & "' AND is_current = True ORDER BY serial_number ASC;"
        
        ' Assign the new Row Source to the fourth combo box
        Me.cboProbe.RowSource = strSQL
        
        ' Requery the fourth combo box to reflect the new Row Source
        Me.cboProbe.Requery
        
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

Private Sub btnSave_Click()
    Dim strSQL As String
    Dim serialNumber As String
    Dim measurementDate As Date
    Dim qaCLRev As Variant
    Dim qaCLGn As Variant
    Dim qaCLC As Variant
    Dim qaPHRev As Variant
    Dim qaPHGn As Variant
    Dim qaPHC As Variant
    Dim custComm As String
    Dim physComm As String
    Dim status As String
    Dim rs As DAO.Recordset
    Dim db As DAO.Database
    
    On Error GoTo ErrorHandler

    ' Check if a serial number is selected in cboProbe
    If IsNull(Me.cboProbe) Then
        MsgBox "Please select a probe serial number.", vbExclamation
        Exit Sub
    End If
    
    ' Retrieve values from form controls
    serialNumber = Me.cboProbe.Value
    measurementDate = Me.txtDate.Value

    ' Check for "N/A" and treat it as 0
    qaCLRev = IIf(Me.txtqa_cl_rev.Value = "N/A" Or Me.txtqa_cl_rev.Value = "", Null, Me.txtqa_cl_rev.Value)
    qaCLGn = IIf(Me.txtqa_cl_gn.Value = "N/A" Or Me.txtqa_cl_gn.Value = "", Null, Me.txtqa_cl_gn.Value)
    qaCLC = IIf(Me.txtqa_cl_c.Value = "N/A" Or Me.txtqa_cl_c.Value = "", Null, Me.txtqa_cl_c.Value)
    qaPHRev = IIf(Me.txtqa_ph_rev.Value = "N/A" Or Me.txtqa_ph_rev.Value = "", Null, Me.txtqa_ph_rev.Value)
    qaPHGn = IIf(Me.txtqa_ph_gn.Value = "N/A" Or Me.txtqa_ph_gn.Value = "", Null, Me.txtqa_ph_gn.Value)
    qaPHC = IIf(Me.txtqa_ph_c.Value = "N/A" Or Me.txtqa_ph_c.Value = "", Null, Me.txtqa_ph_c.Value)


    custComm = Nz(Me.txtCustComm.Value, "")
    physComm = Nz(Me.txtPhysComm.Value, "")
    
    ' Handle single quotes in comments
    custComm = Replace(custComm, "'", "''")
    physComm = Replace(physComm, "'", "''")

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

    ' Check for duplicate entry in the results table
    Set db = CurrentDb
    strSQL = "SELECT * FROM results WHERE [serial_number] = '" & serialNumber & "' " & _
             "AND [date] = #" & Format(measurementDate, "dd\/mm\/yyyy") & "#;"

    Set rs = db.OpenRecordset(strSQL)
    
    ' If duplicate is found, notify the user and stop the save operation
    If Not rs.EOF Then
        MsgBox "This data already exists in the results table. Duplicate entries are not allowed.", vbExclamation
        rs.Close
        Exit Sub
    End If
    rs.Close

    ' Update the customer comment and status in the probes table
    strSQL = "UPDATE probes SET [status] = '" & status & "', [customer_comment] = '" & custComm & "' WHERE [serial_number] = '" & serialNumber & "';"
    CurrentDb.Execute strSQL, dbFailOnError
    
     ' Build the SQL insert statement
    strSQL = "INSERT INTO results ([date], [serial_number], [qa_cl_rev], [qa_cl_gn], [qa_cl_c], [qa_ph_rev], [qa_ph_gn], [qa_ph_c], [phys_comment]) " & _
             "VALUES (#" & Format(measurementDate, "dd\/mm\/yyyy") & "#, '" & serialNumber & "', "

    ' Append values, handling Nulls
    If IsNull(qaCLRev) Then
        strSQL = strSQL & "Null, "
    Else
        strSQL = strSQL & qaCLRev & ", "
    End If
    
    If IsNull(qaCLGn) Then
        strSQL = strSQL & "Null, "
    Else
        strSQL = strSQL & qaCLGn & ", "
    End If
    
    If IsNull(qaCLC) Then
        strSQL = strSQL & "Null, "
    Else
        strSQL = strSQL & qaCLC & ", "
    End If
    
    If IsNull(qaPHRev) Then
        strSQL = strSQL & "Null, "
    Else
        strSQL = strSQL & qaPHRev & ", "
    End If
    
    If IsNull(qaPHGn) Then
        strSQL = strSQL & "Null, "
    Else
        strSQL = strSQL & qaPHGn & ", "
    End If
    
    If IsNull(qaPHC) Then
        strSQL = strSQL & "Null, "
    Else
        strSQL = strSQL & qaPHC & ", "
    End If

    ' Append physComm and finalize the SQL
    strSQL = strSQL & "'" & physComm & "');"

    ' Execute the insert SQL
    CurrentDb.Execute strSQL, dbFailOnError
    
    ' Notify the user
    MsgBox "Data saved successfully.", vbInformation
    Exit Sub

ErrorHandler:
    MsgBox "Error " & Err.Number & ": " & Err.Description, vbCritical
End Sub



Private Sub btnClearEntry_Click()
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
        
        ' Clear the RowSource of the charts to remove their data
        Me.chart_qa_cl_r.RowSource = ""
        Me.chart_qa_cl_g.RowSource = ""
        Me.chart_qa_cl_c.RowSource = ""
        Me.chart_qa_ph_r.RowSource = ""
        Me.chart_qa_ph_g.RowSource = ""
        Me.chart_qa_ph_c.RowSource = ""
        
        ' Requery the charts to reflect the cleared state
        Me.chart_qa_cl_r.Requery
        Me.chart_qa_cl_g.Requery
        Me.chart_qa_cl_c.Requery
        Me.chart_qa_ph_r.Requery
        Me.chart_qa_ph_g.Requery
        Me.chart_qa_ph_c.Requery
        
        ' Notify the user that the form has been cleared
        MsgBox "The form has been cleared.", vbInformation
    Else
        ' If the user selects 'No', cancel the operation
        MsgBox "The form has not been cleared.", vbInformation
    End If
End Sub

Private Sub btnSearch_Click()
    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim strProbeID As String
    Dim strSQL As String
    Dim chart1RowSource As String
    Dim chart2RowSource As String
    Dim chart3RowSource As String
    Dim chart4RowSource As String
    Dim chart5RowSource As String
    Dim chart6RowSource As String

    ' Get the probe ID from the text box
    strProbeID = Nz(Me.txtSearchProbe.Value, "")

    ' Check if the search box is empty
    If strProbeID = "" Then
        MsgBox "Please enter a probe ID to search.", vbExclamation
        Exit Sub
    End If

    ' Set up the database and query
    Set db = CurrentDb

    ' Properly escape single quotes in the probe ID (for safety)
    strProbeID = Replace(strProbeID, "'", "''")

    ' SQL query to fetch details
    strSQL = "SELECT pro.serial_number, pro.model AS ProbeModel, pro.scanner_id, " & _
             "scan.model AS ScannerModel, dep.dept_name, dep.site, " & _
             "pro.status AS ProbeStatus, pro.customer_comment, " & _
             "res.qa_cl_rev, res.qa_cl_gn, res.qa_cl_c, " & _
             "res.qa_ph_rev, res.qa_ph_gn, res.qa_ph_c " & _
             "FROM ((probes AS pro " & _
             "INNER JOIN scanners AS scan ON pro.scanner_id = scan.serial_number) " & _
             "INNER JOIN depts AS dep ON scan.dept = dep.dept_name) " & _
             "LEFT JOIN results AS res ON pro.serial_number = res.serial_number " & _
             "WHERE pro.serial_number = '" & strProbeID & "';"

    On Error GoTo ErrorHandler
    ' Open the recordset
    Set rs = db.OpenRecordset(strSQL)

    ' Check if the recordset is properly opened and not empty
    If rs Is Nothing Then
        MsgBox "Recordset could not be opened.", vbCritical
        Exit Sub
    End If

    ' Check if a matching record was found
    If Not rs.EOF Then
        ' Populate the form controls with the data
        Me.cboSite.Value = rs!site
        Me.cboDepartment.Value = rs!dept_name
        Me.cboScanner.Value = rs!scanner_id
        Me.cboProbe.Value = rs!serial_number
        Me.txtScanModel.Value = rs!scannerModel
        Me.txtModel.Value = rs!ProbeModel
        Me.txtProbeStatus.Value = rs!ProbeStatus
        Me.txtCustComm.Value = rs!customer_comment
        
        ' Define RowSource for each chart using the actual probe's serial number
        chart1RowSource = "SELECT [date], [qa_cl_rev] FROM results WHERE [serial_number] = '" & strProbeID & "' ORDER BY [date];"
        chart2RowSource = "SELECT [date], [qa_cl_gn] FROM results WHERE [serial_number] = '" & strProbeID & "' ORDER BY [date];"
        chart3RowSource = "SELECT [date], [qa_cl_c] FROM results WHERE [serial_number] = '" & strProbeID & "' ORDER BY [date];"
        chart4RowSource = "SELECT [date], [qa_ph_rev] FROM results WHERE [serial_number] = '" & strProbeID & "' ORDER BY [date];"
        chart5RowSource = "SELECT [date], [qa_ph_gn] FROM results WHERE [serial_number] = '" & strProbeID & "' ORDER BY [date];"
        chart6RowSource = "SELECT [date], [qa_ph_c] FROM results WHERE [serial_number] = '" & strProbeID & "' ORDER BY [date];"
        
        ' Update RowSource of the charts
        Me.chart_qa_cl_r.RowSource = chart1RowSource
        Me.chart_qa_cl_g.RowSource = chart2RowSource
        Me.chart_qa_cl_c.RowSource = chart3RowSource
        Me.chart_qa_ph_r.RowSource = chart4RowSource
        Me.chart_qa_ph_g.RowSource = chart5RowSource
        Me.chart_qa_ph_c.RowSource = chart6RowSource
    
        ' Requery the charts to update them
        Me.chart_qa_cl_r.Requery
        Me.chart_qa_cl_g.Requery
        Me.chart_qa_cl_c.Requery
        Me.chart_qa_ph_r.Requery
        Me.chart_qa_ph_g.Requery
        Me.chart_qa_ph_c.Requery
    Else
        MsgBox "No probe found with the entered ID.", vbExclamation
    End If

    ' Close the recordset
    If Not rs Is Nothing Then rs.Close
    Set rs = Nothing
    Set db = Nothing
    Exit Sub

ErrorHandler:
    MsgBox "Error " & Err.Number & ": " & Err.Description, vbCritical
    If Not rs Is Nothing Then rs.Close
    Set rs = Nothing
    Set db = Nothing
End Sub

Private Sub optPass_AfterUpdate()
    If Me.optPass.Value = True Then
        Me.optAdv.Value = False
        Me.optFail.Value = False
    End If
End Sub

Private Sub optAdv_AfterUpdate()
    If Me.optAdv.Value = True Then
        Me.optPass.Value = False
        Me.optFail.Value = False
    End If
End Sub

Private Sub optFail_AfterUpdate()
    If Me.optFail.Value = True Then
        Me.optPass.Value = False
        Me.optAdv.Value = False
    End If
End Sub

Private Sub btnEdit_Click()
    Dim strSQL As String
    Dim serialNumber As String
    Dim measurementDate As Date
    Dim qaCLRev As Variant
    Dim qaCLGn As Variant
    Dim qaCLC As Variant
    Dim qaPHRev As Variant
    Dim qaPHGn As Variant
    Dim qaPHC As Variant
    Dim custComm As String
    Dim physComm As String
    Dim db As DAO.Database
    
    On Error GoTo ErrorHandler

    ' Retrieve values from form controls
    serialNumber = Me.cboProbe.Value
    measurementDate = Me.txtDate.Value

    ' Retrieve the values from the textboxes, allowing empty fields to be saved as Null
    qaCLRev = IIf(Me.txtqa_cl_rev.Value = "N/A", Null, Nz(Me.txtqa_cl_rev.Value, Null))
    qaCLGn = IIf(Me.txtqa_cl_gn.Value = "N/A", Null, Nz(Me.txtqa_cl_gn.Value, Null))
    qaCLC = IIf(Me.txtqa_cl_c.Value = "N/A", Null, Nz(Me.txtqa_cl_c.Value, Null))
    qaPHRev = IIf(Me.txtqa_ph_rev.Value = "N/A", Null, Nz(Me.txtqa_ph_rev.Value, Null))
    qaPHGn = IIf(Me.txtqa_ph_gn.Value = "N/A", Null, Nz(Me.txtqa_ph_gn.Value, Null))
    qaPHC = IIf(Me.txtqa_ph_c.Value = "N/A", Null, Nz(Me.txtqa_ph_c.Value, Null))
    
    ' Handle comments (customer_comment and phys_comment)
    custComm = Nz(Me.txtCustComm.Value, "")
    physComm = Nz(Me.txtPhysComm.Value, "")
    
    ' Replace single quotes to avoid SQL injection
    custComm = Replace(custComm, "'", "''")
    physComm = Replace(physComm, "'", "''")

    ' Open the database connection
    Set db = CurrentDb
    
    ' Update the existing record in the results table, allowing Null values
    strSQL = "UPDATE results SET " & _
             "[qa_cl_rev] = " & Nz(qaCLRev, "Null") & ", " & _
             "[qa_cl_gn] = " & Nz(qaCLGn, "Null") & ", " & _
             "[qa_cl_c] = " & Nz(qaCLC, "Null") & ", " & _
             "[qa_ph_rev] = " & Nz(qaPHRev, "Null") & ", " & _
             "[qa_ph_gn] = " & Nz(qaPHGn, "Null") & ", " & _
             "[qa_ph_c] = " & Nz(qaPHC, "Null") & ", " & _
             "[phys_comment] = '" & physComm & "' " & _
             "WHERE [serial_number] = '" & serialNumber & "' AND [date] = #" & Format(measurementDate, "dd\/mm\/yyyy") & "#;"
    
    db.Execute strSQL, dbFailOnError
    
    ' Update the customer_comment in the probes table
    strSQL = "UPDATE probes SET [customer_comment] = '" & custComm & "' " & _
             "WHERE [serial_number] = '" & serialNumber & "';"
    
    db.Execute strSQL, dbFailOnError

    ' Notify the user
    MsgBox "Record updated successfully.", vbInformation

    Exit Sub

ErrorHandler:
    MsgBox "Error " & Err.Number & ": " & Err.Description, vbCritical
End Sub


