<?xml version="1.0" encoding="UTF-8"?>
<!--
  Details -> HTML presentation stylesheet (localized template).
  Renders an XOPXF Details document (urn:xopxf:details:1.0) as a readable HTML
  page: production / budget-reference / cost-report-reference header, then the
  chapter > account > movement tree.

  Data minimisation in the rendering
  ==================================
  Each movement carries only a payee code (payeeRef). This stylesheet resolves it
  to a name via the optional Header/Parties registry: when Parties is present the
  counterparty name (and city) is shown; when it is absent (minimised transmission)
  only the code is shown. The same stylesheet therefore renders both the full and
  the minimised form correctly, without ever inventing data.

  This file is a TEMPLATE: the double-at placeholders are replaced per language by
  regen.py from l10n/labels-<lang>.json. Do not edit the generated copies.
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:d="urn:xopxf:details:1.0"
                exclude-result-prefixes="d">

  <xsl:output method="html" encoding="UTF-8" indent="yes"
              doctype-system="about:legacy-compat"/>

  <xsl:key name="kGroup" match="d:Group" use="@code"/>
  <xsl:key name="kDept"  match="d:Department" use="@code"/>
  <xsl:key name="kProd"  match="d:Producer" use="@code"/>
  <xsl:key name="kRole"  match="d:Role" use="@code"/>
  <xsl:key name="kType"  match="d:MovementType" use="@code"/>
  <xsl:key name="kParty" match="d:Party" use="@code"/>

  <xsl:template match="/d:Details">
    <html lang="{@language}">
      <head>
        <meta charset="UTF-8"/>
        <title>Détails &#8211; <xsl:value-of select="d:Header/d:Production/d:Title"/></title>
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
          tr.movement td.l { padding-left: 26px; }
          .code { font-family: ui-monospace, monospace; font-size: 11px;
                  background: #16a085; color: #fff; padding: 1px 6px; border-radius: 3px; margin-right: 6px; }
          .tag { font-size: 10px; background: #e8eef3; color: #555; padding: 1px 5px; border-radius: 3px; margin-left: 4px; }
          .payroll { background: #fdecea; color: #b03a2e; }
          .payee { font-weight: 600; }
          .payee.code-only { font-family: ui-monospace, monospace; color: #7d3c98; }
          a.doc { font-size: 11px; color: #2471a3; text-decoration: none; margin-left: 6px; }
          a.doc:hover { text-decoration: underline; }
          tr.total td { font-weight: 700; border-top: 2px solid #2c3e50; background: #fafafa; }
          .note { color: #888; font-size: 11px; margin-top: 10px; }
        </style>
      </head>
      <body>
        <xsl:apply-templates select="d:Header"/>
        <xsl:call-template name="bodyTable"/>
        <xsl:if test="not(d:Header/d:Parties)">
          <p class="note">Répertoire des contreparties omis : seuls les codes sont affichés (minimisation des données).</p>
        </xsl:if>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="d:Header">
    <h1><xsl:value-of select="d:Production/d:Title"/></h1>
    <div class="sub">Mouvements analytiques justifiant le rapport de coûts</div>
    <div class="meta">
      <div><span class="lbl">Production</span><span class="val"><xsl:value-of select="d:Production/d:Code"/></span></div>
      <div><span class="lbl">Par rapport au budget</span>
           <span class="val">rev <xsl:value-of select="d:BudgetReference/@revision"/></span></div>
      <div><span class="lbl">Rapport de coûts</span>
           <span class="val">no. <xsl:value-of select="d:CostReportReference/@number"/>
             <xsl:if test="d:CostReportReference/@asOf">
               <span class="tag"><xsl:value-of select="d:CostReportReference/@asOf"/></span>
             </xsl:if></span></div>
      <div><span class="lbl">ID du document</span><span class="val"><xsl:value-of select="d:Transmission/d:DocumentId"/></span></div>
      <div><span class="lbl">Émetteur</span><span class="val"><xsl:value-of select="d:Transmission/d:Sender/d:Name"/></span></div>
      <xsl:if test="d:Transmission/d:Recipient">
        <div><span class="lbl">Destinataire</span><span class="val"><xsl:value-of select="d:Transmission/d:Recipient/d:Name"/></span></div>
      </xsl:if>
      <xsl:if test="d:Production/d:Currency">
        <div><span class="lbl">Devise</span><span class="val"><xsl:value-of select="d:Production/d:Currency"/></span></div>
      </xsl:if>
    </div>
  </xsl:template>

  <xsl:template name="bodyTable">
    <table>
      <thead>
        <tr>
          <th class="l">Chapitre / Compte / Mouvement</th>
          <th>Date</th>
          <th class="l">Contrepartie</th>
          <th class="l">Description</th>
          <th>Dépensé</th>
          <th>Commandé</th>
        </tr>
      </thead>
      <tbody>
        <xsl:apply-templates select="d:Body/d:Chapter"/>
        <tr class="total">
          <td class="l">TOTAL</td>
          <td/><td/><td/>
          <td><xsl:call-template name="n"><xsl:with-param name="v" select="sum(//d:Movement/@spent)"/></xsl:call-template></td>
          <td><xsl:call-template name="n"><xsl:with-param name="v" select="sum(//d:Movement/@ordered)"/></xsl:call-template></td>
        </tr>
      </tbody>
    </table>
  </xsl:template>

  <!-- Chapter row: sum of its movements -->
  <xsl:template match="d:Chapter">
    <tr class="chapter">
      <td class="l">
        <span class="code"><xsl:value-of select="@code"/></span><xsl:value-of select="@name"/>
        <xsl:for-each select="d:GroupRef">
          <span class="tag"><xsl:value-of select="key('kGroup',@group)/@name"/></span>
        </xsl:for-each>
      </td>
      <td/><td/><td/>
      <td><xsl:call-template name="n"><xsl:with-param name="v" select="sum(.//d:Movement/@spent)"/></xsl:call-template></td>
      <td><xsl:call-template name="n"><xsl:with-param name="v" select="sum(.//d:Movement/@ordered)"/></xsl:call-template></td>
    </tr>
    <xsl:apply-templates select="d:Account"/>
  </xsl:template>

  <!-- Account row -->
  <xsl:template match="d:Account">
    <tr class="account">
      <td class="l">
        <span class="code"><xsl:value-of select="@code"/></span><xsl:value-of select="@name"/>
        <xsl:if test="@externalCode"><span class="tag"><xsl:value-of select="@externalCode"/></span></xsl:if>
      </td>
      <td/><td/><td/>
      <td><xsl:call-template name="n"><xsl:with-param name="v" select="sum(.//d:Movement/@spent)"/></xsl:call-template></td>
      <td><xsl:call-template name="n"><xsl:with-param name="v" select="sum(.//d:Movement/@ordered)"/></xsl:call-template></td>
    </tr>
    <xsl:apply-templates select="d:Movement"/>
  </xsl:template>

  <!-- Movement row -->
  <xsl:template match="d:Movement">
    <tr class="movement">
      <td class="l">
        <xsl:variable name="mt" select="key('kType',@type)"/>
        <span class="tag">
          <xsl:choose>
            <xsl:when test="$mt"><xsl:value-of select="$mt/@name"/></xsl:when>
            <xsl:otherwise><xsl:value-of select="@type"/></xsl:otherwise>
          </xsl:choose>
        </span>
        <xsl:if test="@documentNumber"><span class="code"><xsl:value-of select="@documentNumber"/></span></xsl:if>
        <xsl:if test="d:Document/@url">
          <a class="doc" href="{d:Document/@url}">document</a>
        </xsl:if>
      </td>
      <td><xsl:value-of select="@date"/></td>
      <td class="l">
        <xsl:call-template name="payee"/>
        <xsl:if test="@role">
          <span class="tag"><xsl:value-of select="key('kRole',@role)/@name"/></span>
        </xsl:if>
        <xsl:if test="key('kType',@type)/@payroll = 'true'">
          <span class="tag payroll">paie</span>
        </xsl:if>
      </td>
      <td class="l"><xsl:value-of select="@description"/></td>
      <td><xsl:call-template name="n"><xsl:with-param name="v" select="@spent"/></xsl:call-template></td>
      <td><xsl:call-template name="n"><xsl:with-param name="v" select="@ordered"/></xsl:call-template></td>
    </tr>
  </xsl:template>

  <!-- Resolve payeeRef to a name via Parties; fall back to the bare code when the
       registry is absent (minimised transmission). Never invents data. -->
  <xsl:template name="payee">
    <xsl:if test="@payeeRef">
      <xsl:variable name="p" select="key('kParty',@payeeRef)"/>
      <xsl:choose>
        <xsl:when test="$p">
          <span class="payee">
            <xsl:choose>
              <xsl:when test="$p/@legalName"><xsl:value-of select="$p/@legalName"/></xsl:when>
              <xsl:when test="$p/@personName"><xsl:value-of select="$p/@personName"/></xsl:when>
              <xsl:otherwise><xsl:value-of select="@payeeRef"/></xsl:otherwise>
            </xsl:choose>
          </span>
          <xsl:if test="$p/@city"><span class="tag"><xsl:value-of select="$p/@city"/></span></xsl:if>
        </xsl:when>
        <xsl:otherwise>
          <span class="payee code-only"><xsl:value-of select="@payeeRef"/></span>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <!-- Separators localized via num_decimal / num_grouping; pattern uses the
       canonical role symbols, decimal-format remaps to the per-language ones. -->
  <xsl:template name="n">
    <xsl:param name="v"/>
    <xsl:if test="$v != '' and $v != 0">
      <xsl:value-of select="format-number($v, '# ##0,00', 'eu')"/>
    </xsl:if>
  </xsl:template>

  <xsl:decimal-format name="eu" decimal-separator="," grouping-separator=" "/>

</xsl:stylesheet>
