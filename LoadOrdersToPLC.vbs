Sub LoadOrdersToPLC()

    '=========================================================
    ' Deklaracja zmiennych
    '=========================================================
    Dim xmlDoc, orderNodes, orderNode
    Dim productNodes, productNode
    Dim i, j
    Dim orderStart, orderEnd
    Dim filePath
    Dim ordersPerPage, productsPerOrderMax
    Dim currentOrderPage, selectedOrder
    Dim selectedOrderXmlIndex
    Dim totalOrders, loadedOrdersCount
    Dim baseTagName, productTagName
    Dim productCountToWrite

    '=========================================================
    ' Ustawienia
    '=========================================================
    ordersPerPage = 5
    productsPerOrderMax = 15

    currentOrderPage = HmiRuntime.SmartTags("uiOrdersPageNum")
    selectedOrder = HmiRuntime.SmartTags("uiSelectedOrder")

    If currentOrderPage < 1 Then currentOrderPage = 1
    If selectedOrder < 1 Then selectedOrder = 1
    If selectedOrder > ordersPerPage Then selectedOrder = ordersPerPage

    '=========================================================
    ' Obsługa przycisków (zbocze przez reset flagi do FALSE)
    '=========================================================
    If HmiRuntime.SmartTags("bNextOrderPage") = True Then
        currentOrderPage = currentOrderPage + 1
        selectedOrder = 1
        HmiRuntime.SmartTags("bNextOrderPage") = False
    End If

    If HmiRuntime.SmartTags("bPrevOrderPage") = True Then
        If currentOrderPage > 1 Then
            currentOrderPage = currentOrderPage - 1
            selectedOrder = 1
        End If
        HmiRuntime.SmartTags("bPrevOrderPage") = False
    End If

    If HmiRuntime.SmartTags("bNextSelectedOrder") = True Then
        selectedOrder = selectedOrder + 1
        If selectedOrder > ordersPerPage Then
            currentOrderPage = currentOrderPage + 1
            selectedOrder = 1
        End If
        HmiRuntime.SmartTags("bNextSelectedOrder") = False
    End If

    If HmiRuntime.SmartTags("bPrevSelectedOrder") = True Then
        selectedOrder = selectedOrder - 1
        If selectedOrder < 1 Then
            If currentOrderPage > 1 Then
                currentOrderPage = currentOrderPage - 1
                selectedOrder = ordersPerPage
            Else
                selectedOrder = 1
            End If
        End If
        HmiRuntime.SmartTags("bPrevSelectedOrder") = False
    End If

    If HmiRuntime.SmartTags("bNextProductsPage") = True Then
        HmiRuntime.SmartTags("uiProductsPageNum") = HmiRuntime.SmartTags("uiProductsPageNum") + 1
        HmiRuntime.SmartTags("bNextProductsPage") = False
    End If

    If HmiRuntime.SmartTags("bPrevProductsPage") = True Then
        If HmiRuntime.SmartTags("uiProductsPageNum") > 1 Then
            HmiRuntime.SmartTags("uiProductsPageNum") = HmiRuntime.SmartTags("uiProductsPageNum") - 1
        End If
        HmiRuntime.SmartTags("bPrevProductsPage") = False
    End If

    HmiRuntime.SmartTags("uiOrdersPageNum") = currentOrderPage
    HmiRuntime.SmartTags("uiSelectedOrder") = selectedOrder

    '=========================================================
    ' Ścieżka do pliku XML
    '=========================================================
    filePath = "D:\Projekty\Nowy magazyn rolek\XML\ORDERS_LIST.xml"

    '=========================================================
    ' XML
    '=========================================================
    Set xmlDoc = CreateObject("Msxml2.DOMDocument.6.0")
    xmlDoc.async = False

    If Not xmlDoc.load(filePath) Then
        HmiRuntime.SmartTags("DB115_Orders_Diag_AlarmText") = _
            "Błąd wczytania pliku XML"
        Exit Sub
    End If

    Set orderNodes = xmlDoc.selectNodes("//ORDERS_LIST/ORDER")

    If orderNodes Is Nothing Or orderNodes.length = 0 Then
        HmiRuntime.SmartTags("DB115_Orders_Diag_AlarmText") = _
            "Brak zamówień"
        Exit Sub
    End If

    totalOrders = orderNodes.length

    '=========================================================
    ' Zakres zamówień dla aktualnej strony (strony: 1..N)
    '=========================================================
    orderStart = (currentOrderPage - 1) * ordersPerPage
    orderEnd = orderStart + ordersPerPage - 1

    If orderStart > totalOrders - 1 Then
        currentOrderPage = ((totalOrders - 1) \ ordersPerPage) + 1
        HmiRuntime.SmartTags("uiOrdersPageNum") = currentOrderPage
        orderStart = (currentOrderPage - 1) * ordersPerPage
        orderEnd = orderStart + ordersPerPage - 1
        selectedOrder = 1
        HmiRuntime.SmartTags("uiSelectedOrder") = selectedOrder
    End If

    If orderEnd > totalOrders - 1 Then
        orderEnd = totalOrders - 1
    End If

    '=========================================================
    ' Czyszczenie Order_1..Order_5 (tylko ID + ProductCount)
    '=========================================================
    For i = 0 To ordersPerPage - 1
        baseTagName = "DB115_Orders_Order_" & (i + 1)

        On Error Resume Next
        HmiRuntime.SmartTags(baseTagName & ".OrderID") = ""
        HmiRuntime.SmartTags(baseTagName & ".ProductCount") = 0
        On Error GoTo 0
    Next

    '=========================================================
    ' Czyszczenie globalnej listy produktów DB115_Orders_Products{0..14}
    '=========================================================
    For j = 0 To productsPerOrderMax - 1
        productTagName = "DB115_Orders_Products{" & j & "}"

        On Error Resume Next
        HmiRuntime.SmartTags(productTagName & ".sProductType") = ""
        HmiRuntime.SmartTags(productTagName & ".rLength") = 0
        On Error GoTo 0
    Next

    '=========================================================
    ' Wczytanie zamówień dla bieżącej strony (maks. 5)
    '=========================================================
    loadedOrdersCount = 0

    For i = orderStart To orderEnd
        Set orderNode = orderNodes.Item(i)
        baseTagName = "DB115_Orders_Order_" & (loadedOrdersCount + 1)

        On Error Resume Next
        HmiRuntime.SmartTags(baseTagName & ".OrderID") = orderNode.selectSingleNode("ID").text
        On Error GoTo 0

        Set productNodes = orderNode.selectNodes("PRODUCTS_LIST/PRODUCT")

        If productNodes Is Nothing Then
            HmiRuntime.SmartTags(baseTagName & ".ProductCount") = 0
        Else
            HmiRuntime.SmartTags(baseTagName & ".ProductCount") = productNodes.length
        End If

        loadedOrdersCount = loadedOrdersCount + 1
    Next

    '=========================================================
    ' Wczytanie produktów tylko dla wybranego zamówienia (max 15)
    '=========================================================
    If loadedOrdersCount > 0 And selectedOrder > loadedOrdersCount Then
        selectedOrder = 1
        HmiRuntime.SmartTags("uiSelectedOrder") = selectedOrder
    End If

    selectedOrderXmlIndex = orderStart + (selectedOrder - 1)

    If selectedOrderXmlIndex >= orderStart And selectedOrderXmlIndex <= orderEnd Then
        Set orderNode = orderNodes.Item(selectedOrderXmlIndex)
        Set productNodes = orderNode.selectNodes("PRODUCTS_LIST/PRODUCT")

        productCountToWrite = 0
        If Not productNodes Is Nothing Then
            productCountToWrite = productNodes.length
            If productCountToWrite > productsPerOrderMax Then
                productCountToWrite = productsPerOrderMax
            End If
        End If

        For j = 0 To productCountToWrite - 1
            Set productNode = productNodes.Item(j)
            productTagName = "DB115_Orders_Products{" & j & "}"

            On Error Resume Next
            HmiRuntime.SmartTags(productTagName & ".sProductType") = _
                productNode.selectSingleNode("ID").text
            HmiRuntime.SmartTags(productTagName & ".rLength") = _
                CDbl(productNode.selectSingleNode("LENGTH").text)
            On Error GoTo 0
        Next
    End If

    '=========================================================
    ' Komunikat
    '=========================================================
    HmiRuntime.SmartTags("DB115_Orders_Diag_AlarmText") = _
        "Wczytano stronę " & currentOrderPage & ": " & loadedOrdersCount & _
        " zamówień, wybrane: " & selectedOrder

End Sub
