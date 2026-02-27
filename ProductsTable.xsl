<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="html" encoding="UTF-8" indent="yes"/>

  <xsl:template match="/">
    <html>
      <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <title>Produkty</title>
        <style type="text/css">
          body {
            font-family: Arial, Helvetica, sans-serif;
            background: #f5f7fa;
            margin: 0;
            padding: 16px;
            color: #1f2937;
          }

          .table-wrap {
            background: #ffffff;
            border: 1px solid #d1d5db;
            border-radius: 8px;
            overflow-x: auto;
            overflow-y: hidden;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.08);
          }

          table {
            width: max-content;
            min-width: 100%;
            border-collapse: collapse;
            table-layout: auto;
          }

          thead th {
            background: #1f3a5f;
            color: #ffffff;
            font-weight: 700;
            font-size: 14px;
            text-align: left;
            padding: 10px 12px;
            border-right: 1px solid #39587f;
            white-space: nowrap;
          }

          thead th:last-child {
            border-right: none;
          }

          tbody td {
            height: 34px;
            padding: 0 12px;
            line-height: 34px;
            border-top: 1px solid #e5e7eb;
            border-right: 1px solid #f0f2f5;
            font-size: 13px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
          }

          tbody td:last-child {
            border-right: none;
          }

          tbody tr:nth-child(even) {
            background: #f9fafb;
          }

          tbody tr:hover {
            background: #eef4ff;
          }

          .col-nr { min-width: 60px; }
          .col-id { min-width: 180px; }
          .col-comp { min-width: 340px; }
          .col-color { min-width: 140px; }
          .col-length { min-width: 90px; }
          .col-width { min-width: 90px; }

          .num {
            text-align: right;
            font-variant-numeric: tabular-nums;
          }
        </style>
      </head>
      <body>
        <div class="table-wrap">
          <table>
            <thead>
              <tr>
                <th class="col-nr">Nr.</th>
                <th class="col-id">ID</th>
                <th class="col-comp">Skład</th>
                <th class="col-color">Kolor</th>
                <th class="col-length">Dł.</th>
                <th class="col-width">Szer.</th>
              </tr>
            </thead>
            <tbody>
              <xsl:for-each select="LOAD_PRODUCTS/PRODUCTS_LIST/PRODUCT">
                <tr>
                  <td class="col-nr num"><xsl:value-of select="position()"/></td>
                  <td class="col-id"><xsl:value-of select="ID"/></td>
                  <td class="col-comp"><xsl:value-of select="COMPOSITION"/></td>
                  <td class="col-color"><xsl:value-of select="COLOR"/></td>
                  <td class="col-length num"><xsl:value-of select="LENGTH"/></td>
                  <td class="col-width num"><xsl:value-of select="WIDTH"/></td>
                </tr>
              </xsl:for-each>
            </tbody>
          </table>
        </div>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>
