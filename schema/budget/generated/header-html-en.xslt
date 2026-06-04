<?xml version="1.0" encoding="UTF-8"?>
<!--
  Header -> HTML presentation stylesheet.
  Renders ONLY the <Header> of a Budget document: transmission, production and
  revision metadata, plus every declared vocabulary (groups, phases, departments,
  producers, roles, units, detail types, vat and withholding rates).

  This is the document's "data dictionary" / cover sheet, complementary to
  budget-html.xslt which renders the budget body (and deliberately omits these
  vocabularies). Labels are in English to match the standard.
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:b="urn:xopxf:budget:1.0"
                exclude-result-prefixes="b">

  <xsl:output method="html" encoding="UTF-8" indent="yes"
              doctype-system="about:legacy-compat"/>

  <xsl:template match="/b:Budget">
    <html lang="{@language}">
      <head>
        <meta charset="UTF-8"/>
        <title>
          <xsl:text>Header &#8211; </xsl:text>
          <xsl:value-of select="b:Header/b:Production/b:Title"/>
        </title>
        <style>
          body { font-family: -apple-system, Segoe UI, Roboto, sans-serif;
                 color: #222; margin: 24px; font-size: 13px; }
          h1 { font-size: 20px; margin: 0 0 2px; }
          .sub { color: #666; margin-bottom: 16px; }
          h2 { font-size: 14px; margin: 22px 0 6px; color: #2c3e50;
               border-bottom: 2px solid #2c3e50; padding-bottom: 3px; }
          .meta { display: flex; flex-wrap: wrap; gap: 22px;
                  background: #f6f8fa; border: 1px solid #e1e4e8;
                  border-radius: 6px; padding: 12px 16px; margin-bottom: 8px; }
          .meta .lbl { color: #888; font-size: 11px; text-transform: uppercase; display:block; }
          .meta .val { font-weight: 600; }
          .badge { display: inline-block; padding: 2px 8px; border-radius: 4px;
                   font-size: 11px; font-weight: 600; }
          .badge.confirmed { background: #d4f7dd; color: #156b2e; }
          .badge.draft { background: #fff3cd; color: #856404; }
          table { border-collapse: collapse; width: 100%; margin-bottom: 4px; }
          th { background: #34495e; color: #fff; text-align: left;
               padding: 5px 8px; font-size: 11px; }
          th.num, td.num { text-align: right; }
          td { padding: 4px 8px; border-bottom: 1px solid #eee; }
          tr:nth-child(even) td { background: #fafbfc; }
          .code { font-family: ui-monospace, monospace; font-size: 11px;
                  background: #16a085; color: #fff; padding: 1px 6px;
                  border-radius: 3px; }
          .scheme { font-size: 10px; background: #e8eef3; color: #555;
                    padding: 1px 5px; border-radius: 3px; }
          .empty { color: #aaa; font-style: italic; }
        </style>
      </head>
      <body>
        <xsl:apply-templates select="b:Header"/>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="b:Header">
    <h1><xsl:value-of select="b:Production/b:Title"/></h1>
    <div class="sub">Document header and data dictionary</div>

    <!-- ============ Document metadata ============ -->
    <h2>Document</h2>
    <div class="meta">
      <div><span class="lbl">Document ID</span>
           <span class="val"><xsl:value-of select="b:Transmission/b:DocumentId"/></span></div>
      <div><span class="lbl">Issue date</span>
           <span class="val"><xsl:value-of select="b:Transmission/b:IssueDate"/></span></div>
      <div><span class="lbl">Sender</span>
           <span class="val"><xsl:value-of select="b:Transmission/b:Sender/b:Name"/></span></div>
      <xsl:if test="b:Transmission/b:Recipient">
        <div><span class="lbl">Recipient</span>
             <span class="val"><xsl:value-of select="b:Transmission/b:Recipient/b:Name"/></span></div>
      </xsl:if>
    </div>

    <h2>Production</h2>
    <div class="meta">
      <div><span class="lbl">Code</span>
           <span class="val"><xsl:value-of select="b:Production/b:Code"/></span></div>
      <div><span class="lbl">Title</span>
           <span class="val"><xsl:value-of select="b:Production/b:Title"/></span></div>
      <xsl:if test="b:Production/b:Episodes">
        <div><span class="lbl">Episodes</span>
             <span class="val"><xsl:value-of select="b:Production/b:Episodes"/></span></div>
      </xsl:if>
      <xsl:if test="b:Production/b:Currency">
        <div><span class="lbl">Currency</span>
             <span class="val"><xsl:value-of select="b:Production/b:Currency"/></span></div>
      </xsl:if>
      <xsl:if test="b:Production/b:StartDate">
        <div><span class="lbl">Start</span>
             <span class="val"><xsl:value-of select="b:Production/b:StartDate"/></span></div>
      </xsl:if>
      <xsl:if test="b:Production/b:EndDate">
        <div><span class="lbl">End</span>
             <span class="val"><xsl:value-of select="b:Production/b:EndDate"/></span></div>
      </xsl:if>
      <div><span class="lbl">Revision</span>
           <span class="val">
             <xsl:value-of select="b:Revision/@number"/><xsl:text> </xsl:text>
             <span class="badge {b:Revision/@status}"><xsl:value-of select="b:Revision/@status"/></span>
           </span></div>
    </div>

    <!-- ============ Vocabularies ============ -->
    <xsl:call-template name="groups"/>
    <xsl:call-template name="phases"/>
    <xsl:call-template name="codeName">
      <xsl:with-param name="title" select="'Departments'"/>
      <xsl:with-param name="rows"  select="b:Departments/b:Department"/>
    </xsl:call-template>
    <xsl:call-template name="producers"/>
    <xsl:call-template name="codeName">
      <xsl:with-param name="title" select="'Roles'"/>
      <xsl:with-param name="rows"  select="b:Roles/b:Role"/>
    </xsl:call-template>
    <xsl:call-template name="codeName">
      <xsl:with-param name="title" select="'Units of measure'"/>
      <xsl:with-param name="rows"  select="b:UnitsOfMeasure/b:UnitOfMeasure"/>
    </xsl:call-template>
    <xsl:call-template name="detailTypes"/>
    <xsl:call-template name="rates">
      <xsl:with-param name="title" select="'VAT rates'"/>
      <xsl:with-param name="rows"  select="b:VatRates/b:VatRate"/>
    </xsl:call-template>
    <xsl:call-template name="rates">
      <xsl:with-param name="title" select="'Withholding rates'"/>
      <xsl:with-param name="rows"  select="b:WithholdingRates/b:WithholdingRate"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Groups (with scheme) -->
  <xsl:template name="groups">
    <h2>Groups</h2>
    <xsl:choose>
      <xsl:when test="b:Groups/b:Group">
        <table>
          <thead><tr><th>Code</th><th>Name</th><th>Scheme</th></tr></thead>
          <tbody>
            <xsl:for-each select="b:Groups/b:Group">
              <tr>
                <td><span class="code"><xsl:value-of select="@code"/></span></td>
                <td><xsl:value-of select="@name"/></td>
                <td><xsl:if test="@scheme"><span class="scheme"><xsl:value-of select="@scheme"/></span></xsl:if></td>
              </tr>
            </xsl:for-each>
          </tbody>
        </table>
      </xsl:when>
      <xsl:otherwise><p class="empty">none declared</p></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Phases (with dates) -->
  <xsl:template name="phases">
    <h2>Phases</h2>
    <xsl:choose>
      <xsl:when test="b:Phases/b:Phase">
        <table>
          <thead><tr><th>Code</th><th>Name</th><th>Start</th><th>End</th></tr></thead>
          <tbody>
            <xsl:for-each select="b:Phases/b:Phase">
              <tr>
                <td><span class="code"><xsl:value-of select="@code"/></span></td>
                <td><xsl:value-of select="@name"/></td>
                <td><xsl:value-of select="@startDate"/></td>
                <td><xsl:value-of select="@endDate"/></td>
              </tr>
            </xsl:for-each>
          </tbody>
        </table>
      </xsl:when>
      <xsl:otherwise><p class="empty">none declared</p></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Producers (with vatId) -->
  <xsl:template name="producers">
    <h2>Producers</h2>
    <xsl:choose>
      <xsl:when test="b:Producers/b:Producer">
        <table>
          <thead><tr><th>Code</th><th>Name</th><th>VAT ID</th></tr></thead>
          <tbody>
            <xsl:for-each select="b:Producers/b:Producer">
              <tr>
                <td><span class="code"><xsl:value-of select="@code"/></span></td>
                <td><xsl:value-of select="@name"/></td>
                <td><xsl:value-of select="@vatId"/></td>
              </tr>
            </xsl:for-each>
          </tbody>
        </table>
      </xsl:when>
      <xsl:otherwise><p class="empty">none declared</p></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Detail types (with contingency flag) -->
  <xsl:template name="detailTypes">
    <h2>Detail types</h2>
    <xsl:choose>
      <xsl:when test="b:DetailTypes/b:DetailType">
        <table>
          <thead><tr><th>Code</th><th>Name</th><th>Contingency</th></tr></thead>
          <tbody>
            <xsl:for-each select="b:DetailTypes/b:DetailType">
              <tr>
                <td><span class="code"><xsl:value-of select="@code"/></span></td>
                <td><xsl:value-of select="@name"/></td>
                <td><xsl:if test="@contingency = 'true'">yes</xsl:if></td>
              </tr>
            </xsl:for-each>
          </tbody>
        </table>
      </xsl:when>
      <xsl:otherwise><p class="empty">none declared</p></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Generic code/name table (departments, roles, units) -->
  <xsl:template name="codeName">
    <xsl:param name="title"/>
    <xsl:param name="rows"/>
    <h2><xsl:value-of select="$title"/></h2>
    <xsl:choose>
      <xsl:when test="$rows">
        <table>
          <thead><tr><th>Code</th><th>Name</th></tr></thead>
          <tbody>
            <xsl:for-each select="$rows">
              <tr>
                <td><span class="code"><xsl:value-of select="@code"/></span></td>
                <td><xsl:value-of select="@name"/></td>
              </tr>
            </xsl:for-each>
          </tbody>
        </table>
      </xsl:when>
      <xsl:otherwise><p class="empty">none declared</p></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Rate tables (vat, withholding) -->
  <xsl:template name="rates">
    <xsl:param name="title"/>
    <xsl:param name="rows"/>
    <h2><xsl:value-of select="$title"/></h2>
    <xsl:choose>
      <xsl:when test="$rows">
        <table>
          <thead><tr><th>Code</th><th>Name</th><th class="num">Rate %</th></tr></thead>
          <tbody>
            <xsl:for-each select="$rows">
              <tr>
                <td><span class="code"><xsl:value-of select="@code"/></span></td>
                <td><xsl:value-of select="@name"/></td>
                <td class="num"><xsl:value-of select="@rate"/></td>
              </tr>
            </xsl:for-each>
          </tbody>
        </table>
      </xsl:when>
      <xsl:otherwise><p class="empty">none declared</p></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
