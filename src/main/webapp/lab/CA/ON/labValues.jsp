<%--

    Copyright (c) 2001-2002. Department of Family Medicine, McMaster University. All Rights Reserved.
    This software is published under the GPL GNU General Public License.
    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation; either version 2
    of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

    This software was written for the
    Department of Family Medicine
    McMaster University
    Hamilton
    Ontario, Canada

--%>

<%@ taglib uri="/WEB-INF/security.tld" prefix="security"%>
<%
      String roleName$ = (String)session.getAttribute("userrole") + "," + (String) session.getAttribute("user");
	  boolean authed=true;
%>
<security:oscarSec roleName="<%=roleName$%>" objectName="_lab" rights="r" reverse="<%=true%>">
	<%authed=false; %>
	<%response.sendRedirect("../../../securityError.jsp?type=_lab");%>
</security:oscarSec>
<%
if(!authed) {
	return;
}
%>

<%@ page import="org.oscarehr.util.LoggedInInfo"%>
<%@ page import="org.oscarehr.caisi_integrator.ws.CachedDemographicLabResult"%>
<%@ page import="org.oscarehr.managers.DemographicManager" %>
<%@ page import="org.oscarehr.common.model.Demographic"%>
<%@ page import="org.oscarehr.util.SpringUtils"%>
<%@ page import="java.util.*"%>
<%@ page import="java.io.Serializable"%>

<%@ page import="org.w3c.dom.Document"%>

<%@ page import="oscar.oscarLab.ca.on.*"%>
<%@ page import="oscar.oscarLab.ca.all.web.LabDisplayHelper"%>

<%@ page import="org.owasp.encoder.Encode"%>

<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic"%>
<%

String labType = request.getParameter("labType");
String demographicNo = request.getParameter("demo");
String testName = request.getParameter("testName");
String identifier = request.getParameter("identifier");
String remoteFacilityIdString = request.getParameter("remoteFacilityId");
String remoteLabKey = request.getParameter("remoteLabKey");

if (identifier == null) identifier = "NULL";

String highlight = "#E0E0FF";

LoggedInInfo loggedInInfo=LoggedInInfo.getLoggedInInfoFromSession(request);

DemographicManager demographicManager = SpringUtils.getBean( DemographicManager.class );
Demographic demographic = demographicManager.getDemographic(loggedInInfo, demographicNo);

ArrayList list = null;

if (! (demographicNo == null || "null".equals(demographicNo) || "undefined".equals(demographicNo)) ){
	if(remoteFacilityIdString==null)
	{
		list = CommonLabTestValues.findValuesForTest(labType, Integer.valueOf(demographicNo), testName, identifier);
	}
	else
	{
		CachedDemographicLabResult remoteLab=LabDisplayHelper.getRemoteLab(loggedInInfo, Integer.parseInt(remoteFacilityIdString), remoteLabKey,Integer.parseInt(demographicNo));
		Document labContentsAsXml=LabDisplayHelper.getXmlDocument(remoteLab);
		HashMap<String, ArrayList<Map<String, Serializable>>> mapOfTestValues=LabDisplayHelper.getMapOfTestValues(labContentsAsXml);
		list=mapOfTestValues.get(identifier);
	}
}



