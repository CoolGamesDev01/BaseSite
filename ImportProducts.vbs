Sub ImportProducts()

    '=========================================================
    ' Deklaracja zmiennych
    '=========================================================
    Dim fso, ts
    Dim sourceDir, sourceFile, targetDataFile, targetViewFile, targetFile
    Dim content, headerLine, piLine, lineBreak
    Dim posDeclEnd

    '=========================================================
    ' Ścieżki plików
    '=========================================================
    sourceDir = "D:\Projekty\P733_Magazyn_Rolek_Tkanin_JAMKA\XML"
    sourceFile = sourceDir & "\LOAD_PRODUCTS.xml"
    targetDataFile = sourceDir & "\IMPORTED_PRODUCTS_DATA.xml"
    targetViewFile = sourceDir & "\IMPORTED_PRODUCTS_VIEW.xml"

    '=========================================================
    ' Kopiowanie pliku XML
    '=========================================================
    Set fso = CreateObject("Scripting.FileSystemObject")

    If Not fso.FileExists(sourceFile) Then
        HmiRuntime.SmartTags("DB115_Orders_Diag_AlarmText") = _
            "Brak pliku źródłowego: LOAD_PRODUCTS.xml"
        Exit Sub
    End If

    On Error Resume Next
    fso.CopyFile sourceFile, targetDataFile, True
    If Err.Number <> 0 Then
        HmiRuntime.SmartTags("DB115_Orders_Diag_AlarmText") = _
            "Błąd kopiowania DATA XML: " & Err.Description
        Err.Clear
        On Error GoTo 0
        Exit Sub
    End If

    fso.CopyFile sourceFile, targetViewFile, True
    If Err.Number <> 0 Then
        HmiRuntime.SmartTags("DB115_Orders_Diag_AlarmText") = _
            "Błąd kopiowania VIEW XML: " & Err.Description
        Err.Clear
        On Error GoTo 0
        Exit Sub
    End If
    On Error GoTo 0

    '=========================================================
    ' Dodanie instrukcji xml-stylesheet (jeśli brak) do DATA i VIEW
    '=========================================================
    For Each targetFile In Array(targetDataFile, targetViewFile)

        If fso.FileExists(targetFile) Then

            Set ts = fso.OpenTextFile(targetFile, 1, False)
            content = ts.ReadAll
            ts.Close

            If InStr(1, LCase(content), "<?xml-stylesheet", vbTextCompare) = 0 Then
                lineBreak = vbCrLf
                piLine = "<?xml-stylesheet type=""text/xsl"" href=""ProductsTable.xsl""?>"

                posDeclEnd = InStr(1, content, "?>", vbTextCompare)

                If posDeclEnd > 0 Then
                    headerLine = Left(content, posDeclEnd + 1)
                    content = Mid(content, posDeclEnd + 2)
                    content = headerLine & lineBreak & piLine & lineBreak & content
                Else
                    content = piLine & lineBreak & content
                End If

                Set ts = fso.OpenTextFile(targetFile, 2, True)
                ts.Write content
                ts.Close
            End If

        End If

    Next

    '=========================================================
    ' Komunikat
    '=========================================================
    HmiRuntime.SmartTags("DB115_Orders_Diag_AlarmText") = _
        "Skopiowano XML: DATA + VIEW, podpięto styl ProductsTable.xsl"

End Sub
