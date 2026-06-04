<?xml version="1.0" encoding="UTF-8"?>
<!--
  Cost Report -> HTML presentation stylesheet.
  Renders an XOPXF Cost Report (urn:xopxf:costreport:1.0) as a readable HTML
  page: production / budget-reference / reporting header, then the chapter >
  account > [line] tree with the cost report metrics. Negative variance
  (overrun) is highlighted. Works for both profiles (figures on Account in
  synthetic, on Line in analytic). Group references are resolved to names from
  the header.
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:c="urn:xopxf:costreport:1.0"
                exclude-result-prefixes="c">

  <xsl:output method="html" encoding="UTF-8" indent="yes"
              doctype-system="about:legacy-compat"/>

  <xsl:key name="kGroup" match="c:Group" use="@code"/>
  <xsl:key name="kDept"  match="c:Department" use="@code"/>
  <xsl:key name="kProd"  match="c:Producer" use="@code"/>

  <xsl:template match="/c:CostReport">
    <html lang="{@language}">
      <head>
        <meta charset="UTF-8"/>
        <title>비용 보고서 &#8211; <xsl:value-of select="c:Header/c:Production/c:Title"/></title>
        <style>
          body { font-family: -apple-system, Segoe UI, Roboto, sans-serif;
                 color: #222; margin: 24px; font-size: 13px; }
          h1 { font-size: 20px; margin: 0 0 2px; }
          .sub { color: #666; margin-bottom: 16px; }
          .meta { display: flex; flex-wrap: wrap; gap: 22px;
                  background: #f6f8fa; border: 1px solid #e1e4e8;
                  border-radius: 6px; padding: 12px 16px; margin-bottom: 16px; }
          .meta .lbl { color: #888; font-size: 11px; text-transform: uppercase; display:block; }
          .meta .val { font-weight: 600; }
          table { border-collapse: collapse; width: 100%; }
          th { background: #2c3e50; color: #fff; text-align: right; padding: 6px 8px; font-size: 11px; }
          th.l { text-align: left; }
          td { padding: 5px 8px; border-bottom: 1px solid #eee; text-align: right; }
          td.l { text-align: left; }
          tr.chapter td { background: #34495e; color: #fff; font-weight: 700; }
          tr.account td { background: #ecf3f9; font-weight: 600; }
          tr.line td.l { padding-left: 26px; font-style: italic; color: #16608a; }
          .code { font-family: ui-monospace, monospace; font-size: 11px;
                  background: #16a085; color: #fff; padding: 1px 6px; border-radius: 3px; margin-right: 6px; }
          .tag { font-size: 10px; background: #e8eef3; color: #555; padding: 1px 5px; border-radius: 3px; margin-left: 4px; }
          .neg { color: #c0392b; font-weight: 600; }
          .pos { color: #156b2e; }
          tr.total td { font-weight: 700; border-top: 2px solid #2c3e50; background: #fafafa; }
        </style>
      </head>
      <body>
        <xsl:apply-templates select="c:Header"/>
        <xsl:call-template name="bodyTable"/>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="c:Header">
    <h1><xsl:value-of select="c:Production/c:Title"/></h1>
    <div class="sub">비용 보고서 기준일 <xsl:value-of select="c:Reporting/@asOf"/></div>
    <div class="meta">
      <div><span class="lbl">제작</span><span class="val"><xsl:value-of select="c:Production/c:Code"/></span></div>
      <div><span class="lbl">보고서 번호</span><span class="val"><xsl:value-of select="c:Reporting/@number"/></span></div>
      <div><span class="lbl">기준일</span><span class="val"><xsl:value-of select="c:Reporting/@asOf"/></span></div>
      <div><span class="lbl">예산 대비</span>
           <span class="val">rev <xsl:value-of select="c:BudgetReference/@revision"/>
             <span class="tag"><xsl:value-of select="c:BudgetReference/@productionCode"/></span></span></div>
      <div><span class="lbl">발신자</span><span class="val"><xsl:value-of select="c:Transmission/c:Sender/c:Name"/></span></div>
      <xsl:if test="c:Transmission/c:Recipient">
        <div><span class="lbl">수신자</span><span class="val"><xsl:value-of select="c:Transmission/c:Recipient/c:Name"/></span></div>
      </xsl:if>
      <xsl:if test="c:PreviousReport">
        <div><span class="lbl">이전</span><span class="val">no. <xsl:value-of select="c:PreviousReport/@number"/></span></div>
      </xsl:if>
      <xsl:if test="c:Production/c:Currency">
        <div><span class="lbl">통화</span><span class="val"><xsl:value-of select="c:Production/c:Currency"/></span></div>
      </xsl:if>
    </div>
  </xsl:template>

  <xsl:template name="bodyTable">
    <table>
      <thead>
        <tr>
          <th class="l">장 / 계정 / 항목</th>
          <th>예산</th><th>지출</th><th>약정</th><th>현재까지 비용</th>
          <th>최종 예상 비용</th><th>차이</th><th>완료까지</th><th>변동</th>
        </tr>
      </thead>
      <tbody>
        <xsl:apply-templates select="c:Body/c:Chapter"/>
        <tr class="total">
          <td class="l">합계</td>
          <xsl:call-template name="sumcol"><xsl:with-param name="a" select="'budget'"/></xsl:call-template>
          <xsl:call-template name="sumcol"><xsl:with-param name="a" select="'spentToDate'"/></xsl:call-template>
          <xsl:call-template name="sumcol"><xsl:with-param name="a" select="'committed'"/></xsl:call-template>
          <xsl:call-template name="sumcol"><xsl:with-param name="a" select="'costToDate'"/></xsl:call-template>
          <xsl:call-template name="sumcol"><xsl:with-param name="a" select="'efc'"/></xsl:call-template>
          <xsl:call-template name="sumcol"><xsl:with-param name="a" select="'variance'"/></xsl:call-template>
          <xsl:call-template name="sumcol"><xsl:with-param name="a" select="'estToComplete'"/></xsl:call-template>
          <td/>
        </tr>
      </tbody>
    </table>
  </xsl:template>

  <!-- Chapter row: aggregate of all its Figures -->
  <xsl:template match="c:Chapter">
    <tr class="chapter">
      <td class="l">
        <span class="code"><xsl:value-of select="@code"/></span><xsl:value-of select="@name"/>
        <xsl:for-each select="c:GroupRef">
          <span class="tag"><xsl:value-of select="key('kGroup',@group)/@name"/></span>
        </xsl:for-each>
      </td>
      <xsl:call-template name="aggrow"><xsl:with-param name="ctx" select="."/></xsl:call-template>
    </tr>
    <xsl:apply-templates select="c:Account"/>
  </xsl:template>

  <!-- Account row -->
  <xsl:template match="c:Account">
    <tr class="account">
      <td class="l">
        <span class="code"><xsl:value-of select="@code"/></span><xsl:value-of select="@name"/>
        <xsl:if test="@externalCode"><span class="tag"><xsl:value-of select="@externalCode"/></span></xsl:if>
      </td>
      <xsl:call-template name="aggrow"><xsl:with-param name="ctx" select="."/></xsl:call-template>
    </tr>
    <xsl:apply-templates select="c:Line"/>
  </xsl:template>

  <!-- Line row (analytic only) -->
  <xsl:template match="c:Line">
    <tr class="line">
      <td class="l">
        <xsl:if test="@ref"><span class="code"><xsl:value-of select="@ref"/></span></xsl:if>
        <xsl:value-of select="@name"/>
        <xsl:if test="@department"><span class="tag"><xsl:value-of select="key('kDept',@department)/@name"/></span></xsl:if>
        <xsl:if test="@producer"><span class="tag"><xsl:value-of select="key('kProd',@producer)/@name"/></span></xsl:if>
      </td>
      <xsl:call-template name="figrow"><xsl:with-param name="f" select="c:Figures"/></xsl:call-template>
    </tr>
  </xsl:template>

  <!-- One figures row from a single Figures element -->
  <xsl:template name="figrow">
    <xsl:param name="f"/>
    <td><xsl:call-template name="n"><xsl:with-param name="v" select="$f/@budget"/></xsl:call-template></td>
    <td><xsl:call-template name="n"><xsl:with-param name="v" select="$f/@spentToDate"/></xsl:call-template></td>
    <td><xsl:call-template name="n"><xsl:with-param name="v" select="$f/@committed"/></xsl:call-template></td>
    <td><xsl:call-template name="n"><xsl:with-param name="v" select="$f/@costToDate"/></xsl:call-template></td>
    <td><xsl:call-template name="n"><xsl:with-param name="v" select="$f/@efc"/></xsl:call-template></td>
    <td>
      <xsl:attribute name="class"><xsl:choose>
        <xsl:when test="$f/@variance &lt; 0">neg</xsl:when>
        <xsl:when test="$f/@variance &gt; 0">pos</xsl:when>
      </xsl:choose></xsl:attribute>
      <xsl:call-template name="n"><xsl:with-param name="v" select="$f/@variance"/></xsl:call-template>
    </td>
    <td><xsl:call-template name="n"><xsl:with-param name="v" select="$f/@estToComplete"/></xsl:call-template></td>
    <td><xsl:call-template name="n"><xsl:with-param name="v" select="$f/c:Benchmark/@movement"/></xsl:call-template></td>
  </xsl:template>

  <!-- Aggregate row: sum of all descendant Figures of a context node -->
  <xsl:template name="aggrow">
    <xsl:param name="ctx"/>
    <td><xsl:call-template name="n"><xsl:with-param name="v" select="sum($ctx//c:Figures/@budget)"/></xsl:call-template></td>
    <td><xsl:call-template name="n"><xsl:with-param name="v" select="sum($ctx//c:Figures/@spentToDate)"/></xsl:call-template></td>
    <td><xsl:call-template name="n"><xsl:with-param name="v" select="sum($ctx//c:Figures/@committed)"/></xsl:call-template></td>
    <td><xsl:call-template name="n"><xsl:with-param name="v" select="sum($ctx//c:Figures/@costToDate)"/></xsl:call-template></td>
    <td><xsl:call-template name="n"><xsl:with-param name="v" select="sum($ctx//c:Figures/@efc)"/></xsl:call-template></td>
    <td>
      <xsl:attribute name="class"><xsl:choose>
        <xsl:when test="sum($ctx//c:Figures/@variance) &lt; 0">neg</xsl:when>
        <xsl:when test="sum($ctx//c:Figures/@variance) &gt; 0">pos</xsl:when>
      </xsl:choose></xsl:attribute>
      <xsl:call-template name="n"><xsl:with-param name="v" select="sum($ctx//c:Figures/@variance)"/></xsl:call-template>
    </td>
    <td><xsl:call-template name="n"><xsl:with-param name="v" select="sum($ctx//c:Figures/@estToComplete)"/></xsl:call-template></td>
    <td/>
  </xsl:template>

  <!-- Total column over all Figures in the document -->
  <xsl:template name="sumcol">
    <xsl:param name="a"/>
    <td><xsl:call-template name="n">
      <xsl:with-param name="v" select="sum(//c:Figures/@*[name()=$a])"/>
    </xsl:call-template></td>
  </xsl:template>

  <xsl:template name="n">
    <xsl:param name="v"/>
    <xsl:if test="$v != '' and $v != 0">
      <xsl:value-of select="format-number($v, '#.##0,00', 'eu')"/>
    </xsl:if>
  </xsl:template>

  <xsl:decimal-format name="eu" decimal-separator="," grouping-separator="."/>

</xsl:stylesheet>