%>
<!DOCTYPE html>
<html>
<head>
<script type="text/javascript" src="<%= request.getContextPath() %>/js/global.js"></script>
<html:base />
<title><bean:message key="oscarMDS.segmentDisplay.title" /></title>
    <link href="<%=request.getContextPath() %>/css/bootstrap.css" rel="stylesheet" type="text/css">
    <link href="<%=request.getContextPath() %>/css/DT_bootstrap.css" rel="stylesheet" type="text/css">

    <script type="text/javascript" src="<%=request.getContextPath() %>/js/jquery-1.12.3.js"></script>
    <!-- <script src="https://code.jquery.com/jquery-3.6.4.min.js" integrity="sha256-oP6HI9z1XaZNBrJURtCoUT5SUnxFr8s3BzRl+cbzUq8=" crossorigin="anonymous"></script>-->

    <script type="text/javascript" src="<%=request.getContextPath() %>/js/jquery.dataTables.1.10.11.min.js"></script>
    <!-- <script src="https://cdn.datatables.net/1.13.4/js/jquery.dataTables.min.js" integrity="sha256-VSu9DD6vJurraXgjxQJv9BuzedGfJm7XEgPQQehKBlw=" crossorigin="anonymous"></script></script>-->

    <script type="text/javascript">
    // As exception to usual OSCAR conventions a CDN is used instead of a local i18n resource to reduce code maintenance
    // NOTE
    // DataTables 1.13.4 language plugin is tested compatible with 1.10.11
    // and allows for specific use of tag global.i18nLanguagecode=fr-FR  pt-BR
    // if 404 eg offline, no translation available at data tables eg en-CA, no properties file entry for this langauge, etc
    // the english default will automatically be used

	    jQuery(document).ready( function () {
	        jQuery('#tblDiscs').DataTable({
            "order": [],
	        "bPaginate": false,
            "searching": false,
            "language": {
                        "url": "//cdn.datatables.net/plug-ins/1.13.4/i18n/<bean:message key="global.i18nLanguagecode"/>.json"
                    }
            });
	    });
    </script>

    <style type="text/css">
        .AbnormalRes {
            color: red;
        }
        .LoRes {
            color: blue;
        }
    </style>

    <style type="text/css" media="print">
         .DoNotPrint {
	        display:none;
         }
     </style>

</head>

<script language="JavaScript">
function getComment() {
    var commentVal = prompt('<bean:message key="oscarMDS.segmentDisplay.msgComment"/>', '');
    document.acknowledgeForm.comment.value = commentVal;
    return true;
}

function popupStart(vheight,vwidth,varpage,windowname) {
    var page = varpage;
    windowprops = "height="+vheight+",width="+vwidth+",location=no,scrollbars=yes,menubars=no,toolbars=no,resizable=yes";
    var popup=window.open(varpage, windowname, windowprops);
}
</script>

<body>

  <%  if(demographic==null){%>

<script language="JavaScript">
alert("The demographic number is not valid");
window.close();
</script>

    <%} else{%>
<form name="acknowledgeForm" method="post"
	action="../../../oscarMDS/UpdateStatus.do">

<table width="100%" height="100%" border="0" cellspacing="0"
	cellpadding="0">
	<tr>
		<td valign="top">

		<table width="100%" border="1" cellspacing="0" cellpadding="3"
			bgcolor="#9999CC" bordercolordark="#bfcbe3">
			<tr>
				<td width="66%" align="middle" class="Cell">
				<div class="Field2"><bean:message
					key="oscarMDS.segmentDisplay.formDetailResults" /></div>
				</td>
			</tr>
			<tr>
				<td bgcolor="white" valign="top">
				<table valign="top" border="0" cellpadding="2" cellspacing="0"
					width="100%">
					<tr valign="top">
						<td valign="top" width="33%" align="left">
						<table width="100%" border="0" cellpadding="2" cellspacing="0"
							valign="top">
							<tr>
								<td valign="top" align="left">
								<table valign="top" border="0" cellpadding="3" cellspacing="0"
									width="50%">
									<tr>
										<td colspan="2">
										<div class="FieldData"><strong><bean:message
											key="oscarMDS.segmentDisplay.formPatientName" />: </strong> <%=Encode.forHtml(demographic.getFormattedName())%></div>

										</td>
										<td colspan="2">
										<div class="FieldData"="nowrap"><strong><bean:message
											key="oscarMDS.segmentDisplay.formSex" />: </strong><%=Encode.forHtml(demographic.getSex())%>
										</div>
										</td>
									</tr>
									<tr>
										<td colspan="2">
										<div class="FieldData"><strong><bean:message
											key="oscarMDS.segmentDisplay.formDateBirth" />: </strong> <%=Encode.forHtml(demographic.getFormattedDob())%>
										</div>
										</td>
										<td colspan="2">
										<div class="FieldData"><strong><bean:message
											key="oscarMDS.segmentDisplay.formAge" />: </strong><%=Encode.forHtml(demographic.getAge())%>
										</div>
										</td>
									</tr>


								</table>
								</td>
								<td width="33%" valign="top"></td>
							</tr>
						</table>
						</td>
					</tr>
				</table>
				</td>

			</tr>

<%--			<tr>--%>
<%--				<td align="center" bgcolor="white" colspan="2">--%>
<%--				<table width="100%" height="20" border="0" cellpadding="0"--%>
<%--					cellspacing="0">--%>
<%--					<tr>--%>
<%--						<td align="center" bgcolor="white">--%>
<%--						<div class="FieldData">--%>
<%--						<center></center>--%>
<%--						</div>--%>
<%--						</td>--%>
<%--					</tr>--%>
<%--				</table>--%>
<%--				</td>--%>
<%--			</tr>--%>
		</table>



<%--		<table style="page-break-inside: avoid;" bgcolor="#003399" border="0"--%>
<%--			cellpadding="0" cellspacing="0" width="100%">--%>
<%--			<tr>--%>
<%--				<td colspan="4" height="7">&nbsp;</td>--%>
<%--			</tr>--%>
<%--			<tr>--%>
<%--				<td colspan="4" height="7">&nbsp;</td>--%>
<%--			</tr>--%>

<%--		</table>--%>

		<table width="100%" border="0" cellspacing="0" cellpadding="2"
			bgcolor="#CCCCFF" bordercolor="#9966FF" bordercolordark="#bfcbe3"
			name="tblDiscs" id="tblDiscs" class= "table table-condensed table-striped">
            <thead>
			<tr class="Field2">
				<th class="Cell"><bean:message
					key="oscarMDS.segmentDisplay.formTestName" /></th>
				<th class="Cell"><bean:message
					key="oscarMDS.segmentDisplay.formResult" /></th>
				<th class="Cell"><bean:message
					key="oscarMDS.segmentDisplay.formAbn" /></th>
				<th class="Cell"><bean:message
					key="oscarMDS.segmentDisplay.formReferenceRange" /></th>
				<th class="Cell"><bean:message
					key="oscarMDS.segmentDisplay.formUnits" /></th>
				<th class="Cell"><bean:message
					key="oscarMDS.segmentDisplay.formDateTimeCompleted" /></th>
			</tr>
            </thead>
			<%  int linenum = 0;

                            if (list != null){
                               for (int i = 0 ;  i < list.size(); i++){
                                   Map h = (Map) list.get(i);
                                   String lineClass = "NormalRes";
                                   if ( h.get("abn") != null && h.get("abn").equals("A") ){
                                      lineClass = "AbnormalRes";
                                   }
                                   if ( h.get("abn") != null && (h.get("abn").toString().toLowerCase().contains("l")) ){
                                      lineClass = "LoRes";
                                   }
                                   if ( h.get("abn") != null && (h.get("abn").toString().toLowerCase().contains("h")) ){
                                      lineClass = "AbnormalRes";
                                   }
%>

			<tr bgcolor="<%=(linenum % 2 == 1 ? highlight : "")%>"
				class="<%=lineClass%>">
				<td><%=h.get("testName") %></td>
				<td><%=h.get("result") %></td>
				<td><%=h.get("abn") %></td>
				<td><%=h.get("range")%></td>
				<td><%=h.get("units") %></td>
				<td><%=h.get("collDate")%></td>
			</tr>

			<%     }
                            } %>

		</table>

		<table width="100%" border="0" cellspacing="0" cellpadding="3"
			class="MainTableBottomRowRightColumn" bgcolor="#003399">
			<tr>
				<td align="left"><input type="button" class="btn DoNotPrint"
					value=" <bean:message key="global.btnClose"/> "
					onClick="window.close()"> <input type="button" class="btn DoNotPrint"
					value=" <bean:message key="global.btnPrint"/> "
					onClick="window.print()">
                               <%-- <input type="button" value="Plot"
                                onclick="window.open('../../../oscarEncounter/GraphMeasurements.do?method=actualLab&demographic_no=<%=demographicNo%>&labType=<%=labType%>&identifier=<%=identifier%>&testName=<%=testName%>');"/>
                                --%>
                               <input type="button" value="<bean:message key="oscarEncounter.oscarMeasurements.displayHistory.plot"/>" class="btn DoNotPrint"
                                onclick="window.location = 'labValuesGraph.jsp?demographic_no=<%=demographicNo%>&labType=<%=labType%>&identifier=<%=identifier%>&testName=<%=testName%>';"/>

                                </td>
			</tr>
		</table>
		</td>
	</tr>
</table>

</form>
<%}%>
</body>
</html>